//
//  Kata3_LSP_Stores.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//

//
//  Kata3_LSP_Stores.swift
//  Anti-ejemplo para refactorizar (viola LSP, usa herencia con fatalError)
//

import Foundation
import NetworkLayer



struct BookStoreEndpoint: NetworkLayerEndpoint {
    private let query: String
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "q", value: query)
        ]
    }
    var path: String = "search.json"
    var method: NetworkLayer.URLRequestMethod = .GET

    init(query: String) {
        self.query = query
    }
}

protocol BookStoreRemoteDataSourceProtocol {
    func search(query: String) async throws -> [Book]
}

final class BookStoreRemoteDataSource: BookStoreRemoteDataSourceProtocol {
    private let requestProvider: RequestProviderProtocol

    init(requestProvider: RequestProviderProtocol) {
        self.requestProvider = requestProvider
    }

    func search(query: String) async throws -> [Book] {
        let endpoint = BookStoreEndpoint(query: query)
        do {
            let result: OpenLibrarySearchDTO = try await requestProvider.execute(endpoint: endpoint)
			return OpenLibraryMapper.map(result)
        } catch {
            throw BookStoreError.networkError(underlyingError: error)
        }
    }
}


struct Book: Codable {
    let key: String
    let title: String
    let author_name: [String]?
    let cover_i: Int?
}


final class BookStoreRepositoryFactory {
	func make() -> BookStoreRepository {
		let remoteDataSource = BookStoreRemoteDataSource(requestProvider: RequestProvider.basic)
		let localDataSource = BookStoreLocalDataSource(fileManger: FileManager.default)
		let cachedBookStoreProxy = CachedBookStoreProxy(remoteDataSource: remoteDataSource, localDataSource: localDataSource)
		let repo = BookStoreRepository(store: cachedBookStoreProxy)
		return repo
	}
}
