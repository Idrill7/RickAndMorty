//
//  RickAndMortyApp.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 30/1/23.
//

import SwiftUI

@main
struct RickAndMortyApp: App {
    
    @Environment(\.viewFactory) var viewFactory
    
    init() {
        Injector.shared.registerDependencies()
    }
    
    var body: some Scene {
        
        WindowGroup {
            viewFactory.makeMainView()
        }
    }
}
