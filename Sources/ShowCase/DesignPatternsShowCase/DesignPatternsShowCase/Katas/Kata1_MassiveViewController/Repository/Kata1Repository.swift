//
//  Kata1Repository.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//

protocol Kata1RepositoryProtocol {
    func getPosts(page: Int) async throws -> [JPPost]
}

public struct Kata1Repository {
    private let remoteDataSource: Kata1RemoteDataSourceProtocol
    private let localDataSource: Kata1LocalDataSourceProtocol

    init(
        remoteDataSource: Kata1RemoteDataSourceProtocol,
        localDataSource: Kata1LocalDataSourceProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func getPosts(page: Int) async throws -> [JPPost] {
        do {
            return try await localDataSource.getPosts(page: page)
        } catch {
            do {
                let posts = try await remoteDataSource.getPosts(page: page)
                try await localDataSource.savePosts(posts)
                return posts
            } catch {
                throw  Kata1Errors
                    .failedFetchingRemoteDataSourcePosts(underlyingError: error)
            }
        }
    }
}
