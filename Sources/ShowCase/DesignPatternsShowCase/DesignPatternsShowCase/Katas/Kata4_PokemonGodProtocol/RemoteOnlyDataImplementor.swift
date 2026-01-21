import Foundation

struct RemoteOnlyDataImplementor: PokemonDataImplementor {
	let remoteDataSource: Kata4RemoteDataSourceProtocol
	init(remoteDataSource: Kata4RemoteDataSourceProtocol) {
		self.remoteDataSource = remoteDataSource
	}

	func fetchList(limit: Int, offset: Int) async throws -> [PokemonDomain] {
		let result = try await remoteDataSource.fetchPokemonsList(limit: limit, offset: offset)
		let mappedResult = result.results.map { PokemonResponseMapper.map(from: $0) }
		return mappedResult
	}

	func fetchDetail(nameOrId: String) async throws -> PokemonDetail {
		let result = try await remoteDataSource.fetchDetail(nameOrId: nameOrId)
		return result
	}

	func clearCache() {
		// no op
	}

	func fetchImage(nameOrId: String) async throws -> Data {
		try await remoteDataSource.fetchImage(nameOrId: nameOrId)
	}
}
