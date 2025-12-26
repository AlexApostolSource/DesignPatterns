import Foundation
import Combine
import SwiftUI

protocol PokemonDataImplementor {
	func fetchList(limit: Int, offset: Int) async throws -> [PokemonDomain]
	func fetchDetail(nameOrId: String) async throws -> PokemonDetail
}

@Observable
final class PokemonBrowserViewModel {
	private let dataProvider: PokemonDataImplementor
	private(set) var pokemons: [PokemonDomain] = []
	var pokemonDetail: PokemonDetail?

	init(dataProvider: PokemonDataImplementor) {
		self.dataProvider = dataProvider
	}

	func getPokemons(limit: Int, offset: Int) async {
		do {
			pokemons = try await dataProvider.fetchList(limit: limit, offset: offset)
		} catch {
			print(error)
		}
	}

	func detail(nameOrId: String) async  {
		do {
			self.pokemonDetail = try await dataProvider.fetchDetail(nameOrId: nameOrId)
		}
			catch { print(error)}
		}
}

struct CacheFirstDataImplementor: PokemonDataImplementor {
	let repo: Kata4RepositoryProtocol
	let logger: Kata4LoggerUseCaseProtocol

	init(
		repo: Kata4RepositoryProtocol,
		logger: Kata4LoggerUseCaseProtocol = Kata4LoggerUseCase()
	) {
		self.repo = repo
		self.logger = logger
	}

	func fetchList(limit: Int, offset: Int) async throws -> [PokemonDomain] {
		logger.logEvent(
			.getPokemonList,
			params: [
				"limit": limit,
				"offset": offset
			]
		)
		return try await repo.fetchPokemonsList(limit: limit, offset: offset)
	}
	func fetchDetail(nameOrId: String) async throws -> PokemonDetail {
		logger.logEvent(.getDetail, params: [ "nameOrId": nameOrId])
		return try await repo.fetchDetail(nameOrId: nameOrId)
	}
}


struct RemoteOnlyDataImplementor: PokemonDataImplementor {
	let remoteDataSource: Kata4RemoteDataSourceProtocol
	init(remoteDataSource: Kata4RemoteDataSourceProtocol) {
		self.remoteDataSource = remoteDataSource
	}

	func fetchList(limit: Int, offset: Int) async throws -> [PokemonDomain] {
		let result = try await remoteDataSource.fetchPokemonsList(limit: limit, offset: offset)

		let mappedResult = result.results.map {PokemonResponseMapper.map(from: $0)}
		return mappedResult

	}

	func fetchDetail(nameOrId: String) async throws -> PokemonDetail {
		let result = try await remoteDataSource.fetchDetail(nameOrId: nameOrId)

		return result
	}

}
