//
//  Kata6NetworkAdapter.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 4/2/26.
//

protocol Kata6LaunchDataProviderProtocol {
	func getLaunchData() async throws -> [LaunchDomain]
}

protocol Kata6NetwokProxyProtocol: Kata6LaunchDataProviderProtocol {
	func getLaunchData() async throws -> [LaunchDomain]
}

struct Kata6NetwokProxy: Kata6NetwokProxyProtocol {
	let circuitBreaker = CircuitBreaker(maxFailureCount: 3, resetTime: 30)
	private let remoteDatasource: Kata6RemoteDataSourceProtocol

	init(remoteDatasource: Kata6RemoteDataSourceProtocol) {
		self.remoteDatasource = remoteDatasource
	}

	func getLaunchData() async throws -> [LaunchDomain] {
		try await circuitBreaker.execute {
			async let launchV5 =  remoteDatasource.getLaunchV5()
			async let launchV4 =  remoteDatasource.getLaunchV4()
			let data: [LaunchDomain] =  try await [launchV5, launchV4]
			return data
		}
	}
}
