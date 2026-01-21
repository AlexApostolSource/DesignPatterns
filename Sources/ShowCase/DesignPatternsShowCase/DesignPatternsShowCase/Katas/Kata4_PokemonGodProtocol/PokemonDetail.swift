//
//  PokemonDetail.swift
//  DesignPatternsShowCase
//

import Foundation

struct PokemonDetail: Decodable, Hashable {
	let id: Int
	let name: String
	private let sprites: SpriteContainer // Privado para forzar el uso de la propiedad limpia

	// Propiedad de conveniencia: Aplana la jerarquía para la Vista
	var officialArtworkURL: URL? {
		URL(string: sprites.other.officialArtwork.frontDefault)
	}

	// Estructuras internas necesarias para la decodificación
	struct SpriteContainer: Decodable {
		let other: OtherSprites
	}

	struct OtherSprites: Decodable {
		let officialArtwork: Artwork

		enum CodingKeys: String, CodingKey {
			case officialArtwork = "official-artwork" // Manejo del guion en el JSON
		}
	}

	struct Artwork: Decodable {
		let frontDefault: String

		enum CodingKeys: String, CodingKey {
			case frontDefault = "front_default"
		}
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (lhs: PokemonDetail, rhs: PokemonDetail) -> Bool {
		lhs.id == rhs.id
	}
}
