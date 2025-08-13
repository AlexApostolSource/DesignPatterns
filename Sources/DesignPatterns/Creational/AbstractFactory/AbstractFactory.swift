//
//  DesignPatterns.swift
//  DesignPatterns
//
//  Created by Alex.personal on 13/8/25.
//

import Foundation

///
/// Abstract Factory define un contrato para crear familias de objetos relacionados (las “piezas”), sin exponer sus clases concretas. Luego, el cliente (no la fábrica) ensambla esas piezas para construir el objeto/agregado mayor. Cambiando la fábrica concreta cambias toda la variante de la familia sin tocar el cliente.
///

protocol Machine {
   var name: String { get}
}

protocol Room {
    var machines: [Machine] { get set}
}

struct WeightRoom: Room {
    var machines: [any Machine] = []
}

struct CardioWeightRoom: Room {
    var machines: [Machine] = []
}

// Familias concretas
// Sí. En tu diseño, las fábricas concretas son StandardGymFactory y PremiumGymFactory
final class StandardGymFactory: GymFactory {
    func makeCardioRoom() -> Room { CardioWeightRoom() }
    func makeWeightsRoom() -> Room { WeightRoom() }
    func makeExerciseMachine() -> Machine { ExerciseMachine(name: "Treadmill") }
    func makeWeightMachine() -> Machine { WeightMachine(name: "Bench Press") }
}

final class PremiumGymFactory: GymFactory {
    func makeCardioRoom() -> Room { CardioWeightRoom() }
    func makeWeightsRoom() -> Room { WeightRoom() }
    func makeExerciseMachine() -> Machine { ExerciseMachine(name: "Assault Runner") }
    func makeWeightMachine() -> Machine { WeightMachine(name: "Competition Bench") }
}

struct ExerciseMachine: Machine {
    var name: String
}

struct WeightMachine: Machine {
    var name: String
}

// Abstract Factory
protocol GymFactory {
    func makeCardioRoom() -> Room
    func makeWeightsRoom() -> Room
    func makeExerciseMachine() -> Machine
    func makeWeightMachine() -> Machine
}

final class Gym {
    private(set) var rooms: [Room] = []
    func add(_ room: Room) { rooms.append(room) }
}

final class GymAssembler {
    func makeSynergym(using factory: GymFactory) -> Gym {
        let gym = Gym()
        var cardio  = factory.makeCardioRoom()
        var weights = factory.makeWeightsRoom()

        cardio.machines  = [factory.makeExerciseMachine(), factory.makeExerciseMachine()]
        weights.machines = [factory.makeWeightMachine(),   factory.makeWeightMachine()]

        gym.add(cardio)
        gym.add(weights)
        return gym
    }
}

// Uso
nonisolated(unsafe) let standard = GymAssembler().makeSynergym(
    using: StandardGymFactory()
)
nonisolated(unsafe) let premium  = GymAssembler().makeSynergym(
    using: PremiumGymFactory()
)
