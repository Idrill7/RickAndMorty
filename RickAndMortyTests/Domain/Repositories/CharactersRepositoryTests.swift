//
//  CharactersRepositoryTests.swift
//  RickAndMortyTests
//
//  Created by Alejandro Gonzalez Casado on 2/2/23.
//

import Combine
import Foundation
import XCTest
@testable import RickAndMorty

final class CharactersRepositoryTests: XCTestCase {
    
    var sut: CharactersRepository?
    private var dataSource: CharactersDataSourceMock?
    
    lazy var cancellables = Set<AnyCancellable>()
    
    override func setUp()  {
        dataSource = CharactersDataSourceMock()
        sut = CharactersRepositoryImplm(charactersDS: dataSource!)
        super.setUp()
    }
    override func tearDown() {
        cancellables.removeAll()
        dataSource = nil
        sut = nil
        super.tearDown()
    }
}

extension CharactersRepositoryTests {
    
    func testGetCharactersSuccess() {
        //GIVE
        var isFinished: Bool = false
        var receivedError: Error?
        var characters: [Character] = []
        
        dataSource!
            .getCharactersResponse = Just(RickAndMorty.DTOCharactersResponse.responseExample)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        let exp = expectation(description: "characters success")
        //WHEN
        sut!.getCharacters(page: 1)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    isFinished = true
                case .failure(let error):
                    receivedError = error
                }
                exp.fulfill()
            }, receiveValue: { res in
                characters = res
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.5)
        //THEN
        XCTAssert(isFinished)
        XCTAssertNil(receivedError)
        XCTAssertFalse(characters.isEmpty)
    }
    
    func testGetCharactersByFilterError() {
        //GIVE
        var isFinished: Bool = false
        var receivedError: Error?
        var characters: [Character] = []
        let exp = expectation(description: "error")
        //WHEN
        sut!.getCharacters(page: 1, filterBy: "Alex")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    isFinished = true
                case .failure(let error):
                    receivedError = error
                }
                exp.fulfill()
            }, receiveValue: { value in
                characters = value
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.5)
        //THEN
        XCTAssertFalse(isFinished)
        XCTAssertNotNil(receivedError)
        XCTAssertTrue(characters.isEmpty)
    }
    
    func testGetCharactersLastPageReached() {
        //GIVE
        var receivedError: CharactersRepositoryError = .generalError()
   
        let firstExp = expectation(description: "getCharacters completion")
        let secondExp = expectation(description: "error")
        
        dataSource!
            .getCharactersResponse = Just(RickAndMorty.DTOCharactersResponse.responseExample)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        sut!.getCharacters(page: 1)
            .sink(receiveCompletion: { _ in
                firstExp.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        //WHEN
        sut!.getCharacters(page: 3)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = (error as? CharactersRepositoryError) ?? receivedError
                }
                secondExp.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.5)
        //THEN
        XCTAssert(receivedError.isLastPageReached)
    }
}

private final class CharactersDataSourceMock: CharactersDataSource {
    
    var getCharactersResponse: AnyPublisher<RickAndMorty.DTOCharactersResponse, Error>?
    
    var getCharactersFilterResponse: AnyPublisher<RickAndMorty.DTOCharactersResponse, Error>?
    
    func getCharacters(page: Int) -> AnyPublisher<RickAndMorty.DTOCharactersResponse, Error> {
        getCharactersResponse
        ?? Fail(error: CharactersDataSourceError.badRequest(message: "GetCharacters Error")).eraseToAnyPublisher()
    }
    
    func getCharacters(page: Int, filterBy name: String) -> AnyPublisher<RickAndMorty.DTOCharactersResponse, Error> {
        return getCharactersFilterResponse
        ?? Fail(error: CharactersDataSourceError.badRequest(message: "GetCharactersFilters Error")).eraseToAnyPublisher()
    }
}


private extension RickAndMorty.DTOCharactersResponse {
    static var responseExample: Self {
        .init(info: .init(count: 1, pages: 2, next: "next", prev: nil),
              results: [.init(id: 0, name: "Alex", status: "Alive", species: "Human",
                              type: "", gender: "Male", origin: .init(name: "Earth", url: ""),
                              location: .init(name: "Earth", url: ""), image: "", episode: [""],
                              url: "", created: "2023-01-31T00:00:00.000Z")])
    }
}

private extension CharactersRepositoryError {
    var isLastPageReached: Bool {
        switch self {
        case .lastPageReached:
            return true
        default:
            return false
        }
    }
}
