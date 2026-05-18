//
//  MediatorKata_ChatRoom.swift
//  DesignPatternsShowCase
//
//  Kata de Mediator (punto de partida "malo") — Chat Room.
//  Objetivo: eliminar el acoplamiento directo entre usuarios y centralizar
//  la coordinación (entrega de mensajes, DND, bloqueos, topic) en un Mediator.
//
//  Instrucciones:
//  - Observa el código “malo”: cada usuario conoce a los demás y aplica reglas duplicadas.
//  - Refactoriza a Mediator:
//    1) Define ChatMediator (register/sendPublic/sendPrivate/typing/setTopic/setDND/block).
//    2) Haz que ChatUser no conozca a sus peers; sólo notifique al Mediator.
//    3) Implementa ChatRoomMediator que aplique reglas (DND, bloqueos, permisos admin).
//    4) Mantén el mismo output observable del #Playground.
//
//  Retos extra:
//  - Moderación: filtro de palabras prohibidas centralizado en el Mediator.
//  - Salas múltiples y cambio de sala.
//  - Historial con Memento.
//

import Foundation
import Playgrounds

// MARK: - Código "malo" (sin Mediator)

protocol ChatUserMediatorProtocol {
	func connect(peers: [ChatUserBad])
	func sendPublic(_ text: String, user: ChatUserBad)
	func sendPrivate(_ text: String, to targetName: String, from user: ChatUserBad)
	func startTyping(from user: ChatUserBad)
	func setTopic(_ newTopic: String, from user: ChatUserBad)

}

final class ChatUserMediator: ChatUserMediatorProtocol {
	private var peers: [ChatUserBad] = []

	func connect(peers: [ChatUserBad]) {
		self.peers = peers
	}

	// Duplicación de reglas (bloqueos/DND) en cada operación
	func sendPublic(_ text: String, user: ChatUserBad) {
		for peer in peers {
			if peer.blockedUsers.contains(user.name) {
				print("  -> no entregado a \(peer.name) (bloqueado)")
				continue
			}
			if peer.isDoNotDisturb {
				print("  -> omitido \(peer.name) (DND)")
				continue
			}
			peer.receivePublic(from: user, text: text)
		}
	}

	func sendPrivate(_ text: String, to targetName: String, from user: ChatUserBad) {
		guard let target = peers.first(where: { $0.name == targetName }) else {
			print("  -> destinatario '\(targetName)' no encontrado")
			return
		}
		if target.blockedUsers.contains(user.name) {
			print("  -> no entregado (bloqueado por \(target.name))")
			return
		}
		if target.isDoNotDisturb {
			print("  -> omitido (DND de \(target.name))")
			return
		}
		target.receivePrivate(from: user, text: text)
	}

	func startTyping(from user: ChatUserBad) {
		for peer in peers {
			if peer.isDoNotDisturb { continue }
			peer.showTyping(from: user.name)
		}
	}

	func setTopic(_ newTopic: String, from user: ChatUserBad) {
		if !user.isAdmin {
			print("\(user.name) no es admin; no puede cambiar el topic")
			return
		}
		user.setTopic(newTopic)
		print("\(user.name) cambia el topic a '\(newTopic)'")
		for peer in peers {
			peer.updateTopic(newTopic)
		}
	}
}


final class ChatUserBad: CustomStringConvertible {
	let name: String
	let isAdmin: Bool
	private(set) var isDoNotDisturb: Bool = false
	private(set) var blockedUsers: Set<String> = []
	private(set) var topic: String? = nil
	private let mediator: ChatUserMediatorProtocol

	// Acoplamiento directo: conoce a todos sus peers


	init(name: String, isAdmin: Bool = false, mediator: ChatUserMediatorProtocol) {
		self.name = name
		self.isAdmin = isAdmin
		self.mediator = mediator
	}



	// Duplicación de reglas (bloqueos/DND) en cada operación
	func sendPublic(_ text: String) {
		print("\(name) (public): \(text)")
		mediator.sendPublic(text, user: self)

	}

	func setTopic(topic: String) {
		self.topic = topic
	}

