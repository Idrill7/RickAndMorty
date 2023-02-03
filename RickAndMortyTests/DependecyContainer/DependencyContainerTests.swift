//
//  DependencyContainerTests.swift
//  RickAndMortyTests
//
//  Created by Alejandro Gonzalez Casado on 30/1/23.
//

import XCTest
@testable import RickAndMorty

final class DependencyContainerTests: XCTestCase {
    var sut: DependecyContainer?
    
    override func setUp() {
        sut = DependecyContainerImplm()
        super.setUp()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
}

extension DependencyContainerTests {
    
    func testDependencyContainerRegisterAsSingleton() {
        //GIVE
        let instance = InstanceSingletonMock(id: "SingletonMock")
        //WHEN
        sut!.registerAsSingleton(InstanceSingletonMock.self, service: instance)
        //THEN
        XCTAssertNotNil(sut!.resolve(InstanceSingletonMock.self))
    }
    
    func testDependencyContainerRegisterAsEphemeral() {

        //WHEN
        sut!.registerAsEphemeral(InstanceEphemeralMock.self) {
            InstanceEphemeralMock(id: "SingletonMock")
        }
        //THEN
        XCTAssertNotNil(sut!.resolve(InstanceEphemeralMock.self))
    }
    
    func testDependencyContainerSingletonInstances() {
        //GIVE
        let instance = InstanceSingletonMock(id: "SingletonMock\(Int.random(in: 0...Int.max))")
        sut!.registerAsSingleton(InstanceSingletonMock.self, service: instance)
        //WHEN
        let instance1 = sut!.resolve(InstanceSingletonMock.self)
        let instance2 = sut!.resolve(InstanceSingletonMock.self)
        //THEN
        XCTAssertEqual(instance1?.id, instance2?.id)
    }
    
    func testDependencyContainerEphemeralInstances() {
        //GIVE
        sut!.registerAsEphemeral(InstanceEphemeralMock.self) {
            InstanceEphemeralMock(id: "EphemeralMock\(Int.random(in: 0...Int.max))")
        }
        //WHEN
        let instance1 = sut!.resolve(InstanceEphemeralMock.self)
        let instance2 = sut!.resolve(InstanceEphemeralMock.self)
        //THEN
        XCTAssertNotEqual(instance1?.id, instance2?.id)
    }
    
    func testDependencyContainerResolveSuccess() {
        //GIVE
        let instance = InstanceSingletonMock(id: "SingletonMock")
        sut!.registerAsSingleton(InstanceSingletonMock.self, service: instance)
        //WHEN
        let resolvedInstance = sut!.resolve(InstanceSingletonMock.self)
        //THEN
        XCTAssertNotNil(resolvedInstance)
    }
    
    func testDependencyContainerResolveFailed() {
        //GIVE
        let resolvedInstance = sut!.resolve(InstanceEphemeralMock.self)
        //THEN
        XCTAssertNil(resolvedInstance)
    }
}

//MARK: Instance Mocks

private class InstanceSingletonMock {
    let id: String
    
    init(id: String) {
        self.id = id
    }
}

private class InstanceEphemeralMock {
    let id: String
    
    init(id: String) {
        self.id = id
    }
}
