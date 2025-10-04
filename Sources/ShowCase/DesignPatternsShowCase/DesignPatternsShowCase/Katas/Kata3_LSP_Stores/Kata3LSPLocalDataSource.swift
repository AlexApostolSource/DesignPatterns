//
//  Kata3LSPLocalDataSource.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 2/10/25.
//
import Foundation
import CryptoKit

// MARK: - Protocolo Local
protocol BookStoreLocalDataSourceProtocol {
    func cachedEntry(for query: String) async throws -> CacheEntry?
    func save(books: [Book], for query: String) async throws
    func invalidate(query: String) async throws
}

actor BookStoreLocalDataSource: BookStoreLocalDataSourceProtocol {
	struct Constants {
		static let folderName = "BookStoreCache"
	}
    private var memoryCache: [String: CacheEntry] = [:]
    private let dir: URL?
    private let fileManager: FileManager

    init(fileManger: FileManager) {
        self.fileManager = fileManger
        let baseURL = fileManger.urls( for: .cachesDirectory,in: .userDomainMask).first
        dir = baseURL?.appending(path: Constants.folderName, directoryHint: .isDirectory)
    }

    func cachedEntry(for query: String) async throws -> CacheEntry? {
		if let memoryCache = memoryCache[query] {
			return memoryCache
		}

		guard let url = fileURL(forQuery: query) else { return nil }
		guard fileManager.fileExists(atPath: url.path()) else { return nil }

		do {
			let data = try Data(contentsOf: url)
			let entry = try JSONDecoder().decode(CacheEntry.self, from: data)
			guard entry.schemaVersion == CacheEntry.currentSchemaVersion else {
				try fileManager.removeItem(at: url)
				memoryCache[query] = nil
				throw BookStoreError.corruptedCache(underlyingError: nil)
			}

			memoryCache[query] = entry
			return entry

		} catch let error as DecodingError {
			try? fileManager.removeItem(at: url)
			throw BookStoreError.corruptedCache(underlyingError: error)
		} catch {
			throw BookStoreError.errorRetrievingLocalDataSourceEntry(underlyingError: error)
		}
    }

	func invalidate(query: String) async throws {
		memoryCache[query] = nil
		guard let url = fileURL(forQuery: query), fileManager.fileExists(atPath: url.path())
		else {  throw BookStoreError.errorInvalidationCache(underlyingError: nil) }
		do {
			try fileManager.removeItem(at: url)
		} catch {
			throw BookStoreError.errorInvalidationCache(underlyingError: error)
		}
    }

	func save(books: [Book], for query: String) async throws {
		let schema = await CacheEntry.currentSchemaVersion
		let cacheEntry = CacheEntry(
			books: books,
			timestamp: Date(),
			schemaVersion: schema,
		)
		memoryCache[query] = cacheEntry

		guard let url = fileURL(forQuery: query) else {
			throw BookStoreError.cannotCreateEntryURL
		}
		do {
			let data = try JSONEncoder().encode(cacheEntry)
			try data.write(to: url, options: .atomic)
		} catch {
			throw BookStoreError.cannotWriteEntryToUrl(underlyingError: error)
		}
	}

     // MARK: - Helpers
    private func fileURL(forQuery query: String) -> URL? {
        dir?.appendingPathComponent("\(query).json", isDirectory: false)
    }

	private func validateFolder() throws {
		if let dir = dir {
			do {
				try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
			} catch {
				throw BookStoreError.cannotCreateDirectory(underlyingError: error)
			}
		}
	}
}

// MARK: - Entrada de caché
struct CacheEntry: Codable {
    static let currentSchemaVersion = 1

    let books: [Book]
    let timestamp: Date
    let schemaVersion: Int
}
