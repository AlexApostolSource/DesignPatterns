import Foundation

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

	func fetchImage(nameOrId: String) async throws -> Data {
		// not implemented
		Data()
	}
}
