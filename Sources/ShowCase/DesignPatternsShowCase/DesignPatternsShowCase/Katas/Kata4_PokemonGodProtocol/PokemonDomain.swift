import Foundation

struct PokemonDomain: Identifiable {
	let id: String = UUID().uuidString
	let name: String
	let url: String

	var urlID: String? {
		let idString = url.split(separator: "/").last
		return idString?.lowercased()
	}
}
