import Foundation
import SwiftUI

@Observable
final class Kata4PokemonImageViewViewModel {
	private var task: Task<Void, Error>?
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
