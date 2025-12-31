import Foundation
import Combine
import SwiftUI

protocol PokemonDataImplementor {
	func fetchList(limit: Int, offset: Int) async throws -> [PokemonDomain]
	func fetchDetail(nameOrId: String) async throws -> PokemonDetail
	func clearCache()
}


@Observable
final class PokemonBrowserViewModel {
	private let dataProvider: PokemonDataImplementor
	private(set) var pokemons: [PokemonDomain] = []
	var pokemonDetail: PokemonDetail?
	let logger: Kata4LoggerUseCaseProtocol
	var isLoading: Bool = false
	private var canLoadMore = true
	private let limit = 50
	private enum State {
		case idle
		case loading(task: Task<[PokemonDomain], Error>)
		case loaded
	}
	private var currentState: State = .idle
	@MainActor
	func loadMore() async {
		if case .loading = currentState {
			return
		}

		let task = Task { [weak self] () -> [PokemonDomain] in
			guard let self = self else { return [] }
			let pokemonsResult = try await self.dataProvider.fetchList(limit: self.limit, offset: self.pokemons.count)
			return pokemonsResult
		}
		self.currentState = .loading(task: task)

		do {
			let result = try await task.value
			pokemons += result
			self.currentState = .loaded

		} catch {
			self.currentState = .idle
			print("Load More Error: \(error)")
		}
	}

	init(dataProvider: PokemonDataImplementor, logger: Kata4LoggerUseCaseProtocol = Kata4LoggerUseCase()) {
		self.dataProvider = dataProvider
		self.logger = logger

	}

	func getPokemons(limit: Int, offset: Int) async {
		isLoading = true
		defer {
			isLoading = false
		}
		do {
			pokemons = try await dataProvider.fetchList(limit: limit, offset: offset)
		} catch {
			logger.logEvent(.getPokemonList, params: ["error": error])
		}
	}

	func detail(nameOrId: String) async  {
		do {
			self.pokemonDetail = try await dataProvider.fetchDetail(nameOrId: nameOrId)
		} catch {
			logger.logEvent(.getDetail, params: ["error": error])
		}
	}

	func clearCache() {
		dataProvider.clearCache()
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

	func clearCache() {
		repo.clearCache()
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

	func clearCache() {
		// no op
	}
}
