//
//  ViewModel+AnyViewModel.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 1/2/23.
//

import Foundation
import Combine

protocol ViewModel: ObservableObject where ObjectWillChangePublisher.Output == Void {
    associatedtype Data
    associatedtype Action

    var data: Data { get }
    func trigger(_ action: Action)
}

final class AnyViewModel<Data, Action>: ObservableObject {

    private let wrappedObjectWillChange: () -> AnyPublisher<Void, Never>
    private let wrappedData: () -> Data
    private let wrappedTrigger: (Action) -> Void

    var objectWillChange: AnyPublisher<Void, Never> {
        wrappedObjectWillChange()
    }

    var data: Data {
        wrappedData()
    }

    func trigger(_ action: Action) {
        wrappedTrigger(action)
    }

    init<V: ViewModel>(_ viewModel: V) where V.Data == Data, V.Action == Action {
        self.wrappedObjectWillChange = { viewModel.objectWillChange.eraseToAnyPublisher() }
        self.wrappedData = { viewModel.data }
        self.wrappedTrigger = viewModel.trigger
    }

}
