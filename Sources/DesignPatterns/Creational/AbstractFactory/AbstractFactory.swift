//
//  DesignPatterns.swift
//  DesignPatterns
//
//  Created by Alex.personal on 13/8/25.
//

import Foundation

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

final class SynergymGym {
    let rooms: [Room]

    init(rooms: [Room]) {
        self.rooms = rooms
    }
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
