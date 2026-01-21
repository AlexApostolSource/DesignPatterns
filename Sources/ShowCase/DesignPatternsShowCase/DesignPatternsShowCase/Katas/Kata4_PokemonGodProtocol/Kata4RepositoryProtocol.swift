import Foundation

protocol Kata4RepositoryProtocol {
	func fetchPokemonsList(limit: Int, offset: Int) async throws -> [PokemonDomain]
	func fetchDetail(nameOrId: String) async throws -> PokemonDetail
	func clearCache()
	func cacheSize() -> Int
}
