//
//  Debouncer.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 9/10/25.
//

import Foundation

public typealias DebounceAction = @Sendable () async throws -> Void

public actor Debouncer {
	private var debounceActionTask: Task<Void, Error>?
	private var timerTask: Task<Void, Never>?
	private let interval: Duration

	public init(debounceInterval: Duration) {
		self.interval = debounceInterval
	}

	public func debounce(action: @escaping DebounceAction) {
			// 1) Cancela el timer anterior
		timerTask?.cancel()

			// 2) Programa nuevo timer fuera del actor
		timerTask = Task { [interval, weak self] in
			do {
				print("[alex] Nuevo input - comenzando espera []")
				try await Task.sleep(for: interval)
				print("[alex] Nuevo input - listo para ejecutar []")
				guard let self else { return }
				await self.run(action)
			} catch {
					// Cancelado por nuevo input
				print("[alex] cancelado por nuevo input mientras esperaba []")
				return
			}
		}
	}

	private func run(_ action: @escaping DebounceAction) {
			// Cancela la acción anterior si seguía en vuelo
		debounceActionTask?.cancel()

			// Lanza la nueva acción (puede lanzar internamente)
		debounceActionTask = Task {
			try await action()
		}
	}

	public func cancel() {
		timerTask?.cancel()
		debounceActionTask?.cancel()
		timerTask = nil
		debounceActionTask = nil
	}
}
