//
//  AppAssembler.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 1/2/23.
//

import Foundation

protocol AppAssembler {
    func assemble()
    var container: DependecyContainer? { get }
}

public final class AppAssemblerImpl: AppAssembler {
    
    init(container: DependecyContainer = DependecyContainerImplm()) {
        self.container = container
    }
    private(set) var container: DependecyContainer?
    
    func assemble() {
        registerClients()
        registerRepositories()
        registerUseCases()
    }
    
    private func registerClients() {
        container?.registerAsSingleton(HttpClient.self, service: HttpClientImpl())
    }
    
    private func registerRepositories() {
        container?.registerAsEphemeral(CharactersRepository.self, closure: { [weak self] in
            CharactersRepositoryImplm(
                charactersDS: CharactersDataSourceImpl(client: self?.container?.resolve(HttpClient.self)))
        })
    }
    
    private func registerUseCases() {
        container?.registerAsEphemeral(GetCharactersListUseCase.self, closure: { [weak self] in
            GetCharactersListUseCaseImplm(repository:
                                            self?.container?.resolve(CharactersRepository.self))
        })

    }
}
