//
//  Kata5ApiResponse.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 8/1/26.
//

import Foundation

// MARK: - Weather Response Model
/// Represents the top-level structure of the Open-Meteo JSON response.
struct WeatherResponse: Codable {
	let latitude: Double
	let longitude: Double
	let generationTimeMs: Double
	let utcOffsetSeconds: Int
	let timezone: String
	let timezoneAbbreviation: String
	let elevation: Double
	let hourlyUnits: HourlyUnits
	let hourly: HourlyData

	// Mapping snake_case JSON keys to camelCase Swift properties.
	enum CodingKeys: String, CodingKey {
		case latitude, longitude, timezone, elevation, hourly
		case generationTimeMs = "generationtime_ms"
		case utcOffsetSeconds = "utc_offset_seconds"
		case timezoneAbbreviation = "timezone_abbreviation"
		case hourlyUnits = "hourly_units"
	}
}

// MARK: - Hourly Units
/// definitions of units used in the hourly data.
struct HourlyUnits: Codable {
	let time: String
	let temperature2m: String

	enum CodingKeys: String, CodingKey {
		case time
		case temperature2m = "temperature_2m"
	}
}

// MARK: - Hourly Data (Raw Columns)
/// Represents the raw parallel arrays from the JSON.
/// Note: This structure is memory efficient for transfer but poor for UI iteration.
struct HourlyData: Codable {
	let time: [String]
	let temperature2m: [Double]

	enum CodingKeys: String, CodingKey {
		case time
		case temperature2m = "temperature_2m"
	}
}

// MARK: - Domain Model Extension (Expert Suggestion)
extension WeatherResponse {
	/// A single data point representing one hour of weather.
	/// Useful for SwiftUI Lists or Charts.
	struct WeatherPoint: Identifiable {
		let id = UUID()
		let date: Date
		let temperature: Double
	}

	/// Computes a list of standard objects from the parallel arrays.
	/// - Returns: An array of WeatherPoint ready for UI consumption.
	func getFormattedHourlyData() -> [WeatherPoint] {
		var points: [WeatherPoint] = []

		// Date Formatter for the specific input format "yyyy-MM-dd'T'HH:mm"
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
		formatter.timeZone = TimeZone(identifier: self.timezone)

		// Zip the two arrays to ensure we don't access out-of-bounds indices
		for (timeString, temp) in zip(hourly.time, hourly.temperature2m) {
			if let date = formatter.date(from: timeString) {
				points.append(WeatherPoint(date: date, temperature: temp))
			}
		}

		return points
	}
}
