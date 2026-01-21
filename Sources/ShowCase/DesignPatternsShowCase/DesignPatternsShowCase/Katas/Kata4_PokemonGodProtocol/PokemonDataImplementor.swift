import Foundation

protocol PokemonDataImplementor {
	func fetchList(limit: Int, offset: Int) async throws -> [PokemonDomain]
	func fetchDetail(nameOrId: String) async throws -> PokemonDetail
	func clearCache()
	func fetchImage(nameOrId: String) async throws -> Data
}
