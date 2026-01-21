import Foundation

protocol Kata4RemoteDataSourceProtocol {
	func fetchPokemonsList(limit: Int, offset: Int) async throws -> PokemonsResponse
	func fetchDetail(nameOrId: String) async throws -> PokemonDetail
	func fetchImage(nameOrId: String) async throws -> Data
}
