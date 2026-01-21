import Foundation
import SwiftUI

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

	init(
		dataProvider: PokemonDataImplementor,
		logger: Kata4LoggerUseCaseProtocol = Kata4LoggerUseCase()
	) {
		self.dataProvider = dataProvider
		self.logger = logger
	}

	func getURl(for pokemon: PokemonDomain) -> URL? {
		PokemonDomainURLIDSanatizer.sanitize(pokemon.url)
	}

	func getPokemons(limit: Int, offset: Int) async {
		isLoading = true
		defer { isLoading = false }
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