	func sendPrivate(_ text: String, to targetName: String) {
		print("\(name) (private -> \(targetName)): \(text)")
		mediator.sendPrivate(text, to: targetName, from: self)
	}

	func startTyping() {
		print("\(name) está escribiendo…")
		mediator.startTyping(from: self)
	}

	func setTopic(_ newTopic: String) {
		mediator.setTopic(newTopic, from: self)

	}

	func setDoNotDisturb(_ enabled: Bool) {
		isDoNotDisturb = enabled
		print("\(name) DND = \(enabled ? "ON" : "OFF")")
	}

	func blockUser(_ user: String) {
		blockedUsers.insert(user)
		print("\(name) bloquea a \(user)")
	}

	// Recepción/indicadores
	func receivePublic(from sender: ChatUserBad, text: String) {
		print("[\(name)] recibe público de \(sender.name): \(text)")
	}

	func receivePrivate(from sender: ChatUserBad, text: String) {
		print("[\(name)] recibe privado de \(sender.name): \(text)")
	}

	func showTyping(from user: String) {
		print("[\(name)] ve que \(user) está escribiendo…")
	}

	func updateTopic(_ newTopic: String) {
		topic = newTopic
		print("[\(name)] actualiza topic a '\(newTopic)'")
	}

	// Estado
	var description: String {
		"User(name:\(name), admin:\(isAdmin), DND:\(isDoNotDisturb), blocked:\(Array(blockedUsers).sorted()), topic:\(topic ?? "nil"))"
	}
}


// MARK: - TODO (tu trabajo)
// 1) Crea el protocolo de Mediator, p.ej.:
//
//    protocol ChatUserMediatorProtocol {
//        func register(_ user: ChatColleague)
//        func sendPublic(from: ChatColleague, text: String)
//        func sendPrivate(from: ChatColleague, to: String, text: String)
//        func typing(from: ChatColleague, isTyping: Bool)
//        func setTopic(from: ChatColleague, topic: String)
//        func setDND(for user: ChatColleague, enabled: Bool)
//        func block(from: ChatColleague, target: String)
//    }
//
//    protocol ChatUserBad: AnyObject {
//        var name: String { get }
//        func receivePublic(from: String, text: String)
//        func receivePrivate(from: String, text: String)
//        func showTyping(from: String)
//        func updateTopic(_ topic: String)
//    }
//
// 2) Haz que ChatUser (renombrado) no conozca a sus peers ni aplique reglas;
//    solo notifique al Mediator y exponga lo mínimo para actualizar su estado.
// 3) Implementa ChatRoomMediator con las reglas actuales:
//    - No entregar a usuarios con DND activo.
//    - Respetar bloqueos.
//    - Solo admin puede cambiar el topic; todos lo reciben.
// 4) Mantén el mismo comportamiento observable del Playground (mismo output).

// MARK: - Demo (debe seguir funcionando tras el refactor)

#Playground {
	let mediator = ChatUserMediator()
	let alice = ChatUserBad(name: "Alice", isAdmin: true, mediator: mediator)
	let bob   = ChatUserBad(name: "Bob", mediator: mediator)
	let carol = ChatUserBad(name: "Carol", mediator: mediator)

	mediator.connect(peers: [alice, bob, carol])

	print("Escenario 1: Alice escribe y manda saludo público")
	alice.startTyping()
	alice.sendPublic("¡Hola a todos!")

	print("\nEscenario 2: Bob activa DND y Carol le escribe en privado")
	bob.setDoNotDisturb(true)
	carol.sendPrivate("¿Café luego?", to: "Bob")

	print("\nEscenario 3: Alice cambia el topic (es admin)")
	alice.setTopic("Kata Mediator")

	print("\nEscenario 4: Bob bloquea a Alice")
	bob.blockUser("Alice")

	print("\nEscenario 5: Alice intenta escribir privado a Bob")
	alice.sendPrivate("¿Todo bien, Bob?", to: "Bob")

	print("\nEscenario 6: Bob desactiva DND y Carol manda mensaje público")
	bob.setDoNotDisturb(false)
	carol.sendPublic("Listo para la sesión de pairing")

	print("\nEstado final:")
	print(alice.description)
	print(bob.description)
	print(carol.description)
}
