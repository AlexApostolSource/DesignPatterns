//
//  CORKata1.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 25/2/26.
//

import Foundation

// Models
struct HTTPRequest {
	let hasNetwork: Bool
	let token: String?
	let isPayloadValid: Bool
	let isCached: Bool
}

protocol NetworkRequestHandlerProtocol {
	var next: NetworkRequestHandlerProtocol? { get }
	func handle(request: HTTPRequest)
}

class NetworkRequestHandler {
	let chain: NetworkRequestHandlerProtocol
	// TODO: Refactor this method using the Chain of Responsibility pattern.
	// Create separate handlers for Network, Authentication, Cache, and Payload validation.
	init(chain: NetworkRequestHandlerProtocol) {
		self.chain = chain
	}

	func handle(request: HTTPRequest) {
		chain.handle(request: request)
	}
}


struct NetworkRequestHandlerFactory {
	func make() -> NetworkRequestHandler {
		NetworkRequestHandler(
			chain: AuthenticationHandler(
				with: TokenHandler(
					with: CacheHandler(
						with: PayloadValidationHandler()
					)
				)
			)
		)
	}
}
