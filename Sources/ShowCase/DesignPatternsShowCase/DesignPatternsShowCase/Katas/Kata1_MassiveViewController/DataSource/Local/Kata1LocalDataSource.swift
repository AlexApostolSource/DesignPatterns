//
//  Kata1LocalDataSource.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//
import Foundation

protocol Kata1LocalDataSourceProtocol {
    func getPosts(page: Int) async throws -> [JPPost]
    func savePosts(_ posts: [JPPost]) async throws
}


public actor Kata1LocalDataSource: Kata1LocalDataSourceProtocol {
    private let fileManager: Kata1LocalDataSourceFileManagerProtocol
    private struct Constants {
        static let postsFileName: String = "jp_posts.json"
    }
    init(fileManager: Kata1LocalDataSourceFileManagerProtocol) {
        self.fileManager = fileManager
    }
    public func getPosts(page: Int) async throws -> [JPPost] {
        do {
            let cacheURL = await cacheURL()
            let data = try Data(contentsOf: cacheURL)
            return try JSONDecoder().decode([JPPost].self, from: data)
        } catch let error as DecodingError {
            throw Kata1Errors.failedDecodingPosts(underlyingError: error)
        } catch {
            throw Kata1Errors.failedReadFromDisk(underlyingError: error)
        }
    }

    func savePosts(_ posts: [JPPost]) async throws {
        do {
            let data = try JSONEncoder().encode(posts)
            let cacheURL = await self.cacheURL()
            try data.write(to: cacheURL, options: .atomic)
        } catch let error as EncodingError {
            throw  Kata1Errors.failedCodingPosts(underlyingError: error)
        } catch {
            throw Kata1Errors.failedWriteToDisk(underlyingError: error)
        }

    }

    private func cacheURL() async -> URL {
        await fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(Constants.postsFileName)
    }
}

public protocol Kata1LocalDataSourceFileManagerProtocol: Sendable {
     func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) async -> [URL]
}
