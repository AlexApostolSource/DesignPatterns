//
//  AuthenticationHandler.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 25/2/26.
//

struct PayloadValidationHandler: NetworkRequestHandlerProtocol {
	var next: (any NetworkRequestHandlerProtocol)?

	init(with handler: NetworkRequestHandlerProtocol? = nil) {
		self.next = handler
	}

	func handle(request: HTTPRequest) {
		if request.isPayloadValid {
			print("Executing network request...")
			next?.handle(request: request)
		} else {
			print("Error: Invalid payload.")
		}
		log()

	}
}

struct CacheHandler: NetworkRequestHandlerProtocol {
	var next: (any NetworkRequestHandlerProtocol)?

	init(with handler: NetworkRequestHandlerProtocol? = nil) {
		self.next = handler
	}

	func handle(request: HTTPRequest) {
		if !request.isCached {
			log()
			next?.handle(request: request)
		} else {
			print("Returning cached response.")
		}

	}
}

struct TokenHandler: NetworkRequestHandlerProtocol {
	var next: (any NetworkRequestHandlerProtocol)?

	init(with handler: NetworkRequestHandlerProtocol? = nil) {
		self.next = handler
	}

	func handle(request: HTTPRequest) {
		if let token = request.token, !token.isEmpty {
			log()
			next?.handle(request: request)
		} else {
			print("Error: Unauthorized. Missing token.")
		}

	}
}


struct AuthenticationHandler: NetworkRequestHandlerProtocol {
	var next: (any NetworkRequestHandlerProtocol)?
	
	init(with handler: NetworkRequestHandlerProtocol? = nil) {
		self.next = handler
	}
	
	func handle(request: HTTPRequest) {
		if request.hasNetwork {
			log()
			next?.handle(request: request)
		} else {
			print("Error: No internet connection.")
		}

	}
}

extension NetworkRequestHandlerProtocol {
	func log() {
		print("Handling requestFrom: \(String(describing: Self.self))")
	}
}
