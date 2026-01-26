//
//  Kata6RemoteDataSource.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 22/1/26.
//
import NetworkLayer
import Foundation

struct Kata6Factory {
	static func makeRemoteDataSource() -> Kata6RemoteDataSourceProtocol {
		let requestProvider = RequestProvider.basic
		return Kata6RemoteDataSource(requestProvider: requestProvider)
	}

	static func makeViewModel() -> Kata6ViewModel {
		Kata6ViewModel(remoteDateSource: makeRemoteDataSource())
	}
}

protocol Kata6RemoteDataSourceProtocol {
	func getLaunchV5() async throws -> LaunchDomain
	func getLaunchV4() async throws -> LaunchDomain
}

struct Kata6RemoteDataSource: Kata6RemoteDataSourceProtocol {
	private let requestProvider: RequestProviderProtocol

	init(requestProvider: RequestProviderProtocol) {
		self.requestProvider = requestProvider
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
}

struct Kata6LaunchV5Endpoint: VersionedEndpoint {
	var queryItems: [URLQueryItem] = []

	var path: String {
		"/\(version)/launches/latest"
	}

	var host: String {
		"api.spacexdata.com"
	}

	var method: NetworkLayer.URLRequestMethod = .GET

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

	var method: NetworkLayer.URLRequestMethod = .GET

	var version: String {
		"v4"
	}
}

typealias VersionedEndpoint = NetworkLayerEndpoint & VersionedEndpointProtocol

protocol VersionedEndpointProtocol {
	var version: String { get }
}
