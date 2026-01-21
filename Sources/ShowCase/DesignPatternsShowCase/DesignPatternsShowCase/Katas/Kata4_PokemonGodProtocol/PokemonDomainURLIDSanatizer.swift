import Foundation

struct PokemonDomainURLIDSanatizer {
	static func sanitize(_ url: String) -> URL? {
		guard let idString = url.split(separator: "/").last,
			  let idInt = Int(idString) else {
			return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(0).png")
		}
		return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(idInt).png")
	}
}
