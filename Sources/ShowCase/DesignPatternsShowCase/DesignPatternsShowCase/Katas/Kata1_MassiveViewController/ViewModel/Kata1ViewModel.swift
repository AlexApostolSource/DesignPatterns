//
//  Kata1ViewModel.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 15/9/25.
//

import Combine

enum Kata1ViewModelState {
    case void
    case loading
    case success([Kata1Post])
    case failure(Error)
}

protocol Kata1ViewModelProtocol {
    func getPosts() async throws
    var driver: Published<Kata1ViewModelState>.Publisher{ get }
}

@MainActor
final class Kata1ViewModel: Kata1ViewModelProtocol, ObservableObject {

    private let facade: PostsServiceFacadeProtocol
    private let pageSize = 20
    private var currentPage = 1
    
    @Published private var state: Kata1ViewModelState = .void
    var driver: Published<Kata1ViewModelState>.Publisher { $state }

    init(facade: PostsServiceFacadeProtocol) {
        self.facade = facade
    }

    func getPosts() async throws {
        if case .loading = state { return }
        state = .loading
        let result = await facade.fetch(page: currentPage)
        switch result {
        case .success(let posts):
            state = .success(posts)
            currentPage += 1
        case .failure(let error):
            state = .failure(error)
        }
    }
}
