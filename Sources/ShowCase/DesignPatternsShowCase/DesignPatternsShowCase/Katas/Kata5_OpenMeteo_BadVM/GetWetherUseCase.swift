//
//  GetWetherUseCase.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 8/1/26.
//

protocol GetWetherUseCaseProtocol {
	func getWether(params: GetWetherParams) async throws -> WeatherResponse
}

struct GetWetherUseCase: GetWetherUseCaseProtocol {
	private let remoteDataSource: WetherRemoteDataSourceProtocol

	init(remoteDataSource: WetherRemoteDataSourceProtocol) {
		self.remoteDataSource = remoteDataSource
	}

	func getWether(params: GetWetherParams) async throws -> WeatherResponse {
		try await remoteDataSource.getWether(params: params)
	}
}
