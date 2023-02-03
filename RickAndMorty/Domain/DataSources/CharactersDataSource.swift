//
//  CharactersDataSource.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 30/1/23.
//

import Combine
import Foundation

private extension String {
    static var name: Self { Configuration.API.Character.Parameters.name }
    static var path: Self { Configuration.API.Character.endpoint }
    static var page: Self { Configuration.API.Character.Parameters.page }
}

enum CharactersDataSourceError: Error {
    case badRequest(message: String)
    case clientNotFound
    case characterNotFound
}

protocol CharactersDataSource {
    func getCharacters(page: Int) -> AnyPublisher<DTOCharactersResponse, Error>
    func getCharacters(page: Int, filterBy name: String) -> AnyPublisher<DTOCharactersResponse, Error>
}

final class CharactersDataSourceImpl: CharactersDataSource {
    
    private var httpClient: HttpClient?
    
    init(client: HttpClient?) {
        self.httpClient = client
    }
    
}

extension CharactersDataSourceImpl {
    func getCharacters(page: Int) -> AnyPublisher<DTOCharactersResponse, Error> {
        
        return httpClient?.make(request: HttpRequest.getAllCharactersRequest(page: page))
        .decode(type: DTOCharactersResponse.self, decoder: JSONDecoder())
        .mapError({ error in
            CharactersDataSourceError.badRequest(message: error.localizedDescription)
        })
        .eraseToAnyPublisher()
        ?? Fail(error: CharactersDataSourceError.clientNotFound).eraseToAnyPublisher()
    }
    
    func getCharacters(page: Int, filterBy name: String) -> AnyPublisher<DTOCharactersResponse, Error> {
        
        return httpClient?.make(request: HttpRequest.getFilteredCharactersRequest(page: page, name: name))
        .decode(type: DTOCharactersResponse.self, decoder: JSONDecoder())
        .mapError({ error in
            switch (error as? HttpError)?.code {
            case 404:
                return CharactersDataSourceError.characterNotFound
            default:

                return CharactersDataSourceError.badRequest(
                    message: (error as? HttpError)?.message ?? "An error ocurred, please try again")
            }
        })
        .eraseToAnyPublisher()
        ?? Fail(error: CharactersDataSourceError.clientNotFound).eraseToAnyPublisher()
    }
}


private extension HttpRequest {
    
    static func getAllCharactersRequest(page: Int) -> Self {
        let url = "\(Configuration.API.baseUrl)\(String.path)"
        let params = [String.page: String(page)]
        return HttpRequest(url: url, method: .GET, parameters: params)
    }
    
    static func getFilteredCharactersRequest(page: Int, name: String) -> Self {
        let url = "\(Configuration.API.baseUrl)\(String.path)"
        let params: [String:String] = [String.name:name, String.page:String(page)]
        return HttpRequest(url: url, method: .GET, parameters: params)
    }
}
