//
//  Kata4RemoteDataSource.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 4/11/25.
//

import Foundation
import NetworkLayer

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
