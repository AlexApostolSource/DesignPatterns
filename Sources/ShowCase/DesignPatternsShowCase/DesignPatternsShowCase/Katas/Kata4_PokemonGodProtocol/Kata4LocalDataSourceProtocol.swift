import Foundation

protocol Kata4LocalDataSourceProtocol {
	func fetchList(limit: Int, offset: Int) -> [PokemonDomain]?
	func saveList(_ list: [PokemonDomain])
	func saveDetail(nameOrId: String, detail: PokemonDetail)
	func clearCache()
	func getDetail(nameOrId: String) -> PokemonDetail?
	func currentCacheSize() -> Int
}
