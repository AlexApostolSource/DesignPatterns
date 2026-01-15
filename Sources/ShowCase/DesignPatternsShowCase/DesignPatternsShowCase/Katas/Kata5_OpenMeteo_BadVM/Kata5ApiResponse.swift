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
