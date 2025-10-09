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
	private var searchTask: Task<[Book], Error>?
	private let debounceInterval: Duration = .milliseconds(300)
	private var debounceTask: Task<Void, Never>?
	init(useCase: Kata3BooksUseCaseProtocol) {
		self.useCase = useCase
	}

		/// Llama a esto en cada cambio de texto. El propio VM aplica debounce.
	func loadBooks(query: String) async {
		guard !query.isEmpty else { return }
			// Cancela el timer anterior (nuevo input)
		debounceTask?.cancel()

			// Programa un nuevo "timer" async
		debounceTask = Task { [weak self] in
			guard let self else { return }
			do {
				print("[alex] Nuevo input - comenzando espera [\(query)]")
				try await Task.sleep(for: debounceInterval)   // espera periodo de silencio
				print("[alex] Nuevo input - listo para buscar [\(query)]")
			} catch {
					print("[alex] cancelado por nuevo input mientras esperaba [\(query)]")
				return
			}

				// Cancelar la petición anterior si seguía en vuelo
			self.searchTask?.cancel()

				// Estado de carga
			self.state = .loading

				// Lanza la búsqueda
			let task = Task { try await self.useCase.loadBooks(query: query) }
			self.searchTask = task

			do {
				let books = try await task.value
				guard !Task.isCancelled else { return }
				print("[alex] Resultado de búsqueda listo [\(query)]")
				self.state = .loaded(books)
			} catch is CancellationError {
				print("[alex] Búsqueda cancelada [\(query)]")
			} catch {
				self.state = .error(error)
			}
		}
	}
}
