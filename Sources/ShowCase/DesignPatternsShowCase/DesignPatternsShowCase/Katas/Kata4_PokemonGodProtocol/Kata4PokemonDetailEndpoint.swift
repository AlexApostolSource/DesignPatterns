import Foundation
import NetworkLayer

struct Kata4PokemonDetailEndpoint: NetworkLayerEndpoint {
	var queryItems: [URLQueryItem] = []

	private let nameOrId: String
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}

	var path: String  {
		"/api/v2/pokemon/\(nameOrId)"
	}

	var method: NetworkLayer.URLRequestMethod = .GET
}
