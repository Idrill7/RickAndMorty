//
//  CharactersRepository.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 30/1/23.
//

import Combine
import Foundation

private extension Int {
    static var defaultPage: Self { 1 }
}

enum CharactersRepositoryError: Error {
    case generalError(message: String = "")
    case lastPageReached
    case missingName
    case characterNotFound
}

protocol CharactersRepository {
    func getCharacters(page: Int?) -> AnyPublisher<[Character], Error>
    func getCharacters(page: Int?, filterBy name: String) -> AnyPublisher<[Character], Error>
}

final class CharactersRepositoryImplm: CharactersRepository {
    
    private let charactersDS: CharactersDataSource
    private var maxPages: Int = .max
    private var fileteredMaxPages: Int = .max
    
    init(charactersDS: CharactersDataSource) {
        self.charactersDS = charactersDS
    }
}

extension CharactersRepositoryImplm {
    
    func getCharacters(page: Int? = nil) -> AnyPublisher<[Character], Error> {
        
        guard page ?? 1 <= maxPages else {
            return Fail(error: CharactersRepositoryError.lastPageReached).eraseToAnyPublisher()
        }
        
        return charactersDS.getCharacters(page: page ?? .defaultPage)
            .map { [weak self] response in
                self?.maxPages = response.info.pages
                return response.results.compactMap{Character(from: $0)}
            }.mapError({ error -> CharactersRepositoryError in
                switch (error as? CharactersDataSourceError) {
                case .badRequest(let message):
                    return .generalError(message: message)
                default:
                    return .generalError(message: "The operation couldn’t be completed. Try again!")
                }
            })
            .eraseToAnyPublisher()
    }
    
    func getCharacters(page: Int?, filterBy name: String) -> AnyPublisher<[Character], Error> {
        guard page ?? 1 <= fileteredMaxPages else {
            return Fail(error: CharactersRepositoryError.lastPageReached).eraseToAnyPublisher()
        }
        
        guard name.isNotEmpty else {
            return Fail(error: CharactersRepositoryError.missingName).eraseToAnyPublisher()
        }
        
        return charactersDS.getCharacters(page: page ?? .defaultPage, filterBy: name)
            .map { [weak self] response in
                self?.fileteredMaxPages = response.info.pages
                return response.results.compactMap{Character(from: $0)}
            }
            .mapError{ error -> CharactersRepositoryError in
                switch (error as? CharactersDataSourceError) {
                case .characterNotFound:
                    return .characterNotFound
                case .badRequest(let message):
                    return .generalError(message: message)
                default:
                    return .generalError(message: "The operation couldn’t be completed. Try again!")
                }
                
            }
            .eraseToAnyPublisher()
    }
}

private extension Character {
    init(from entity: DTOCharacter) {
        self.id = entity.id
        self.name = entity.name
        self.status = .init(rawValue: entity.status) ?? .unknown
        self.species = entity.species
        self.type = entity.type
        self.gender = .init(rawValue: entity.gender) ?? .unknown
        self.origin = entity.origin.name
        self.location = entity.location.name
        self.image = URL(string: entity.image)
    }
}
