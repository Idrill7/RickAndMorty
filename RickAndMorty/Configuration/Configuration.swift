//
//  Configuration.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 31/1/23.
//

import Foundation

public struct Configuration {
    
    struct API {
        static let baseUrl = "https://rickandmortyapi.com/api"
        
        struct Character {
            static let endpoint = "/character"
            
            struct Parameters {
                static let page = "page"
                static let name = "name"
                static let status = "status"
                static let species = "species"
                static let type = "type"
                static let gender = "gender"
            }
        }
    }
}
