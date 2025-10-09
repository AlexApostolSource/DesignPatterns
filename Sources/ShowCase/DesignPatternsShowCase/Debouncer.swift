//
//  Debouncer.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 9/10/25.
//

import Foundation

typealias DebounceAction = @Sendable () async throws -> Void

actor Debouncer {
	private var debounceActionTask: Task<Void, Error>?
	private let debounceInterval: Duration
	private var debounceTask: Task<Void, Error>?

	init(debounceInterval: Duration) {
		self.debounceInterval = debounceInterval
	}

	public func debounce(action: DebounceAction) async throws {
		debounceTask?.cancel()
			// Programa un nuevo "timer" async
		debounceTask = Task { [weak self] in
			guard let self else { return }
			do {
				print("[alex] Nuevo input - comenzando espera []")
				try await Task.sleep(for: debounceInterval)   // espera periodo de silencio
				print("[alex] Nuevo input - listo para buscar []")
			} catch {
				print("[alex] cancelado por nuevo input mientras esperaba []")
				return
			}

				// Cancelar la petición anterior si seguía en vuelo
			await self.debounceActionTask?.cancel()

				// Estado de carga


				// Lanza la búsqueda
			let task = Task { try await action() }
			 self.debounceActionTask = task
		}
	}
}
