//
//  Kata4Repository.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 6/11/25.
//

struct Kata4Repository: Kata4RepositoryProtocol {
	private let remoteDataSource: Kata4RemoteDataSourceProtocol
	private let localDataSource: Kata4LocalDataSourceProtocol

	init(remoteDataSource: Kata4RemoteDataSourceProtocol, localDataSource: Kata4LocalDataSourceProtocol) {
		self.remoteDataSource = remoteDataSource
		self.localDataSource = localDataSource
	}

	func fetchPokemonsList(limit: Int, offset: Int) async throws -> [PokemonDomain] {
		if let cachedData = localDataSource.fetchList(limit: limit, offset: offset), !cachedData.isEmpty {
			return cachedData
		} else {
			let result = try await remoteDataSource.fetchPokemonsList(limit: limit, offset: offset)
			let mappedResult = result.results.map { PokemonResponseMapper.map(from: $0) }
			localDataSource.saveList(mappedResult)
			return mappedResult
		}
	}

	func fetchDetail(nameOrId: String) async throws -> PokemonDetail {
		if let cachedData = localDataSource.getDetail(nameOrId: nameOrId) {
			return cachedData
		} else {
			let result = try await remoteDataSource.fetchDetail(nameOrId: nameOrId)
			localDataSource.saveDetail(nameOrId: nameOrId, detail: result)
			return result
		}
	}

	func clearCache() {
		localDataSource.clearCache()
	}

	func cacheSize() -> Int {
		localDataSource.currentCacheSize()
	}
}
