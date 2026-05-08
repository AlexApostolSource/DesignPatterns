//
//  IteratorKata1.swift
//  DesignPatternsShowCase
//
//  Kata de Iterator (refactor que aplica GoF/Sequence).
//  Objetivo: ocultar representación interna, permitir múltiples recorridos
//  e iteradores independientes (snapshot).
//
//  Instrucciones en IteratorKata1.md
//

import Foundation
import Playgrounds

// MARK: - Dominio

enum Genre: String {
	case rock, pop, jazz, classical, electronic
}

struct Song: CustomStringConvertible, Equatable {
	let title: String
	let artist: String
	let genre: Genre

	var description: String {
		"\"\(title)\" - \(artist) [\(genre.rawValue)]"
	}
}

// MARK: - Interfaz (GoF + Sequence idiomático)

/// Colección que puede fabricar iteradores concretos (GoF).
protocol SongCollection {
	func makeForwardIterator() -> ForwardSongIterator
	func makeReverseIterator() -> ReverseSongIterator
	func makeFilteredIterator(where predicate: @escaping (Song) -> Bool) -> FilteredSongIterator
}

/// Iterador forward (snapshot) — IteratorProtocol de Swift
struct ForwardSongIterator: IteratorProtocol {
	private let snapshot: [Song]
	private var index: Int = 0

	init(_ base: [Song]) {
		self.snapshot = base
	}

	mutating func next() -> Song? {
		guard index < snapshot.count else { return nil }
		defer { index += 1 }
		return snapshot[index]
	}
}

/// Iterador reverse (snapshot)
struct ReverseSongIterator: IteratorProtocol {
	private let snapshot: [Song]
	private var index: Int

	init(_ base: [Song]) {
		self.snapshot = base
		self.index = base.count - 1
	}

	mutating func next() -> Song? {
		guard index >= 0 else { return nil }
		defer { index -= 1 }
		return snapshot[index]
	}
}

/// Iterador filtrado por predicado (snapshot)
struct FilteredSongIterator: IteratorProtocol {
	private let snapshot: [Song]
	private var index: Int = 0

	init(_ base: [Song], where predicate: @escaping (Song) -> Bool) {
		self.snapshot = base.filter(predicate)
	}

	mutating func next() -> Song? {
		guard index < snapshot.count else { return nil }
		defer { index += 1 }
		return snapshot[index]
	}
}

// MARK: - Colección concreta

/// Playlist que oculta su almacenamiento y fabrica iteradores.
/// Además, adopta Sequence para permitir for-in idiomático (forward por defecto).
final class Playlist: SongCollection, Sequence {
	typealias Element = Song

	private var storage: [Song]

	init(_ songs: [Song] = []) {
		self.storage = songs
	}

	func add(_ song: Song) {
		storage.append(song)
	}

	// Sequence (forward por defecto)
	func makeIterator() -> ForwardSongIterator {
		ForwardSongIterator(storage)
	}

	// GoF: fábricas de iteradores concretos
	func makeForwardIterator() -> ForwardSongIterator {
		ForwardSongIterator(storage)
	}

	func makeReverseIterator() -> ReverseSongIterator {
		ReverseSongIterator(storage)
	}

	func makeFilteredIterator(where predicate: @escaping (Song) -> Bool) -> FilteredSongIterator {
		FilteredSongIterator(storage, where: predicate)
	}
}

// MARK: - Cliente refactorizado (no depende de índices ni del array)

final class DJConsoleBad {

	func playAll(from library: SongCollection) {
		print("— All —")
		var it = library.makeForwardIterator()
		while let song = it.next() {
			print(song.description)
		}
	}

	func playReverse(from library: SongCollection) {
		print("\n— Reverse —")
		var it = library.makeReverseIterator()
		while let song = it.next() {
			print(song.description)
		}
	}

	func playGenre(_ genre: Genre, from library: SongCollection) {
		print("\n— Genre: \(genre.rawValue) —")
		var it = library.makeFilteredIterator(where: { $0.genre == genre })
		while let song = it.next() {
			print(song.description)
		}
	}

	// Ejemplo de uso manual de iterador (sin exponer índices)
	func playNext(library: SongCollection) {
		print("\n— Manual index traversal —")
		var it = library.makeForwardIterator()
		let song = it.next()
		print("\n -next Song: \(song?.description)")
	}

	func playShuffled(limit: Int? = nil, from library: SongCollection) {
		print("\n— Shuffled —")
		// Recorremos con el iterador forward para construir una snapshot local.
		var forward = library.makeForwardIterator()
		var all: [Song] = []
		while let song = forward.next() {
			all.append(song)
		}
		all.shuffle()
		let n = min(limit ?? all.count, all.count)
		for song in all.prefix(n) {
			print(song.description)
		}
	}
}

// MARK: - Demo (debe seguir funcionando tras el refactor)

#Playground {
	let songs: [Song] = [
		Song(title: "Everlong",       artist: "Foo Fighters",  genre: .rock),
		Song(title: "Get Lucky",      artist: "Daft Punk",     genre: .electronic),
		Song(title: "Imagine",        artist: "John Lennon",   genre: .pop),
		Song(title: "Take Five",      artist: "Dave Brubeck",  genre: .jazz),
		Song(title: "Clair de Lune",  artist: "Debussy",       genre: .classical),
		Song(title: "Back in Black",  artist: "AC/DC",         genre: .rock)
	]

	let library = Playlist(songs)
	let console = DJConsoleBad()

	console.playAll(from: library)
	console.playReverse(from: library)
	console.playGenre(.rock, from: library)
	console.playShuffled(limit: 3, from: library)
}
