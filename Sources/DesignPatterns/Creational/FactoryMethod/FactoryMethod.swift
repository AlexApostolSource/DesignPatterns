//
//  FactoryMethod.swift
//  DesignPatterns
//
//  Created by Alex.personal on 19/8/25.
//

protocol Transport {
    func deliver()
}

struct Truck: Transport {
    func deliver() {
        print("Delivering by land in a box.")
    }
}

struct Ship: Transport {
    func deliver() {
        print("Delivering by sea in a container.")
    }
}

protocol TransportFactory {
    func createTransport() -> Transport
}

struct TruckFactory: TransportFactory {
    func createTransport() -> Transport {
        return Truck()
    }
}

struct ShipFactory: TransportFactory {
    func createTransport() -> Transport {
        return Ship()
    }
}

struct Logistics {
    private let factory: TransportFactory
    private let transport: Transport
    init(factory: TransportFactory) {
        self.factory = factory
        self.transport = factory.createTransport()
    }
    func deliver() {
        transport.deliver()
    }
}

