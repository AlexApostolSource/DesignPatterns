//
//  Kata4Rate-limitProxy.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 9/2/26.
//

import Foundation
import NetworkLayer
import NLCore

protocol Kata6RateProxyProtocol {
	func getLaunchData() async throws -> [LaunchDomain]
}

struct Kata6RateProxy: Kata6RateProxyProtocol {
	private let remoteDataSource: Kata6RemoteDataSourceProtocol
	private let kata6NetworkProxy: Kata6NetwokProxyProtocol

	init(remoteDataSource: Kata6RemoteDataSourceProtocol, kata6NetworkProxy: Kata6NetwokProxyProtocol) {
		self.remoteDataSource = remoteDataSource
		self.kata6NetworkProxy = kata6NetworkProxy
	}

	func getLaunchData() async throws -> [LaunchDomain] {
		let launch4RawRequest = try await remoteDataSource.getLaunchV4Raw()
		let hasRateLimit = launch4RawRequest.response?.allHeaderFields.contains { key, _ in
			key as? String == "Retry-After"
		} ?? false

		if hasRateLimit {
			if let retryAfter = launch4RawRequest.response?.allHeaderFields["Retry-After"] as? Int {
				// Retry-After suele venir en segundos -> convertir a nanosegundos
				try await Task.sleep(nanoseconds: UInt64(retryAfter) * 1_000_000_000)
				return try await getLaunchData()
			}
		}

		// Si no hay rate limit (o no se pudo parsear), pide los datos al proxy subyacente
		return try await kata6NetworkProxy.getLaunchData()
	}
}
