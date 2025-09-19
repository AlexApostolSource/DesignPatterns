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
    func viewDidLoad()
    func getPosts() async throws
    var driver: AnyPublisher<Kata1ViewModelState, Never> { get }
}

import Combine

@MainActor
final class Kata1ViewModel: Kata1ViewModelProtocol {
    private let facade: PostsServiceFacadeProtocol
    private let pageSize = 20
    private var currentPage = 1

    private let subject = CurrentValueSubject<Kata1ViewModelState, Never>(.void)
    var driver: AnyPublisher<Kata1ViewModelState, Never> { subject.eraseToAnyPublisher() }

    init(facade: PostsServiceFacadeProtocol) {
        self.facade = facade
    }

    func viewDidLoad() { subject.send(.void) }

    func getPosts() async throws {
        subject.send(.loading)
        let result = await facade.fetch(page: currentPage)
        switch result {
        case .success(let posts):
            subject.send(.success(posts))
            currentPage += 1
        case .failure(let error):
            subject.send(.failure(error))
        }
    }
}
