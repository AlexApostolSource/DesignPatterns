import Foundation
import SwiftUI
import NetworkLayer

struct Kata4Factory {
	static func makeViewModel() -> PokemonBrowserViewModel {
		NetworkLayerConfig.config(host: "pokeapi.co")
		let requestProvider: RequestProviderProtocol = RequestProvider.basic

		let localDataSource = Kata4LocalDataSource()
		let remoteDataSource = Kata4RemoteDataSource(requestProvider: requestProvider)
		let repo = Kata4Repository(remoteDataSource: remoteDataSource, localDataSource: localDataSource)
		let dataProvider = CacheFirstDataImplementor(repo: repo)
		return PokemonBrowserViewModel(dataProvider: dataProvider)
	}

	static func makeViewSpriteView(pokemonID: String) -> Kata4PokemonSpriteImageView {
		let requestProvider: RequestProviderProtocol = RequestProvider.basic
		let remoteDataSource = Kata4RemoteDataSource(requestProvider: requestProvider)
		let dataProvider = RemoteOnlyDataImplementor(remoteDataSource: remoteDataSource)
		let vm = Kata4PokemonImageViewViewModel(dataProvider: dataProvider)
		return Kata4PokemonSpriteImageView(viewModel: vm, id: pokemonID)
	}
}
