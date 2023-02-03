//
//  HttpError.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 30/1/23.
//

import Foundation

public struct HttpError: Error {
    let code: Int
    let message: String?
}
