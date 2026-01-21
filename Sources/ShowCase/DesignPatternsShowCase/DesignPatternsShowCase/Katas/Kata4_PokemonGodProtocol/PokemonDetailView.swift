import SwiftUI

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
