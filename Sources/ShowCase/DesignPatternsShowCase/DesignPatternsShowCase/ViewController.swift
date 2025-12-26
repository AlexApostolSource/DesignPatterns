//
//  ViewController.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 11/9/25.
//
//
import UIKit
import SwiftUI

/// Representable que permite integrar cualquier UIViewController en SwiftUI.
struct UIKitViewControllerAdapter: UIViewControllerRepresentable {
	let viewControllerFactory: () -> UIViewController

	func makeUIViewController(context: Context) -> UIViewController {
		return viewControllerFactory()
	}

	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

enum KataType: String, CaseIterable, Identifiable {
	case kata1 = "Kata 1: Factory Method"
	case bookStore = "BookStore Repository"
	case pokemon = "Pokémon List (SwiftUI)"
	case weather = "Weather App"
	case spaceX = "SpaceX Launches"

	var id: String { self.rawValue }

	// Generamos la vista de destino para cada caso
	@ViewBuilder
	var destination: some View {
		switch self {
		case .kata1:
			UIKitViewControllerAdapter { Kata1FactoryMethod.createKata1() }
		case .bookStore:
			UIKitViewControllerAdapter { BookStoreRepositoryFactory.make() }
		case .pokemon:
			PokemonListBadView()
		case .weather:
			WeatherBadView()
		case .spaceX:
			SpaceXBadView()
		}
	}
}

struct DesignPatternsShowCaseView: View {
	var body: some View {
		NavigationStack {
			List(KataType.allCases) { kata in
				NavigationLink(value: kata) {
					HStack(spacing: 16) {
						Image(systemName: "terminal.fill")
							.foregroundColor(.blue)
							.frame(width: 30)

						VStack(alignment: .leading, spacing: 4) {
							Text(kata.rawValue)
								.font(.headline)
								.foregroundColor(.primary)
							Text("Click para ejecutar la Kata")
								.font(.caption)
								.foregroundColor(.secondary)
						}
					}
					.padding(.vertical, 4)
				}
			}
			.navigationTitle("Design Patterns")
			.navigationDestination(for: KataType.self) { kata in
				kata.destination
					.navigationTitle(kata.rawValue)
					.navigationBarTitleDisplayMode(.inline)
			}
		}
	}
}
