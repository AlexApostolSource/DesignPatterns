// WeatherDomain.swift
import Foundation

// MARK: - Domain Models

struct Coordinates: Equatable {
    let latitude: Double
    let longitude: Double
}

struct HourlyForecast: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let temperature: Measurement<UnitTemperature>
}

struct WeatherForecast: Equatable {
    let coordinates: Coordinates
    let timeZone: TimeZone
    let elevation: Measurement<UnitLength>
    let hourly: [HourlyForecast]
}

// MARK: - Mapper (DTO -> Domain)

extension WeatherResponse {
    func toDomain() -> WeatherForecast {
        let tz = TimeZone(identifier: timezone) ?? .current
        let tempUnit = UnitTemperature.from(apiSymbol: hourlyUnits.temperature2m)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = tz

        let hourlyPoints: [HourlyForecast] = zip(hourly.time, hourly.temperature2m).compactMap { timeString, temp in
            guard let date = formatter.date(from: timeString) else { return nil }
            return HourlyForecast(
                date: date,
                temperature: Measurement(value: temp, unit: tempUnit)
            )
        }

        return WeatherForecast(
            coordinates: Coordinates(latitude: latitude, longitude: longitude),
            timeZone: tz,
            elevation: Measurement(value: elevation, unit: .meters),
            hourly: hourlyPoints
        )
    }
}

// MARK: - Helpers

private extension UnitTemperature {
    static func from(apiSymbol: String) -> UnitTemperature {
        let symbol = apiSymbol.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if symbol.contains("c") { return .celsius }
        if symbol.contains("f") { return .fahrenheit }
        if symbol.contains("k") { return .kelvin }
        return .celsius
    }
}


extension Measurement where UnitType == UnitTemperature {

	// 1. Singleton del formateador para evitar impacto en performance (crearlos es costoso)
	private static let temperatureFormatter: MeasurementFormatter = {
		let formatter = MeasurementFormatter()

		// .naturalScale permite convertir C -> F automáticamente si el usuario usa sistema imperial
		// .providedUnit fuerza a mostrar la unidad que le pasas (ej. siempre C)
		formatter.unitOptions = .naturalScale

		formatter.unitStyle = .short // Muestra "18°C" en lugar de "18 degrees Celsius"

		// Configuración numérica: 1 decimal máximo (estándar en apps de clima)
		formatter.numberFormatter.maximumFractionDigits = 1
		formatter.numberFormatter.minimumFractionDigits = 0 // "20°" en vez de "20.0°"

		return formatter
	}()

	/// Devuelve el string formateado localizado (ej: "24,5°C" en ES, "76°F" en US)
	func asString() -> String {
		return Self.temperatureFormatter.string(from: self)
	}

	/// Variación para listas compactas (sin decimales)
	func asCompactString() -> String {
		let formatter = Self.temperatureFormatter
		let oldDigits = formatter.numberFormatter.maximumFractionDigits

		// Cambiamos temporalmente
		formatter.numberFormatter.maximumFractionDigits = 0
		let result = formatter.string(from: self)

		// Restauramos (o usamos un segundo formatter si hay concurrencia extrema)
		formatter.numberFormatter.maximumFractionDigits = oldDigits
		return result
	}
}
