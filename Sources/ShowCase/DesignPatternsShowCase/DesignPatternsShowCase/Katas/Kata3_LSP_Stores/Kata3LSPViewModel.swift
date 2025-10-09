//
//  Kata3LSPViewModel.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 6/10/25.
//

import Foundation
import Combine

protocol Kata3LSPViewModelProtocol: AnyObject {
	func loadBooks(query: String) async throws
	var driver: Published<Kata3LSPViewModelState>.Publisher { get }
}

enum Kata3LSPViewModelState: Equatable {
	static func == (lhs: Kata3LSPViewModelState, rhs: Kata3LSPViewModelState) -> Bool {
		switch (lhs, rhs) {
			case (.void, .void): return true
			case (.loading, .loading): return true
			case (.loaded, .loaded): return true
			case (.error, .error): return true
			default: return false
		}
	}

	case void
	case loading
	case loaded([Book])
	case error(Error)
}

@MainActor
final class Kata3LSPViewModel: ObservableObject, Kata3LSPViewModelProtocol {
	private let useCase: Kata3BooksUseCaseProtocol
	@Published private var state: Kata3LSPViewModelState = .void
	var driver: Published<Kata3LSPViewModelState>.Publisher { $state }
	private let debouncer: Debouncer = Debouncer(debounceInterval: .milliseconds(300))
	init(useCase: Kata3BooksUseCaseProtocol) {
		self.useCase = useCase
	}

		/// Llama a esto en cada cambio de texto. El propio VM aplica debounce.
	func loadBooks(query: String) async {
		guard !query.isEmpty else { return }
		await debouncer.debounce {@MainActor [weak self] in
			guard let self else { return }
			self.state = .loading
			do {
				let books = try await self.useCase.loadBooks(query: query)
				self.state = .loaded(books)
			} catch {
				self.state = .error(error)
			}
		}
	}
}
