//
//  Untitled.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 15/9/25.
//

protocol Kata1GetPostsUseCaseOperarationProtocol {
    func getPosts(page: Int) async throws -> [JPPost]
}

struct Kata1GetPostsUseCaseOperaration {
    private let repository: Kata1Repository
    private let mapper: Kata1GetPostsUseCaseOperarationMapperProtocol

    init(repository: Kata1Repository, mapper: Kata1GetPostsUseCaseOperarationMapperProtocol) {
        self.repository = repository
        self.mapper = mapper
    }

    func getPosts(page: Int) async throws -> [Kata1Post] {
        return mapper.map(try await repository.getPosts(page: page))
    }
}

protocol Kata1GetPostsUseCaseOperarationMapperProtocol {
    func map(_ posts: [JPPost]) -> [Kata1Post]
}

struct Kata1GetPostsUseCaseOperarationMapper: Kata1GetPostsUseCaseOperarationMapperProtocol {
    func map(_ posts: [JPPost]) -> [Kata1Post] {
        return posts.map { post in
            Kata1Post(
                id: post.id,
                title: post.title,
                body: post.body
            )
        }
    }
}

struct Kata1Post {
    public let id: Int
    public let title: String
    public let body: String
}
