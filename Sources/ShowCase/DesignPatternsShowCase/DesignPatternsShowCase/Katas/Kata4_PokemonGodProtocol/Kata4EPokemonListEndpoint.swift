import Foundation
import NetworkLayer

struct Kata4EPokemonListEndpoint: NetworkLayerEndpoint {
	var queryItems: [URLQueryItem] {
		[
			URLQueryItem(name: Constants.limit, value: "\(limit)"),
			URLQueryItem(name: Constants.offset, value: "\(offset)")
		]
	}

	var path: String = "/api/v2/pokemon"
	var method: NetworkLayer.URLRequestMethod = .GET

	struct Constants {
		static let limit = "limit"
		static let offset = "offset"
	}

	private let limit: Int
	private let offset: Int

	init(limit: Int, offset: Int) {
		self.limit = limit
		self.offset = offset
	}
}
