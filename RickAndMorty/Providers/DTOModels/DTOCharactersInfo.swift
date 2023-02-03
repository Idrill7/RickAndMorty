//
//  DTOCharactersInfo.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 31/1/23.
//

import Foundation

struct DTOCharactersInfo: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
