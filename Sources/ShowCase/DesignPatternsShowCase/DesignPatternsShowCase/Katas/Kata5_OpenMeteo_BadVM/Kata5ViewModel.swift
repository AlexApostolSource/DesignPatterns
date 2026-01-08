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
	var status: String = "idle"
	private let getWetherUseCase: GetWetherUseCaseProtocol

	init(getWetherUseCase: GetWetherUseCaseProtocol) {
		self.getWetherUseCase = getWetherUseCase
	}

	func newGo(lat: Double, lon: Double) {
		let tz = TimeZone.current.identifier
		Task {
			do {
				let result = try await getWetherUseCase.getWether(params: GetWetherParams(timeZone: tz, lat: lat, lon: lon))
				self.points = result.getFormattedHourlyData()
				self.status = "loaded at \(Date())" // usa Date() directo (mal)
			} catch {
				print(error)
			}

		}
	}

	func load(lat: Double, lon: Double) {
		status = "loading"
		// URL montada a mano (mal) + zona horaria del sistema (no inyectable)


		// Retries manuales con sleep en main thread (mal)
		var attempts = 0
		newGo(lat: lat, lon: lon)
		let tz = TimeZone.current.identifier
		let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&hourly=temperature_2m&timezone=\(tz)"
		guard let url = URL(string: urlStr) else { status = "bad_url"; return }

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
