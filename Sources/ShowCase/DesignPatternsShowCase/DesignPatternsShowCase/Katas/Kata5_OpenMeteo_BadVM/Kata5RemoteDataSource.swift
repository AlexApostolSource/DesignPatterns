//
//  Kata5RemoteDataSource.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 8/1/26.
//
import NetworkLayer
import Foundation

protocol WetherRemoteDataSourceProtocol {
	func getWether(params: GetWetherParams) async throws -> WeatherResponse
}

struct GetWetherParams {
	let timeZone: String
	let lat: Double
	let lon: Double
}

struct Kata5Factory {
	static func makeRemoteDataSource() -> WetherRemoteDataSource {
		let requestProvider = RequestProvider.basic
		let dataSource = WetherRemoteDataSource(requestProvider: requestProvider)
		return dataSource
	}

	static func makeView() -> WeatherBadView {
		let dataSource = makeRemoteDataSource()
		let getWetherUseCase = GetWetherUseCase(remoteDataSource: dataSource)
		let viewModel = WeatherViewModelBad(getWetherUseCase: getWetherUseCase)
		let view = WeatherBadView(vm: viewModel)
		return view
	}
}


struct WetherRemoteDataSource: WetherRemoteDataSourceProtocol {
	private let requestProvider: RequestProviderProtocol
	init(requestProvider: RequestProviderProtocol) {
		self.requestProvider = requestProvider
	}

	func getWether(params: GetWetherParams) async throws -> WeatherResponse {
		var builder = WetherEndpointBuilder().setLatitude(params.lat).setLongitude(params.lon).setTimeZone(params.timeZone)

		let endpoint = try builder.build()
		return try await requestProvider.execute(endpoint: endpoint)
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
