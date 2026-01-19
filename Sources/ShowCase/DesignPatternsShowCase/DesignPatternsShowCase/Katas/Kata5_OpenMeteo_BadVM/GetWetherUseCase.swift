//
//  GetWetherUseCase.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 8/1/26.
//

protocol GetWetherUseCaseProtocol {
	func getWether(params: GetWetherParams) async throws -> WeatherForecast
}

struct GetWetherUseCase: GetWetherUseCaseProtocol {
	private let remoteDataSource: WetherRemoteDataSourceProtocol

	init(remoteDataSource: WetherRemoteDataSourceProtocol) {
		self.remoteDataSource = remoteDataSource
	}

	func getWether(params: GetWetherParams) async throws -> WeatherForecast {
		let result = try await remoteDataSource.getWether(params: params)
		return result
	}
}
