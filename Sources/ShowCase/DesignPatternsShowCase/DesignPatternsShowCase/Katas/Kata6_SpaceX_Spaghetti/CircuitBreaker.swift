//
//  CircuitBreaker.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 28/1/26.
//

import Foundation
actor CircuitBreaker {
	private var failureCount: Int = 0
	private let maxFailureCount: Int
	private var currentState: State = .closed

	enum State {
		case closed
		case open
		case halfOpen
	}

	init(maxFailureCount: Int) {
		self.maxFailureCount = maxFailureCount
	}

	func execute<T>(operation: @escaping() throws -> T) async throws -> T {
		if currentState == .open {
			throw URLError(.unknown)
		}
		do {
			let result = try operation()
			self.currentState = .closed
			self.failureCount = 0
			return result
		} catch {
			self.failureCount += 1
			if failureCount >= maxFailureCount {
				self.currentState = .open
				throw error
			}
		}
		throw URLError(.unknown)
	}

}
