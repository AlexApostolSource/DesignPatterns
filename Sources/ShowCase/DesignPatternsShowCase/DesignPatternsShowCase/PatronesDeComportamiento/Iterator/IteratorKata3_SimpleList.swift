//
//  IteratorKata3_SimpleList.swift
//  DesignPatternsShowCase
//
//  Kata de Iterator (punto de partida "malo") — To‑Do List (lista plana).
//  Objetivo: eliminar duplicación, ocultar representación interna y permitir
//  forward, reverse y filtrado con iteradores reales.
//
//  Instrucciones en IteratorKata3_SimpleList.md
//

import Foundation
import Playgrounds

// MARK: - Dominio

enum Priority: String {
	case low, medium, high
}

protocol TaskKataCollection {
	func makeReverseTaskKataIterator() -> ReverseTaskKataIterator
	func makeIterator() -> ForwardTaskKataIterator
	func makeFilteredTaskKataIterator(where predicate: @escaping (TaskKata) -> Bool) -> FilteredTaskKataIterator
	func makeForwardIterator() -> ForwardTaskKataIterator
}

struct TaskKata: CustomStringConvertible, Equatable {
	let title: String
	let priority: Priority
	let done: Bool

	var description: String {
		let status = done ? "✅" : "🟡"
		return "\(status) \(title) [\(priority.rawValue)]"
	}
}

struct ReverseTaskKataIterator: IteratorProtocol {
	private let snapshot: [TaskKata]
	private var index: Int = 0

	init(snapshot: [TaskKata]) {
		self.snapshot = snapshot
	}

	mutating func next() -> TaskKata? {
		guard index < snapshot.count else { return nil }
		defer { index += 1 }
		return snapshot[snapshot.count - 1 - index]
	}
}

struct ForwardTaskKataIterator: IteratorProtocol {
	private let snapshot: [TaskKata]
	private var index: Int = 0

	init(snapshot: [TaskKata]) {
		self.snapshot = snapshot
	}

	mutating func next() -> TaskKata? {
		guard index < snapshot.count else { return nil }
		defer { index += 1 }
		return snapshot[index]
	}
}

struct FilteredTaskKataIterator: IteratorProtocol {
	private let snapshot: [TaskKata]
	private var index: Int = 0

	init(base: [TaskKata], where predicate: @escaping (TaskKata) -> Bool) {
		self.snapshot = base.filter(predicate)
	}

	mutating func next() -> TaskKata? {
		guard index < snapshot.count else { return nil }
		defer { index += 1 }
		return snapshot[index]
	}
}

// MARK: - Código "malo" (sin Iterator)

/// Problemas intencionados:
/// - Duplica bucles (forward, reverse, filtro).
/// - Mezcla algoritmo y presentación (print*).
/// - next() manual con índice obliga al cliente a conocer detalles internos.
/// - Exposición implícita del almacenamiento al tener métodos de recorrido ad‑hoc.
final class TodoListBad: TaskKataCollection, Sequence {
	typealias Element = TaskKata

	private var storage: [TaskKata]

	init(_ TaskKatas: [TaskKata]) {
		self.storage = TaskKatas
	}

	func add(_ TaskKata: TaskKata) {
		storage.append(TaskKata)
	}

	func makeIterator() -> ForwardTaskKataIterator {
		.init(snapshot: storage)
	}

	func makeReverseTaskKataIterator() -> ReverseTaskKataIterator {
		.init(snapshot: storage)
	}

	func makeFilteredTaskKataIterator(where predicate: @escaping (TaskKata) -> Bool) -> FilteredTaskKataIterator {
		.init(base: storage, where: predicate)
	}

	func makeForwardIterator() -> ForwardTaskKataIterator {
		.init(snapshot: storage)
	}
}

// Cliente “malo”: usa métodos ad‑hoc y depende de next() con índice interno
final class TodoConsoleBad {

	func listAll(from list: TodoListBad) {
		print("— All TaskKatas —")
		var it = list.makeForwardIterator()
		while let task = it.next() {
			print(task.description)
		}
	}

	func listReverse(from list: TodoListBad) {
		print("\n— Reverse —")
		var it = list.makeReverseTaskKataIterator()
		while let task = it.next() {
			print(task.description)
		}
	}

	func listByPriority(_ p: Priority, from list: TodoListBad) {
		print("\n— Priority: \(p.rawValue) —")
		var it = list.makeFilteredTaskKataIterator { task in
			task.priority == p
		}
		while let task = it.next() {
			print(task.description)
		}
	}

	func listPendingShuffled(limit: Int? = nil, from list: TodoListBad) {
		print("\n— Pending (shuffled) —")
		var it = list.makeForwardIterator()
		var all: [TaskKata] = []
		while let task = it.next() {
			all.append(task)
		}

		all.shuffle()
		let n = min(limit ?? all.count, all.count)
		for task in all.prefix(n) {
			print(task.description)
		}
	}

	func nextManually(from list: TaskKataCollection) {
		print("\n— Manual index traversal —")
		var it = list.makeForwardIterator()
		let task = it.next()
		print("next: \(task?.description ?? "nil")")
	}
}

// MARK: - TODO (tu trabajo)
// 1) Define una interfaz de Iterator (GoF) y/o adopta Sequence/IteratorProtocol.
// 2) Implementa iteradores concretos: Forward, Reverse y Filtered.
// 3) Cambia TodoListBad -> TodoList para que no exponga recorrido ad‑hoc y ofrezca fábricas de iteradores.
// 4) Refactoriza TodoConsoleBad para depender de iteradores en lugar de métodos print*.
// 5) Mantén el mismo comportamiento observable (mismo output en el #Playground).

// MARK: - Demo (debe seguir funcionando tras el refactor)

#Playground {
	let TaskKatas: [TaskKata] = [
		TaskKata(title: "Buy milk",          priority: .low,    done: false),
		TaskKata(title: "Pay electricity",   priority: .high,   done: false),
		TaskKata(title: "Reply to emails",   priority: .medium, done: true),
		TaskKata(title: "Gym",               priority: .low,    done: false),
		TaskKata(title: "Prepare slides",    priority: .high,   done: true),
		TaskKata(title: "Book flights",      priority: .medium, done: false)
	]

	let list = TodoListBad(TaskKatas)
	let console = TodoConsoleBad()

	console.listAll(from: list)
	console.listReverse(from: list)
	console.listByPriority(.high, from: list)
	console.listPendingShuffled(limit: 3, from: list)
	console.nextManually(from: list)
}
