//
//  Kata6RemoteDataSource.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 22/1/26.
//
import NLCore
import NetworkLayer
import Foundation

struct Kata6Factory {
	static func makeRemoteDataSource() -> Kata6RemoteDataSourceProtocol {
		let nlCore = NetworkLayerCore(session: URLSession.shared)
		let requestProvider = RequestProvider.basic
		return Kata6RemoteDataSource(requestProvider: requestProvider, nlCore: nlCore)
	}

	static func makeViewModel() -> Kata6ViewModel {
		let proxy = Kata6NetwokProxy(remoteDatasource: makeRemoteDataSource())
		return Kata6ViewModel(launchDataProvider: proxy)
	}
}

protocol Kata6RemoteDataSourceProtocol {
	func getLaunchV5() async throws -> LaunchDomain
	func getLaunchV4() async throws -> LaunchDomain
	func getLaunchV5Raw() async throws -> NetworkResponse
	func getLaunchV4Raw() async throws -> NetworkResponse
}

struct Kata6RemoteDataSource: Kata6RemoteDataSourceProtocol {
	private let nlCore: NetworkLayerCoreProtocol
	private let requestProvider: RequestProviderProtocol

	init(requestProvider: RequestProviderProtocol, nlCore: NetworkLayerCoreProtocol) {
		self.requestProvider = requestProvider
		self.nlCore = nlCore
	}

	func getLaunchV5() async throws -> LaunchDomain {
		let endpoint = Kata6LaunchV5Endpoint()
		let result: Launch =  try await requestProvider.execute(endpoint: endpoint)
		return LaunchMapper().map(dto: result)
	}

	func getLaunchV4() async throws -> LaunchDomain {
		let endpoint = Kata6LaunchV4Endpoint()
		let result: Launch =  try await requestProvider.execute(endpoint: endpoint)
		return LaunchMapper().map(dto: result)
	}

	func getLaunchV5Raw() async throws -> NetworkResponse {
		let endpoint = Kata6LaunchV5Endpoint()
		guard let request = endpoint.asURLRequest else {
			throw URLError(.badURL)
		}
		let result = try await nlCore.execute(request: request)
		return result
	}

	func getLaunchV4Raw() async throws -> NetworkResponse {
		let endpoint = Kata6LaunchV4Endpoint()
		guard let request = endpoint.asURLRequest else {
			throw URLError(.badURL)
		}
		let result = try await nlCore.execute(request: request)
		return result
	}
}

struct Kata6LaunchV5Endpoint: VersionedEndpoint {
	var queryItems: [URLQueryItem] = []

	var path: String {
		"/\(version)/launches/latest"
	}

	var host: String {
		"api.spacexdata.com"
	}

	var method: URLRequestMethod = .GET

	var version: String {
		"v5"
	}
}

struct Kata6LaunchV4Endpoint: VersionedEndpoint {
	var queryItems: [URLQueryItem] = []

	var path: String {
		"/\(version)/launches/next"
	}

	var host: String {
		"api.spacexdata.com"
	}

	var method: URLRequestMethod = .GET

	var version: String {
		"v4"
	}
}

typealias VersionedEndpoint = NetworkLayerEndpoint & VersionedEndpointProtocol

protocol VersionedEndpointProtocol {
	var version: String { get }
}
