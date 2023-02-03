//
//  MainViewModel.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 30/1/23.
//

import Foundation
import Combine

final class MainViewModel: ViewModel {
    
    @Published var data = Data()
    
    lazy var cancellables = Set<AnyCancellable>()
    
    private var charactersCache: [Character] = []
    private var charactersListUC: GetCharactersListUseCase?
    private var listCurrentPage: Int = 1
    private var searchableCurrentPage: Int = 1
    private var lastSearch: String = ""
    
    init(charactersListUC: GetCharactersListUseCase?) {
        self.charactersListUC = charactersListUC
    }
    
    func trigger(_ action: Action) {
        switch action {
        case .getCharacters:
            getCharacters()
        case .searchCharacters(let name) where name.count >= 1:
            searchCharacters(by: name)
        case .searchCharacters:
            lastSearch = ""
            self.data.characters = charactersCache
        }
    }
    
    private func getCharacters() {
        charactersListUC?.execute(page: listCurrentPage)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    switch (error as? GetCharactersListUseCaseError) {
                    case .generalError(let message):
                        self?.data.state.send(.failure(error: .fetchCharactersError(message: message)))
                    case .lastPageReached:
                        self?.data.state.send(.onLimitReached)
                    default:
                        self?.data.state.send(.none)
                    }
                }
            }, receiveValue: { [weak self] value in
                guard let self = self else { return }
                self.listCurrentPage += 1
                self.charactersCache.append(contentsOf: value)
                self.data.characters = self.charactersCache
                self.data.state.send(.onCharactersReceived)
            })
            .store(in: &cancellables)
    }
    
    private func searchCharacters(by name: String) {
        if lastSearch != name {
            searchableCurrentPage = 1
        }
        lastSearch = name
        charactersListUC?.execute(page: searchableCurrentPage, filterBy: name)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    switch (error as? GetCharactersListUseCaseError) {
                    case .generalError(let message):
                        self?.data.characters = []
                        self?.data.state.send(.failure(error: .fetchCharactersError(message: message)))
                    case .characterNotFound:
                        self?.data.state.send(.none)
                        self?.data.characters = []
                    case .lastPageReached:
                        self?.data.state.send(.onLimitReached)
                    default:
                        self?.data.state.send(.none)
                    }
                }
            }, receiveValue: { [weak self] value in
                if self?.searchableCurrentPage == 1 {
                    self?.data.characters = value
                } else {
                    self?.data.characters.append(contentsOf: value)
                }
                self?.searchableCurrentPage += 1
                self?.data.state.send(.onCharactersReceived)
            })
            .store(in: &cancellables)
    }
}

extension MainViewModel {
    struct Data {
        var characters: [Character] = []
        var state = PassthroughSubject<State, Never>()
    }
    
    enum DataError: Equatable {
        case fetchCharactersError(message: String)
        
        var message: String {
            switch self {
            case .fetchCharactersError(let message):
                return message
            }
        }
    }
    
    enum State {
        case failure(error: DataError)
        case onCharactersReceived
        case onLimitReached
        case none
    }
    
    enum Action {
        case getCharacters
        case searchCharacters(name: String)
    }
}
