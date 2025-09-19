//
//  Kata1Analytics.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 18/9/25.
//
import Foundation

protocol Kata1AnalyticsProtocol {
    func postsLoaded(count: Int, page: Int)
    func postsLoadFailed(error: Error, page: Int)
}

struct Kata1AnalyticsStdout: Kata1AnalyticsProtocol {
    public init() {}
    public func postsLoaded(count: Int, page: Int) { print("ANALYTICS posts_loaded count=\(count) page=\(page)") }
    public func postsLoadFailed(error: Error, page: Int) { print("ANALYTICS posts_failed \(error) page=\(page)") }
}

protocol PostsServiceFacadeProtocol {
    func fetch(page: Int) async -> Result<[Kata1Post], Error>
}

struct PostsServiceFacade: PostsServiceFacadeProtocol {
    private let useCase: Kata1GetPostsUseCaseOperarationProtocol
    private let analytics: Kata1AnalyticsProtocol

    public init(useCase: Kata1GetPostsUseCaseOperarationProtocol, analytics: Kata1AnalyticsProtocol) {
        self.useCase = useCase
        self.analytics = analytics
    }

    public func fetch(page: Int) async -> Result<[Kata1Post], Error> {
        do {
            let posts = try await useCase.getPosts(page: page)
            analytics.postsLoaded(count: posts.count, page: page)
            return .success(posts)
        } catch {
            analytics.postsLoadFailed(error: error, page: page)
            return .failure(error)
        }
    }
}
