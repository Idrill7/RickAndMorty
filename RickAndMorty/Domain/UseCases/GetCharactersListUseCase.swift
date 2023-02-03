//
//  GetCharactersListUseCase.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 30/1/23.
//

import Combine
import Foundation

enum GetCharactersListUseCaseError: Error {
    case characterNotFound
    case generalError(message: String = "")
    case missingName
    case lastPageReached
    case repositoryNotFound
}

protocol GetCharactersListUseCase {
    func execute(page: Int?) -> AnyPublisher<[Character], Error>
    func execute(page: Int?, filterBy name: String) -> AnyPublisher<[Character], Error>
}

final class GetCharactersListUseCaseImplm: GetCharactersListUseCase {

    private var repository: CharactersRepository?
    
    init(repository: CharactersRepository?) {
        self.repository = repository
    }
}

extension GetCharactersListUseCaseImplm {
    func execute(page: Int? = 1) -> AnyPublisher<[Character], Error> {
        guard let repository = repository else {
            return Fail(error: GetCharactersListUseCaseError.repositoryNotFound).eraseToAnyPublisher()
        }
        return repository.getCharacters(page: page)
            .mapError { error -> GetCharactersListUseCaseError in
                switch (error as? CharactersRepositoryError) {
                case .lastPageReached:
                    return .lastPageReached
                case .generalError(let message):
                    return .generalError(message: message)
                default:
                    return .generalError(message: "The operation couldn’t be completed. Try again!")
                }
            }
            .eraseToAnyPublisher()
    }
    
    func execute(page: Int?, filterBy name: String) -> AnyPublisher<[Character], Error> {
        guard let repository = repository else {
            return Fail(error: GetCharactersListUseCaseError.repositoryNotFound).eraseToAnyPublisher()
        }
        return repository.getCharacters(page: page, filterBy: name)
            .mapError { error -> GetCharactersListUseCaseError in
                switch (error as? CharactersRepositoryError) {
                case .characterNotFound:
                    return .characterNotFound
                case .missingName:
                    return .missingName
                case .lastPageReached:
                    return .lastPageReached
                case .generalError(let message):
                    return .generalError(message: message)
                default:
                    return .generalError(message: "The operation couldn’t be completed. Try again!")
                }
            }
            .eraseToAnyPublisher()
    }
}
