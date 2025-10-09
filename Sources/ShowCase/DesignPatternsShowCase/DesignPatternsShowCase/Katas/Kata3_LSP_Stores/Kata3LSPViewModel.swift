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

enum Kata3LSPViewModelState {
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
	init(useCase: Kata3BooksUseCaseProtocol) {
		self.useCase = useCase
	}

	func loadBooks(query: String) async throws {
		self.state = .loading
		do {
			let books = try await self.useCase.loadBooks(query: query)
			self.state = .loaded(books)
		} catch {
			self.state = .error(error)
		}
	}
}
