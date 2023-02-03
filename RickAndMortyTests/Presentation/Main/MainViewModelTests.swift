//
//  MainViewModelTests.swift
//  RickAndMortyTests
//
//  Created by Alejandro Gonzalez Casado on 2/2/23.
//

import Combine
import Foundation
import XCTest
@testable import RickAndMorty

final class MainViewModelTests: XCTestCase {
    
    private var getCharactersListUseCase: GetCharactersListUseCaseMock?
    var sut: MainViewModel?
    
    lazy var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        getCharactersListUseCase = GetCharactersListUseCaseMock()
        sut = MainViewModel(charactersListUC: getCharactersListUseCase)
        super.setUp()
    }
    
    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        super.tearDown()
    }
}

extension MainViewModelTests {
    
    func testGetCharactersReceivedSuccess() {
        //GIVE
        var receivedState: MainViewModel.State = .none
        
        getCharactersListUseCase!
            .executedPageValue = Just(RickAndMorty.Character.charactersExample)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        //WHEN
        let exp = expectation(description: "onCharactersReceived")
        sut!.trigger(.getCharacters)
        
        sut!.data
            .state
            .sink { state in
                switch state {
                case .onCharactersReceived:
                    receivedState = state
                    exp.fulfill()
                default:
                    XCTFail("Unexpected state")
                }
                
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.5)
        //THEN
        XCTAssert(receivedState.isOnCharacterReceived)
    }
    
    func testGetFilteredCharactersReceivedSuccess() {
        //GIVE
        getCharactersListUseCase!
            .executedPageFilteredValue = Just(RickAndMorty.Character.charactersExample)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        //WHEN
        let exp = expectation(description: "data")
        sut!.trigger(.searchCharacters(name: "Alex"))
        
        sut!.$data
            .dropFirst(1)
            .sink(receiveValue: { data in
                exp.fulfill()
        })
        .store(in: &cancellables)
        
        waitForExpectations(timeout: 1)
        //THEN
        XCTAssertTrue(sut!.data.characters.count == 1)
    }
    
    func testGetFilteredCharactersReceivedFailure() {
        //GIVE
        var receivedState: MainViewModel.State = .none
        //WHEN
        let exp = expectation(description: "data")
        sut!.trigger(.searchCharacters(name: "Alex"))
        
        sut!.data
            .state
            .sink { state in
                switch state {
                case .failure:
                    receivedState = state
                    exp.fulfill()
                default:
                    XCTFail("Unexpected state")
                }
                
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.5)
        //THEN
        XCTAssert(receivedState.isFailed)
    }
}

private final class GetCharactersListUseCaseMock: GetCharactersListUseCase {
    
    var executedPageValue: AnyPublisher<[RickAndMorty.Character], Error>?
    var executedPageFilteredValue: AnyPublisher<[RickAndMorty.Character], Error>?
    
    func execute(page: Int?) -> AnyPublisher<[RickAndMorty.Character], Error> {
        return executedPageValue
        ?? Fail(error: GetCharactersListUseCaseError.generalError(message: "execute failed")).eraseToAnyPublisher()
    }
    
    func execute(page: Int?, filterBy name: String) -> AnyPublisher<[RickAndMorty.Character], Error> {
        return executedPageFilteredValue?
            .map({ characters in characters.filter{$0.name.contains(name)} })
            .eraseToAnyPublisher()
        ?? Fail(error: GetCharactersListUseCaseError.generalError(message: "executeFilter failed")).eraseToAnyPublisher()
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

private extension MainViewModel.State {
    var isOnCharacterReceived: Bool {
        switch self {
        case .onCharactersReceived:
            return true
        default:
            return false
        }
    }
    
    var isFailed: Bool {
        switch self {
        case .failure:
            return true
        default:
            return false
        }
    }
}

