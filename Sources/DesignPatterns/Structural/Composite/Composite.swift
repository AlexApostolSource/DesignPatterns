//
//  Composite.swift
//  DesignPatterns
//
//  Created by Alex.personal on 28/8/25.
//

protocol Producto {
    func precio() -> Double
}

struct Pedido: Producto {
    var productos: [Producto]
    func precio() -> Double {
        return productos.reduce(0) { $0 + $1.precio() }
    }
}

struct Camisa: Producto {
    private let precioActual: Double = 100.0
    func precio() -> Double {
        return precioActual
    }
}

struct Pantalon: Producto {
    private let precioActual: Double = 100.0
    func precio() -> Double {
        return precioActual
    }
}
