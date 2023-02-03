//
//  Injector.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 1/2/23.
//

import Foundation

protocol InjectorProtocol {
    func get<T>(_ type: T.Type) -> T?
}

public final class Injector: InjectorProtocol {
    
    private init() { }
    public static let shared = Injector()
    private lazy var assembler: AppAssembler = AppAssemblerImpl()
    
    func registerDependencies() {
        assembler.assemble()
    }

    func get<T>(_ type: T.Type) -> T? {
        assembler.container?.resolve(type)
    }
}
