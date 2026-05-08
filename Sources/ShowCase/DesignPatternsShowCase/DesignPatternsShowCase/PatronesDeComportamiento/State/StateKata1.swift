//
//  StateKata1.swift
//  DesignPatternsShowCase
//
//  Kata de State (punto de partida "malo" para refactorizar).
//  Objetivo: encapsular el comportamiento por estado y eliminar if/switch dispersos.
//
//  Instrucciones en StateKata1.md
//

import Foundation
import Playgrounds

// MARK: - Dominio

struct MediaItem: CustomStringConvertible, Equatable {
	let title: String
	let artist: String
	let duration: TimeInterval

	var description: String {
		"\"\(title)\" — \(artist)"
	}
}

// MARK: - Código "malo" a refactorizar (sin State)

/// Problemas intencionados:
/// - Duplicación de lógica: en cada acción se comprueba "locked", "lista vacía", etc.
/// - Transiciones de estado con if/switch en cada método.
/// - Mezcla algoritmo y presentación (prints dentro del reproductor).
/// - Cliente acoplado a la API "mala".
final class MediaPlayerBad {

	enum PlayerStateBad: String {
		case stopped, playing, paused, locked
	}

	private var playlist: [MediaItem]
	private var index: Int = 0
	private(set) var state: PlayerStateBad = .stopped

	init(_ items: [MediaItem]) {
		self.playlist = items
	}

	private var isEmpty: Bool { playlist.isEmpty }
	private var current: MediaItem? {
		guard !playlist.isEmpty else { return nil }
		return playlist[index]
	}

	// Mezcla de algoritmo y presentación intencionada para el kata:
	private func printLocked() { print("🔒 Player locked. Ignoring action.") }
	private func printEmpty() { print("⚠️ Empty playlist.") }

	func play() {
		if state == .locked { printLocked(); return }
		if isEmpty { printEmpty(); state = .stopped; return }

		switch state {
		case .playing:
			print("▶️ Already playing: \(current!)")
		case .paused, .stopped:
			state = .playing
			print("▶️ Playing: \(current!)")
		case .locked:
			break
		}
	}

	func pause() {
		if state == .locked { printLocked(); return }
		if isEmpty { printEmpty(); state = .stopped; return }

		switch state {
		case .playing:
			state = .paused
			print("⏸️ Paused: \(current!)")
		case .paused:
			print("⏸️ Already paused: \(current!)")
		case .stopped:
			print("⛔️ Cannot pause while stopped.")
		case .locked:
			break
		}
	}

	func stop() {
		if state == .locked { printLocked(); return }
		switch state {
		case .stopped:
			print("⏹️ Already stopped.")
		case .playing, .paused:
			state = .stopped
			print("⏹️ Stopped.")
		case .locked:
			break
		}
	}

	func next() {
		if state == .locked { printLocked(); return }
		if isEmpty { printEmpty(); state = .stopped; return }

		index = (index + 1) % playlist.count
		print("⏭️ Next -> \(current!)")
		if state == .playing {
			print("▶️ Playing: \(current!)")
		}
	}

	func previous() {
		if state == .locked { printLocked(); return }
		if isEmpty { printEmpty(); state = .stopped; return }

		index = (index - 1 + playlist.count) % playlist.count
		print("⏮️ Previous -> \(current!)")
		if state == .playing {
			print("▶️ Playing: \(current!)")
		}
	}

	func lock() {
		if state == .locked {
			print("🔒 Already locked.")
			return
		}
		state = .locked
		print("🔒 Locked.")
	}

	func unlock() {
		if state != .locked {
			print("🔓 Already unlocked.")
			return
		}
		state = .stopped
		print("🔓 Unlocked (stopped).")
	}
}

// Cliente “malo” (simple invocador)
final class RemoteControlBad {
	private let player: MediaPlayerBad
	init(player: MediaPlayerBad) { self.player = player }

	func pressPlay()    { player.play() }
	func pressPause()   { player.pause() }
	func pressStop()    { player.stop() }
	func pressNext()    { player.next() }
	func pressPrevious(){ player.previous() }
	func pressLock()    { player.lock() }
	func pressUnlock()  { player.unlock() }
}

// MARK: - Demo (debe seguir funcionando tras el refactor)

#Playground {
	let items: [MediaItem] = [
		MediaItem(title: "Everlong",      artist: "Foo Fighters", duration: 250),
		MediaItem(title: "Get Lucky",     artist: "Daft Punk",    duration: 248),
		MediaItem(title: "Imagine",       artist: "John Lennon",  duration: 183)
	]

	let player = MediaPlayerBad(items)
	let remote = RemoteControlBad(player: player)

	print("— State Kata Demo —")
	remote.pressPlay()       // ▶️ Playing: Everlong
	remote.pressNext()       // ⏭️ Next -> Get Lucky + ▶️ Playing: Get Lucky
	remote.pressPause()      // ⏸️ Paused: Get Lucky
	remote.pressNext()       // ⏭️ Next -> Imagine
	remote.pressPlay()       // ▶️ Playing: Imagine
	remote.pressLock()       // 🔒 Locked.
	remote.pressNext()       // 🔒 Player locked. Ignoring action.
	remote.pressUnlock()     // 🔓 Unlocked (stopped).
	remote.pressPlay()       // ▶️ Playing: Imagine
	remote.pressPrevious()   // ⏮️ Previous -> Get Lucky + ▶️ Playing: Get Lucky
	remote.pressStop()       // ⏹️ Stopped.
}
