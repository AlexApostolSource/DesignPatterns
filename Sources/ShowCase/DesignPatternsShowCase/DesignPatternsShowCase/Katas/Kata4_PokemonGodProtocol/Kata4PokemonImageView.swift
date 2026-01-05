//
//  Kata4PokemonImageView.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 31/12/25.
//

import SwiftUI
import NetworkLayer



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

@Observable
final class Kata4PokemonImageViewViewModel {
	private var task: Task <Void, Error>?
	private let dataProvider: PokemonDataImplementor
	private let flyweight: Kata4FlyweightUseCase
	enum State {
		case idle
		case loading(Task<Void,Error>)
		case loaded
	}
	private var currentState: State = .idle
	var image: DataImage?

	init(dataProvider: PokemonDataImplementor, flyweight: Kata4FlyweightUseCase = Kata4FlyweightUseCase.shared) {
		self.dataProvider = dataProvider
		self.flyweight = flyweight
	}

	func getImage(for id: String) async  {
		if let image = flyweight.get(for: id as NSString)?.image {
			self.image = DataImage(data: image)
			return
		}

		do {
			if case let .loading(task) = currentState {
				try await task.value
				return
			}
			let task = Task {
				let data = try await dataProvider.fetchImage(nameOrId: id)
				self.currentState = .loaded
				image = DataImage(data: data)
				saveImage(image: data, key: id)
			}
			self.currentState = .loading(task)
			 try await task.value

		} catch {
			print(error)
		}
	}

	func saveImage(image: Data, key: String) {
		flyweight.add(image: FlywieghtImage(image: image), for: key as NSString)
	}

	func getImage(for key: String) -> Data? {
		flyweight.get(for: key as NSString)?.image
	}
}

struct Kata4PokemonImageEndpoint: NetworkLayerEndpoint {
	var queryItems: [URLQueryItem] = []
	var host: String {
		"raw.githubusercontent.com"
	}
	// https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(idInt).png"
	var path: String {
		"/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
	}

	var method: NetworkLayer.URLRequestMethod = .GET

	private let id: String

	init (id: String) {
		self.id = id
	}
}


struct DataImage: View {
	let data: Data?

	var body: some View {
		if let data = data, let uiImage = UIImage(data: data) {
			// Success: Render the image
			Image(uiImage: uiImage)
				.resizable()
				.aspectRatio(contentMode: .fit)
		} else {
			// Failure/Empty: Render placeholder
			Image(systemName: "photo")
				.font(.largeTitle)
				.foregroundStyle(.gray)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(Color.gray.opacity(0.1))
		}
	}
}
