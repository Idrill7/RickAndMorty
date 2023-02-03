//
//  HttpClient.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 30/1/23.
//

import Foundation
import Combine

protocol HttpClient {
    func make(request: HttpRequest) -> AnyPublisher<Data, HttpError>
}

final class HttpClientImpl: HttpClient {
    
    func make(request: HttpRequest) -> AnyPublisher<Data, HttpError>{
        
        guard let request = request.urlRequest else {
            return Fail(error: HttpError(code: 400, message: "Bad request")).eraseToAnyPublisher()
        }
        return URLSession
            .DataTaskPublisher(request: request, session: .shared)
            .tryMap { data, response in
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    throw HttpError(code: 400, message: "Bad request")
                }
                switch statusCode {
                case 0...299:
                    return data
                default:
                    throw HttpError(code: statusCode, message: data.utf8)
                }
            }
            .mapError{ error in
                guard let error = error as? HttpError else {
                    return HttpError(code: -1, message: error.localizedDescription)
                }
                return error
            }
            .eraseToAnyPublisher()
    }
    
}

private extension Data {
    var utf8: String {
        String(data: self, encoding: .utf8) ?? ""
    }
}
