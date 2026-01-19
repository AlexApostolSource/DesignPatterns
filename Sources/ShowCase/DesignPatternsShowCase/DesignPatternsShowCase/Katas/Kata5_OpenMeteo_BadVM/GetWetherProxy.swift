//
//  GetWetherProxy.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 19/1/26.
//

import Foundation

protocol GetWetherProxyProtocol {
	func getWether(params: GetWetherParams) async throws -> WeatherForecast
}

struct Kata5CacheManager {
	static let cache:  NSCache<NSString, WetherForecastClassWrapper> = {
		return .init()
	}()
}

struct GetWetherProxy: WetherRemoteDataSourceProtocol {
	private let cache = Kata5CacheManager.cache
	private let remoteDataSource: WetherRemoteDataSourceProtocol
	private let logger: KataLogger

	init(remoteDataSource: WetherRemoteDataSourceProtocol, logger: KataLogger = KataLogger(subsystem: "kata5Proxy", category: "kata5")) {
		self.remoteDataSource = remoteDataSource
		self.logger = logger
	}

	func getWether(params: GetWetherParams) async throws -> WeatherForecast {
		let key = NSString(string: "lat: \(params.lat) lon: \(params.lon)")
		if let cache = cache.object(forKey: key) {
			logger.log(level: .info, message: "hitting cache")
			return cache.wetherForecast
		} else {
			let result = try await remoteDataSource.getWether(params: params)
			logger.log(level: .info, message: "hitting remote")
			cache.setObject(WetherForecastClassWrapper(wetherForecast: result), forKey: key)
			return result
		}
	}
}

final class WetherForecastClassWrapper {
	let wetherForecast: WeatherForecast
	init(wetherForecast: WeatherForecast) {
		self.wetherForecast = wetherForecast
	}
}
