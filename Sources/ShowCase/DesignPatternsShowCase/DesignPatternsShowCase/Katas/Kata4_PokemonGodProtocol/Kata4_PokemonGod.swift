//
//  Kata4_PokemonGod.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//

//
//  Kata4_PokemonGodProtocol.swift
//  Anti-ejemplo para refactorizar (viola ISP; UI depende de un mega-protocolo)
//

import SwiftUI
import NetworkLayer



// La vista está acoplada al mega-protocolo (mal)
struct PokemonListBadView: View {
	@State var viewModel = Kata4Factory.makeViewModel()

    var body: some View {
			List(viewModel.pokemons) { pokemon in
				Button {
					Task {
						await viewModel.detail(nameOrId: pokemon.name)
					}
				} label: {
					Text(pokemon.name)

				}
			}
				.onAppear {
	//                manager.fetchList(limit: 50, offset: 0) { results in
	//					viewModel.pokemons = results.map(\.name)
	//                    // Pide detalles desde la vista (mal)
	//                    if let first = self.items.first {
	//                        manager.fetchDetail(nameOrId: first) { _ in print("Detail fetched") }
	//                    }
	//                }
				}.task {
					await viewModel.getPokemons(limit: 50, offset: 0)
				}.navigationDestination(item: $viewModel.pokemonDetail, destination: { detail in
					PokemonDetailView(detail: detail)
				})
				.navigationTitle("Pokémon")

    }
}

struct PokemonDetailView: View {
	let detail: PokemonDetail
	var body: some View {
		VStack {
			Text(detail.name).font(.largeTitle)
			AsyncImage(url: detail.officialArtworkURL) { phase in
				switch phase {
				case .success(let image):
					image
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 150, height: 150)
				case .failure:
					Image(systemName: "exclamationmark.triangle")
				default:
					ProgressView()
				}
			}
		}
	}
}


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
}
