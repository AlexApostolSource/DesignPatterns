//
//  Kata1ViewModel.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 15/9/25.
//

import Combine

struct Kata1ViewModel {
    private let useCase: Kata1GetPostsUseCaseOperarationProtocol
    public var viewSignal: AnyPublisher<[Kata1Post], Error> {
        signalPassthrought.eraseToAnyPublisher()
    }
    private var signalPassthrought: PassthroughSubject<[Kata1Post], Error> = .init()

    init(useCase: Kata1GetPostsUseCaseOperarationProtocol) {
        self.useCase = useCase
    }
}
