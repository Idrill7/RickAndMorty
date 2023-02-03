//
//  DTOCharactersResponse.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 31/1/23.
//

import Foundation

struct DTOCharactersResponse: Decodable {
    let info: DTOCharactersInfo
    let results: [DTOCharacter]
}
