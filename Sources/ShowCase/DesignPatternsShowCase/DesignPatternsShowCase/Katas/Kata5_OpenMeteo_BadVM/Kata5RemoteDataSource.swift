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
		let endpoint = WetherEndpoint(params: params)
		return try await requestProvider.execute(endpoint: endpoint)
	}
}


struct WetherEndpoint: NetworkLayerEndpoint {
	private let params: GetWetherParams

	init(params: GetWetherParams) {
		self.params = params
	}

	var host: String {
		"api.open-meteo.com"
	}

	var queryItems: [URLQueryItem] {
		return [
			URLQueryItem(name: "latitude", value: "\(params.lat)"),
			URLQueryItem(name: "longitude", value: "\(params.lon)"),
			URLQueryItem(name: "hourly", value: "temperature_2m"),
			URLQueryItem(name: "timeZone", value: params.timeZone),
		]
	}

	var path: String {
		"/v1/forecast"
	}

	var method: NetworkLayer.URLRequestMethod = .GET


}
