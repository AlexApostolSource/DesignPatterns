//
//  Kata4_PokemonGod.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
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
				HStack {
					VStack {
						Kata4Factory.makeViewSpriteView(pokemonID: pokemon.urlID ?? "")
					}
					.frame(width: 60, height: 60)

					Text(pokemon.name)
				}
			}
		}
		.onScrollGeometryChange(for: Bool.self, of: { geometry in
			let contentHeight = geometry.contentSize.height
			let visibleHeight = geometry.containerSize.height
			let scrollOffset = geometry.contentOffset.y

			let distanceToBottom = contentHeight - visibleHeight - scrollOffset
			return distanceToBottom < 500
		}, action: { wasNearBottom, isNearBottom in
			if isNearBottom && !wasNearBottom {
				Task {
					await viewModel.loadMore()
				}
			}
		})
		.task {
			await viewModel.getPokemons(limit: 50, offset: 0)
		}
		.navigationDestination(item: $viewModel.pokemonDetail, destination: { detail in
			PokemonDetailView(detail: detail)
		})
		.overlay(content: {
			if viewModel.isLoading {
				ProgressView()
			}
		})
		.navigationTitle("Pokémon")
	}
}
