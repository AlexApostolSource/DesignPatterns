//
//  Kata3LSPFactory.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 6/10/25.
//
import Foundation
import NetworkLayer

final class BookStoreRepositoryFactory {
	static func make() -> Kata3LSPViewController {
		NetworkLayerConfig.config(host: "openlibrary.org")
		let remoteDataSource = BookStoreRemoteDataSource(requestProvider: RequestProvider.basic)
		let localDataSource = BookStoreLocalDataSource(fileManger: FileManager.default)
		let cachedBookStoreProxy = CachedBookStoreProxy(remoteDataSource: remoteDataSource, localDataSource: localDataSource)
		let repo = BookStoreRepository(store: cachedBookStoreProxy)
		let useCase = Kata3BooksUseCase(repo: repo)
		let viewModel = Kata3LSPViewModel(useCase: useCase)
		let vc = Kata3LSPViewController(viewModel: viewModel)
		return vc
	}
}

protocol Kata3BooksUseCaseProtocol: AnyObject {
	func loadBooks(query: String) async throws -> [Book]
}

final class Kata3BooksUseCase: Kata3BooksUseCaseProtocol {
	private let repo: BookStoreRepositoryProtocol
	init(repo: BookStoreRepositoryProtocol) {
		self.repo = repo
	}

	func loadBooks(query: String) async throws -> [Book] {
		try await repo.search(query: query)
	}
}
