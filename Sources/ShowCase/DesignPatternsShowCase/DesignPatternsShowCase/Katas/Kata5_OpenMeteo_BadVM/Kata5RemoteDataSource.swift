//
//  Kata5RemoteDataSource.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 8/1/26.
//
import NetworkLayer
import Foundation

protocol WetherRemoteDataSourceProtocol {
	func getWether(params: GetWetherParams) async throws -> WeatherForecast
}

struct GetWetherParams {
	let timeZone: String
	let lat: Double
	let lon: Double
}

struct Kata5Factory {
	static func makeRemoteDataSource() -> WetherRemoteDataSourceProtocol {
		let requestProvider = RequestProvider.basic
		let dataSource = WetherRemoteDataSource(requestProvider: requestProvider)
		let proxy = GetWetherProxy(remoteDataSource: dataSource)
		return proxy
	}

	static func makeView() -> WeatherBadView {
		let dataSource = makeRemoteDataSource()
		let getWetherUseCase = GetWetherUseCase(remoteDataSource: dataSource)
		let viewModel = WeatherViewModelBad(getWetherUseCase: getWetherUseCase)
		let view = WeatherBadView(vm: viewModel)
		return view
	}
}

actor WetherRetryDecorator {
	private let retries: Int
	private let remoteDataSource: WetherRemoteDataSourceProtocol
	private var currentRetries: Int = 0
	private var initialDelay: TimeInterval

	init(retries: Int, remoteDataSource: WetherRemoteDataSourceProtocol,initialDelay: TimeInterval = 1.0) {
		self.retries = retries
		self.remoteDataSource = remoteDataSource
		self.initialDelay = initialDelay
	}

	func getWether(params: GetWetherParams) async throws  -> WeatherForecast {
		var currentDelay = initialDelay
		for attempt in 1...retries {
			do {
				try Task.checkCancellation()
				return try await remoteDataSource.getWether(params: params)
			} catch {
				guard attempt < retries else {
					throw error
				}
				try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))

				currentDelay *= 2.0
			}
		}
		throw URLError(.unknown)
	}
}

struct WetherRemoteDataSource: WetherRemoteDataSourceProtocol {
	private let requestProvider: RequestProviderProtocol
	init(requestProvider: RequestProviderProtocol) {
		self.requestProvider = requestProvider
	}

	func getWether(params: GetWetherParams) async throws -> WeatherForecast {
		let builder = WetherEndpointBuilder().setLatitude(params.lat).setLongitude(params.lon).setTimeZone(params.timeZone)

		let endpoint = try builder.build()
		let result: WeatherResponse = try await requestProvider.execute(endpoint: endpoint)
		return result.toDomain()
	}
}

struct WetherEndpointBuilder {
	private var timeZone: String?
	private var lat: Double?
	private var lon: Double?

	// Fluent Setters (Granulares -> Esto justifica el patrón Builder)
	func setLatitude(_ lat: Double) -> WetherEndpointBuilder {
		var copy = self
		copy.lat = lat
		return copy
	}

	func setLongitude(_ lon: Double) -> WetherEndpointBuilder {
		var copy = self
		copy.lon = lon
		return copy
	}

	func setTimeZone(_ timeZone: String) -> WetherEndpointBuilder {
		var copy = self
		copy.timeZone = timeZone
		return copy
	}

	func build() throws -> WetherEndpoint {
			guard let lat, let lon, let timeZone else {
				throw WetherEndpointError.noParamsProvided
			}

			let items = [
				URLQueryItem(name: "latitude", value: "\(lat)"),
				URLQueryItem(name: "longitude", value: "\(lon)"),
				URLQueryItem(name: "hourly", value: "temperature_2m"),
				URLQueryItem(name: "timeZone", value: timeZone)
			]

			return WetherEndpoint(queryItems: items)
		}
}


struct WetherEndpoint: NetworkLayerEndpoint {

	init(queryItems: [URLQueryItem]) {
		self.queryItems = queryItems
	}

	var host: String {
		"api.open-meteo.com"
	}

	var queryItems: [URLQueryItem] = []

	var path: String {
		"/v1/forecast"
	}

	var method: NetworkLayer.URLRequestMethod = .GET


}

enum WetherEndpointError: Error {
	case noParamsProvided
}
