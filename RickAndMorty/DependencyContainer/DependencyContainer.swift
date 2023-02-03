//
//  DependencyContainer.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 30/1/23.
//

import Foundation

protocol DependecyContainer {
    func registerAsSingleton<T>(_ type: T.Type, service: T)
    func registerAsEphemeral<T>(_ type: T.Type, closure: @escaping () -> T)
    func resolve<T>(_ type: T.Type) -> T?
}

public final class DependecyContainerImplm: DependecyContainer {
    
    init() {}
    
    private var singletons: [String: Any] = [:]
    private var ephemerals: [String: () -> Any] = [:]
    
    func registerAsSingleton<T>(_ type: T.Type, service: T) {
        let key = String(describing: type)
        singletons[key] = service
    }
    
    func registerAsEphemeral<T>(_ type: T.Type, closure: @escaping () -> T) {
        let key = String(describing: type)
        ephemerals[key] = closure
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        if let singleton = singletons[key] as? T {
            return singleton
        }
        if let ephemeral = ephemerals[key] {
            return ephemeral() as? T
        }
        return nil
    }
    
}
