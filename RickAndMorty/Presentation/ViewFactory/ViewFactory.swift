//
//  ViewFactory.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 30/1/23.
//

import SwiftUI

struct ViewFactoryKey: EnvironmentKey {
    static let defaultValue: ViewFactory = .init()
}

public extension EnvironmentValues {
    var viewFactory: ViewFactory {self[ViewFactoryKey.self]}
}

public struct ViewFactory {
    
    var injector: InjectorProtocol { Injector.shared }
    
    func makeMainView() -> some View {
        MainView(viewModel: AnyViewModel<MainViewModel.Data, MainViewModel.Action>(
            MainViewModel(charactersListUC: injector.get(GetCharactersListUseCase.self))))
    }
    
    func makeDetailViewWith(_ character: Character) -> some View {
        CharacterDetailView(character: character)
    }
}

