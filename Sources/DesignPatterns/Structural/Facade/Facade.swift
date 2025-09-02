//
//  Facade.swift
//  DesignPatterns
//
//  Created by Alex.personal on 2/9/25.
//

import Foundation

enum AppLoaderState {
    case notLoaded
    case loading
    case loaded
    case errorLoading
}


protocol AppLoader: Sendable {
    func startLoadingIfNeeded() async
    var state: AppLoaderState { get async }
}

protocol AppLoaderInteractor: Sendable {
    func loadApp() async throws
}

final actor AppStateManager: AppLoader {
    var state: AppLoaderState = .notLoaded
    private let interactor: AppLoaderInteractor

    init(state: AppLoaderState, interactor: AppLoaderInteractor) {
        self.state = state
        self.interactor = interactor
    }

    func startLoadingIfNeeded() async {
        guard state == .loading else { return }
        self.state = .loading
        do {
            try await interactor.loadApp()
            self.state = .loaded
        }
        catch {
            self.state = .errorLoading
        }
    }
}

