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
	private let resetTime: TimeInterval

	enum State {
		case closed
		case open(resetTime: Date)
		case halfOpen
	}

	init(maxFailureCount: Int, resetTime: TimeInterval ) {
		self.maxFailureCount = maxFailureCount
		self.resetTime = resetTime
	}

	func execute<T>(operation: @escaping() async throws -> T) async throws -> T {
		if case .open(resetTime: let reset) = currentState {
			if reset.timeIntervalSinceNow >= 0 {
				self.currentState = .halfOpen
			} else {
				throw URLError(.cancelled)
			}
		}
		do {
			let result = try await operation()
			self.currentState = .closed
			self.failureCount = 0
			return result
		} catch {
			self.failureCount += 1
			if failureCount >= maxFailureCount {
				self.currentState = .open(resetTime: Date().addingTimeInterval(resetTime))
				throw error
			}
		}
		throw URLError(.unknown)
	}

}
