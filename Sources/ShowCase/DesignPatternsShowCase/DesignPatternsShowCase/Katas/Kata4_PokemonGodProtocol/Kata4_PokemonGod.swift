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
			.onScrollGeometryChange(for: Bool.self, of: { geometry in
				let contentHeight = geometry.contentSize.height
				let visibleHeight = geometry.containerSize.height
				let scrollOffset = geometry.contentOffset.y

				// 2. Definimos el "umbral" (ej. 300 puntos antes del final)
				// Esto equivale visualmente a unas 4-5 celdas
				let distanceToBottom = contentHeight - visibleHeight - scrollOffset

				// 3. Devolvemos true si estamos cerca del final
				return distanceToBottom < 500
			}, action: { wasNearBottom, isNearBottom in
				if isNearBottom && !wasNearBottom {
					Task {
						await viewModel.loadMore()
					}
				}
			}).task {
					await viewModel.getPokemons(limit: 50, offset: 0)
				}.navigationDestination(item: $viewModel.pokemonDetail, destination: { detail in
					PokemonDetailView(detail: detail)
				}).overlay(content: {
					if viewModel.isLoading {
						ProgressView()
					}
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
