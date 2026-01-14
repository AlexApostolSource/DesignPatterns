//
//  Untitled.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//

//
//  Kata5_OpenMeteo_BadVM.swift
//  Anti-ejemplo para refactorizar (viola DIP; URLs a mano; tiempo real acoplado)
//

import Combine
import Foundation
import SwiftUI

struct HourPoint: Decodable { let time: String; let temperature_2m: Double? }

struct WeatherBadView: View {
	@State var vm: WeatherViewModelBad

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()

    var body: some View {
		VStack {
			switch vm.currentState {
			case .void:
				ProgressView()
			case .loading:
				ProgressView()
			case .loaded(let points):
				Text(vm.currentState.status)
				List(points) { points in
					let timeText = Self.timeFormatter.string(from: points.date)
					Text("\(timeText)  \(points.temperature)ºC")
				}
			case .error:
				// Native SwiftUI error handling UI component
				ContentUnavailableView(
					"Network Error",
					systemImage: "exclamationmark.triangle",
					description: Text("CannotLoadData")
				)
				Button("Retry") {
					// Task allows bridging synchronous button action to async context
					Task {
						await vm.load(lat: 40.4168, lon: -3.7038)
					}

				}
				.buttonStyle(.borderedProminent)
			}
		}.task {
			if case .void = vm.currentState {
				await vm.load(lat: 40.4168, lon: -3.7038)
			}
		}
	}
}
