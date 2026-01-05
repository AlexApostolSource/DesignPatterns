//
//  Kata4RemoteDataSource.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 4/11/25.
//
import Foundation
import NetworkLayer

protocol Kata4RemoteDataSourceProtocol {
	func fetchPokemonsList(limit: Int, offset: Int) async throws -> PokemonsResponse
	func fetchDetail(nameOrId: String) async throws -> PokemonDetail
	func fetchImage(nameOrId: String) async throws -> Data
}

struct Kata4RemoteDataSource: Kata4RemoteDataSourceProtocol {
	private let requestProvider: RequestProviderProtocol

	init(requestProvider: RequestProviderProtocol) {
		self.requestProvider = requestProvider
	}

	func fetchPokemonsList(limit: Int, offset: Int) async throws -> PokemonsResponse {
		let endpoint = Kata4EPokemonListEndpoint(limit: limit, offset: offset)
		let result: PokemonsResponse = try await requestProvider.execute(endpoint: endpoint)

		return result
	}

	func fetchDetail(nameOrId: String) async throws -> PokemonDetail {
		let endpoint = Kata4PokemonDetailEndpoint(nameOrId: nameOrId)
		let result: PokemonDetail = try await requestProvider.execute(endpoint: endpoint)
		return result
	}

	func fetchImage(nameOrId: String) async throws -> Data {
		let endpoint = Kata4PokemonImageEndpoint(id: nameOrId)
		let result: Data = try await requestProvider.execute(endpoint: endpoint)
		return result
	}
}

struct Kata4PokemonDetailEndpoint: NetworkLayerEndpoint {
	var queryItems: [URLQueryItem] = []

	private let nameOrId: String
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}

	var path: String  {
		"/api/v2/pokemon/\(nameOrId)"
	}


	var method: NetworkLayer.URLRequestMethod = .GET


}

struct Kata4EPokemonListEndpoint: NetworkLayerEndpoint {
	var queryItems: [URLQueryItem] {
		[URLQueryItem(name: Constants.limit, value: "\(limit)"),
		 URLQueryItem(name: Constants.offset, value: "\(offset)")
		]
	}

	var path: String = "/api/v2/pokemon"

	var method: NetworkLayer.URLRequestMethod = .GET

	struct Constants {
		static let limit = "limit"
		static let offset = "offset"
	}

	private let limit: Int
	private let offset: Int

	init(limit: Int, offset: Int) {
		self.limit = limit
		self.offset = offset
	}
}

struct PokemonsResponse: Codable {
	let results : [RemotePokemon]
}

struct RemotePokemon: Codable {
	let name: String
	let url: String
}

struct PokemonResponseMapper {
	static func map(from remote: RemotePokemon) -> PokemonDomain {
		PokemonDomain(name: remote.name, url: remote.url)
	}
}

struct PokemonDomain: Identifiable {
	let id: String = UUID().uuidString
	let name: String
	let url: String
	var urlID: String? {
		let idString = url.split(separator: "/").last
		return idString?.lowercased()
	}
}

struct PokemonDomainURLIDSanatizer {
	static func sanitize(_ url: String) -> URL? {
		guard let idString = url.split(separator: "/").last,
			  let idInt = Int(idString) else {
			return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(0).png")
		}
		return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(idInt).png")
	}
}



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
