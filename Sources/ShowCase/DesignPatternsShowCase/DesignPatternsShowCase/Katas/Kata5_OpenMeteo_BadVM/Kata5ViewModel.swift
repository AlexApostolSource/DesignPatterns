//
//  Kata5ViewModel.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 8/1/26.
//
import Combine
import Foundation
import SwiftUI

@Observable
final class WeatherViewModelBad {
	var points: [WeatherResponse.WeatherPoint] = []
	private let getWetherUseCase: GetWetherUseCaseProtocol
	enum State: Equatable {
		static func == (lhs: WeatherViewModelBad.State, rhs: WeatherViewModelBad.State) -> Bool {
			switch (lhs, rhs) {

			case (.void, .void): return true

			case (.loading, .loading): return true

			case (.loaded, .loaded): return true

			case (.error, .error): return true

			default: return false

			}
		}

		case void
		case loading
		case loaded(points: [WeatherResponse.WeatherPoint])
		case error

		var status: String {
			switch self {
			case .void:
				return "void"
			case .loading:
				return "loading"
			case .loaded:
				return "loaded"
			case .error:
				return "error"
			}
		}
	}

	private var _currentState: State = .void
	var currentState: State {
		get {
			logger.log(level: .info, message: "CurrentKata5 ViewModel state: \(_currentState.status)")
			return _currentState
		}

		set {
			_currentState = newValue
		}
	}
	private let clockProvider: ClockProviderProtocol
	private var currentLoadingTask: Task<WeatherResponse, Error>?
	private let logger: KataLoggerProtocol

	init(
		getWetherUseCase: GetWetherUseCaseProtocol,
		clockProvider: ClockProviderProtocol = ClockProvider(),
		logger: KataLoggerProtocol = KataLogger(
			subsystem: "kata4",
			category: "kata4VM"
		)
	) {
		self.getWetherUseCase = getWetherUseCase
		self.clockProvider = clockProvider
		self.logger = logger
	}

	func stringifiedStatus() -> String {
		logger.log(level: .info, message: "CurrentStatus: \(currentState.status)")
		return currentState.status
	}

	func newGo(lat: Double, lon: Double) async {
		guard currentState != .loading else { return }
		self.currentState = .loading
		currentLoadingTask = Task {
			let result = try await getWetherUseCase.getWether(
				params: GetWetherParams(
					timeZone: clockProvider.timeZone,
					lat: lat,
					lon: lon
				)
			)
			return result
		}

		do {
			let result = try await currentLoadingTask?.value
			self.currentState = .loaded(points: result?.getFormattedHourlyData() ?? [])
		} catch {
			self.currentState = .error
			logger.log(level: .error, message: error.localizedDescription)
		}
	}

	func load(lat: Double, lon: Double) async {
		// URL montada a mano (mal) + zona horaria del sistema (no inyectable)


		// Retries manuales con sleep en main thread (mal)
		var attempts = 0
		await newGo(lat: lat, lon: lon)
//		let tz = TimeZone.current.identifier
//		let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&hourly=temperature_2m&timezone=\(tz)"
//		guard let url = URL(string: urlStr) else { status = "bad_url"; return }

		func go() {

			attempts += 1
//			URLSession.shared.dataTask(with: url) { data, _, error in
//				if let error {
//					print("ERR \(error)")
//					if attempts < 3 {
//						// Reintento tosco (mal)
//						DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { go() }
//					} else {
//						Task { @MainActor in self.status = "error" }
//					}
//					return
//				}
//				guard
//					let data,
//					let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//					let hourly = json["hourly"] as? [String: Any],
//					let times = hourly["time"] as? [String],
//					let temps = hourly["temperature_2m"] as? [Double]
//				else { Task { @MainActor in self.status = "parse_error" }; return }
//
//				let merged: [HourPoint] = zip(times, temps).map { HourPoint(time: $0.0, temperature_2m: $0.1) }
//				Task { @MainActor in
////					self.points = merged
//					self.status = "loaded at \(Date())" // usa Date() directo (mal)
//				}
//			}.resume()
		}
		
	}
}
