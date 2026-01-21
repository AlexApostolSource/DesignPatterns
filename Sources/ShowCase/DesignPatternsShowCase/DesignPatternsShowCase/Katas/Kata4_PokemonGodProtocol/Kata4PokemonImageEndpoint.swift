import Foundation
import NetworkLayer

struct Kata4PokemonImageEndpoint: NetworkLayerEndpoint {
	var queryItems: [URLQueryItem] = []

	var host: String {
		"raw.githubusercontent.com"
	}

	var path: String {
		"/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
	}

	var method: NetworkLayer.URLRequestMethod = .GET

	private let id: String

	init (id: String) {
		self.id = id
	}
}
