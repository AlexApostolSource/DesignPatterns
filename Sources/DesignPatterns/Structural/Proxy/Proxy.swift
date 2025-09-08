//
//  Proxy.swift
//  DesignPatterns
//
//  Created by Alex.personal on 8/9/25.
//

import Foundation

protocol SSEConnectorProtocol: Sendable {
    func connect() async throws -> AsyncStream<String>
}


actor SSEConnector: SSEConnectorProtocol {
    func connect() async throws -> AsyncStream<String> {
        return AsyncStream { continuation in
            continuation.yield("Real connection established")
        }
    }
}

actor SSEConnectorProxy: SSEConnectorProtocol {

    private var realConnector: SSEConnectorProtocol?
    private var connection: Task<AsyncStream<String>, Error>?

    init(
        realConnector: SSEConnectorProtocol? = nil
    ) {
        self.realConnector = realConnector
    }

    func connect() async throws -> AsyncStream<String> {
        if let connection {
            return try await connection.value
        }
        if let realConnector {
            connection = Task {
                return try await realConnector.connect()
            }
            return try await connection!.value
        }
        throw NSError(domain: "SSEConnectorProxy", code: 1, userInfo: [NSLocalizedDescriptionKey: "No real connector set"])
    }
}

