//
//  Kata1RemoteDataSource.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//

import Foundation
import NetworkLayer

public protocol Kata1RemoteDataSourceProtocol {
    func getPosts(page: Int) async throws -> [JPPost]
}


struct Kata1RemoteDataSource: Kata1RemoteDataSourceProtocol {
    private let requestProvider: RequestProviderProtocol


    init(requestProvider: RequestProviderProtocol) {
        self.requestProvider = requestProvider
    }

    func getPosts(page: Int) async throws -> [JPPost] {
        let endpoint = PostsEndpoint()
        do {
            let posts: [JPPost] = try await requestProvider.execute(endpoint: endpoint)
            return posts
        } catch {
            throw Kata1Errors.requestFailed(underlyingError: error)
        }
    }
}
