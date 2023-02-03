//
//  HttpRequest.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 30/1/23.
//

import Foundation

public enum HttpMethod: String {
    case DELETE
    case GET
    case POST
    case PUT
}

struct HttpRequest {
    let url: String
    let method: HttpMethod
    let headers: [String:String]
    let parameters: [String:String]
    let body: Data?
    let timeout: TimeInterval
    
    
    init(url: String,
         method: HttpMethod,
         headers: [String : String] = [:],
         parameters: [String : String] = [:],
         body: Data? = nil,
         timeout: TimeInterval = 10) {
        self.url = url
        self.method = method
        self.headers = headers
        self.parameters = parameters
        self.body = body
        self.timeout = timeout
    }
    
    var urlRequest: URLRequest? {
        
        guard let url = URL(string: url) else { return nil }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if parameters.isNotEmpty {
            let queryItems: [URLQueryItem] = parameters.compactMap {  URLQueryItem(name: $0.key, value: $0.value) }
            var items = urlComponents?.queryItems ?? []
            items.append(contentsOf: queryItems)
            urlComponents?.queryItems = items
        }
        
        var request = URLRequest(url: urlComponents?.url ?? url)
        
        request.timeoutInterval = timeout
        request.httpBody = body
        request.httpMethod = method.rawValue
    
        if headers.isNotEmpty {
            headers.forEach{request.setValue($0.value, forHTTPHeaderField: $0.key)}
        }
        
        return request
    }
}
