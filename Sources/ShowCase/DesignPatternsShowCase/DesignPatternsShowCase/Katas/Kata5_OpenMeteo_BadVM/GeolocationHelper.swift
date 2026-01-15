//
//  GeolocationHelper.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 15/1/26.
//

import CoreLocation

protocol GeolocationHelperProtocol {
	func getLocationName(lat: Double, lon: Double) async throws -> String
}

struct GeocodingHelper: GeolocationHelperProtocol {
	private let geocoder = CLGeocoder()

	/// Transforma coordenadas en un nombre legible (Ej: "Madrid, España")
	func getLocationName(lat: Double, lon: Double) async throws -> String {
		let location = CLLocation(latitude: lat, longitude: lon)

		// Llamada asíncrona a los servidores de Apple (o caché local)
		// Nota: preferredLocale es opcional, por defecto usa el del sistema
		let placemarks = try await geocoder.reverseGeocodeLocation(location)

		guard let place = placemarks.first else {
			return "Ubicación desconocida"
		}

		// Construimos el string priorizando la Localidad (Ciudad) y el País
		// compactMap elimina nils si alguno falta
		let components = [place.locality, place.country]
			.compactMap { $0 }

		return components.joined(separator: ", ")
	}
}
