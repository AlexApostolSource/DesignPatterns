//
//  Bridge.swift
//  DesignPatterns
//
//  Created by Alex.personal on 27/8/25.
//

struct Credentials {}
struct UserSession {}
protocol AuthProvider {
    func authenticate(credentials: Credentials) async throws -> UserSession
}

protocol LoginFlow {
    var provider: any AuthProvider { get } // ← aquí vive el “bridge”
    func login(with credentials: Credentials) async throws
}

final class PasswordLoginViewModel: LoginFlow {
    let provider: any AuthProvider
    init(provider: any AuthProvider) { self.provider = provider }

    func login(with credentials: Credentials) async throws {
        // lógica de flujo (validaciones, métricas, etc.)
        _ = try await provider.authenticate(credentials: credentials)
    }
}

final class MagicLinkViewModel: LoginFlow {
    let provider: any AuthProvider
    init(provider: any AuthProvider) { self.provider = provider }
    func login(with credentials: Credentials) async throws { /* idem */ }
}
