//
//  Kata4PokemonImageView.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 31/12/25.
//

import SwiftUI

struct Kata4PokemonSpriteImageView: View {
	@State var viewModel: Kata4PokemonImageViewViewModel
	private let id: String

	var body: some View {
		VStack {
			if let viewModelImage = viewModel.image {
				viewModelImage
			} else {
				ProgressView()
			}
		}.task {
			await viewModel.getImage(for: id)
		}
	}

	public init(viewModel: Kata4PokemonImageViewViewModel, id: String) {
		self.viewModel = viewModel
		self.id = id
	}
}
