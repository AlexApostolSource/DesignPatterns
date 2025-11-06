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
	func fetchDetail(nameOrId: String) async throws -> RemotePokemon
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

	func fetchDetail(nameOrId: String) async throws -> RemotePokemon {
		let endpoint = Kata4PokemonDetailEndpoint(nameOrId: nameOrId)
		let result: RemotePokemon = try await requestProvider.execute(endpoint: endpoint)
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
		"v2/pokemon/\(nameOrId)"
	}

	var host: String = "https://pokeapi.co/api"

	var method: NetworkLayer.URLRequestMethod = .GET


}

struct Kata4EPokemonListEndpoint: NetworkLayerEndpoint {
	var queryItems: [URLQueryItem] {
		[URLQueryItem(name: Constants.limit, value: "\(limit)"),
		 URLQueryItem(name: Constants.offset, value: "\(offset)")
		]
	}

	var path: String = "v2/pokemon"

	var host: String = "https://pokeapi.co/api"

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

struct PokemonDomain {
	let name: String
	let url: String
}
