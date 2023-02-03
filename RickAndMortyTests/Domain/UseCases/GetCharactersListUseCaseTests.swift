//
//  GetCharactersListUseCaseTests.swift
//  RickAndMortyTests
//
//  Created by Alejandro Gonzalez Casado on 2/2/23.
//

import Combine
import Foundation
import XCTest
@testable import RickAndMorty

final class GetCharactersListUseCaseTests: XCTestCase {
    
    var sut: GetCharactersListUseCase?
    private var repository: CharactersRepositoryMock?
    
    lazy var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        repository = CharactersRepositoryMock()
        sut = GetCharactersListUseCaseImplm(repository: repository)
        super.setUp()
    }
    
    override func tearDown() {
        cancellables.removeAll()
        repository = nil
        sut = nil
        super.tearDown()
    }
}

extension GetCharactersListUseCaseTests {
    
    func testGetCharactersSuccess() {
        //GIVE
        var isFinished: Bool = false
        var receivedError: Error?
        var characters: [RickAndMorty.Character] = []
        let exp = expectation(description: "completion")
        
        repository!
            .getCharactersValue = Just(RickAndMorty.Character.charactersExample)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        //WHEN
        sut!.execute(page: 1)
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
        XCTAssert(isFinished)
        XCTAssertNil(receivedError)
        XCTAssertFalse(characters.isEmpty)
    }
    
    func testGetCharactersByFilterError() {
        //GIVE
        var isFinished: Bool = false
        var receivedError: Error?
        var characters: [RickAndMorty.Character] = []
        let exp = expectation(description: "error")
        
        //WHEN
        sut!.execute(page: 1, filterBy: "Alex")
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
    
    func testGetCharactersRepositoryError() {
        //GIVE
        sut = GetCharactersListUseCaseImplm(repository: nil)

        var receivedError: GetCharactersListUseCaseError = .generalError()
   
        let exp = expectation(description: "repositoryError")
        //WHEN
        sut!.execute(page: 1, filterBy: "Alex")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = (error as? GetCharactersListUseCaseError) ?? receivedError
                }
                exp.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.5)
        //THEN
        XCTAssert(receivedError.isRepositoryNotFound)
    }
}

private final class CharactersRepositoryMock: CharactersRepository {
    
    var getCharactersValue: AnyPublisher<[RickAndMorty.Character], Error>?
    var getCharactersFilteredValue: AnyPublisher<[RickAndMorty.Character], Error>?
    
    func getCharacters(page: Int?) -> AnyPublisher<[RickAndMorty.Character], Error> {
        return getCharactersValue
        ?? Fail(error: NSError(domain: "Default execute failure", code: -1)).eraseToAnyPublisher()
    }
    
    func getCharacters(page: Int?, filterBy name: String) -> AnyPublisher<[RickAndMorty.Character], Error> {
        return getCharactersFilteredValue?
            .map({ characters in characters.filter{$0.name.contains(name)} })
            .eraseToAnyPublisher()
        ?? Fail(error: CharactersRepositoryError.generalError(message: "TestError")).eraseToAnyPublisher()
    }
    
}

private extension RickAndMorty.Character {
    static var charactersExample: [Self] {
        [.init(id: 0, name: "Alex", status: .alive,
               species: "Human", type: "", gender: .male,
               origin: "Earth", location: "Earth"),
         .init(id: 1, name: "Rick", status: .unknown,
               species: "Human", type: "", gender: .male,
               origin: "Earth", location: "Earth")]
    }
}

private extension GetCharactersListUseCaseError {
    var isRepositoryNotFound: Bool {
        switch self {
        case .repositoryNotFound:
            return true
        default:
            return false
        }
    }
}
