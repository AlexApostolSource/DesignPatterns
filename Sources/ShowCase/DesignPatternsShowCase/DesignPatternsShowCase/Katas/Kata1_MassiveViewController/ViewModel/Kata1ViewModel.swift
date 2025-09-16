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

struct Kata1ViewModel: Kata1ViewModelProtocol {

    private let useCase: Kata1GetPostsUseCaseOperarationProtocol
    var driver: AnyPublisher<Kata1ViewModelState, Never>  {
        signalPassthrough.eraseToAnyPublisher()
    }
    private var signalPassthrough: PassthroughSubject<Kata1ViewModelState, Never> = .init()

    init(useCase: Kata1GetPostsUseCaseOperarationProtocol) {
        self.useCase = useCase
    }

    func viewDidLoad() {
        signalPassthrough.send(.void)
    }

    func getPosts() async throws {
        signalPassthrough.send( .loading)
        do {
            let posts = try await self.useCase.getPosts(page: 1)
            signalPassthrough.send(.success(posts))
        } catch {
            signalPassthrough.send(.failure(error))
        }
    }
}
