import Foundation

/*
 Regla práctica

 Si tu caso cumple ≥ 3 de estos puntos, Builder encaja bien:

 (1) Producto con múltiples componentes (algunos opcionales).

 (2) Necesitas orden y validaciones durante la construcción.

 (3) Quieres ocultar el montaje y evitar que el cliente conozca las piezas.

 (4) Prevés múltiples representaciones con el mismo proceso.

 (5) Quieres que el producto final sea inmutable y el builder gestione el estado transitorio.
 */

protocol HouseBuilder {
    func getResult() -> House
    func buildDoors(doors: Int) -> Self
    func buildWindows() -> Self
    func buildRoof() -> Self
    func buildGarage() -> Self
}

struct House {
    var doors: Int = 0
    var windows: Int = 0
    var roof: String = ""
    var garage: Bool = false
}

final class MyAwesomeHouseBuilder: HouseBuilder {
    private var house: House

    init() {
        self.house = House()
    }

    func getResult() -> House {
        return house
    }

    func buildDoors(doors: Int) -> Self {
        if house.roof.isEmpty {
            fatalError("Cannot build doors before building the roof.")
        }
        house.doors = doors
        return self
    }

    func buildWindows() -> Self {
        house.windows = 10
        return self
    }

    func buildRoof() -> Self {
        house.roof = "Gabled"
        return self
    }

    func buildGarage() -> Self {
        house.garage = true
        return self
    }
}


struct HouseDirector {
    private let builder: HouseBuilder

    init(builder: HouseBuilder) {
        self.builder = builder
    }

    func constructHouse() -> House {
        return builder.buildDoors(doors: 2)
            .buildWindows()
            .buildRoof()
            .buildGarage()
            .getResult()
    }
}
