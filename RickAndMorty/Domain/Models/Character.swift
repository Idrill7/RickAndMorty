//
//  Character.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 31/1/23.
//

import Foundation

struct Character: Identifiable, Equatable {
    let id: Int
    let name: String
    let status: Status
    let species: String
    let type: String
    let gender: Gender
    let origin: String
    let location: String
    var image: URL?
    
    enum Status: String {
        case alive = "Alive"
        case dead = "Dead"
        case unknown = "Unknown"
    }
    
    enum Gender: String {
        case male = "Male"
        case female = "Female"
        case genderless = "Genderless"
        case unknown = "Unknown"
    }
}
