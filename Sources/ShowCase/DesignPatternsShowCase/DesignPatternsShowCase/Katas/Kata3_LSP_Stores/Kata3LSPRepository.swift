//
//  Kata3LSPRepository.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 3/10/25.
//

import Foundation
import Network

protocol BookStoreRepositoryProtocol {
	func search(query: String) async throws -> [Book]
}

final class BookStoreRepository: BookStoreRepositoryProtocol {
	private let store: BookStoreRemoteDataSourceProtocol
	init(store: BookStoreRemoteDataSourceProtocol) { self.store = store }
	func search(query: String) async throws -> [Book] {
		try await store.search(query: query)
	}
}


final class CachedBookStoreProxy: BookStoreRemoteDataSourceProtocol {
	private let remoteDataSource: BookStoreRemoteDataSourceProtocol
	private let localDataSource: BookStoreLocalDataSourceProtocol
	private let ttl: TimeInterval
	private let now: () -> Date
	private let monitor: NWPathMonitor

	init(
		remoteDataSource: BookStoreRemoteDataSourceProtocol,
		localDataSource: BookStoreLocalDataSourceProtocol,
		ttl: TimeInterval = 3600, // 1h por defecto
		monitor: NWPathMonitor = NWPathMonitor(),
		now: @escaping () -> Date = Date.init
	) {
		self.remoteDataSource = remoteDataSource
		self.localDataSource = localDataSource
		self.ttl = ttl
		self.now = now
		self.monitor = monitor

	}


	func search(query: String) async throws -> [Book] {
			// 1) Intenta leer caché pero no interrumpas si falla
		let cached: CacheEntry?
		do {
			cached = try await localDataSource.cachedEntry(for: query)
		} catch {
				// caché corrupta u otro fallo local → la tratamos como inexistente
				// (tu local ya la borrará)
			cached = nil
		}

			// 2) TTL válido ⇒ devolver
		if let e = cached, now().timeIntervalSince(e.timestamp) < ttl {
			return e.books
		}

			// 3) Intentar remoto
		do {
			let fresh = try await remoteDataSource.search(query: query)
			try await localDataSource.save(books: fresh, for: query)
			return fresh
		} catch let e as URLError {
				// 4) Fallo de red (offline, timeout, DNS...) ⇒ servir caché caducada si existe
			if let stale = cached?.books { return stale }
			throw BookStoreError.networkError(underlyingError: e)
		} catch {
				// 5) Cualquier otro error (500, decoding remoto…) ⇒ servir caché caducada si existe
			if let stale = cached?.books { return stale }
			throw BookStoreError.networkError(underlyingError: error)
		}
	}
}


	// 2) DTOs que coinciden con la API remota
struct OpenLibrarySearchDTO: Decodable {
	let docs: [OpenLibraryBookDTO]
}

struct OpenLibraryBookDTO: Decodable {
	let key: String
	let title: String
	let author_name: [String]?
	let cover_i: Int?
}

	// 3) Adapter: convierte DTO → dominio
struct OpenLibraryMapper {
	static func map(_ dto: OpenLibrarySearchDTO) -> [Book] {
		dto.docs.map { d in
			Book(
				key: d.key,
				title: d.title,
				author_name: d.author_name,
				cover_i: d.cover_i
			)
		}
	}
}
