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
            Text(vm.status)
            List(vm.points) { p in
                let timeText = Self.timeFormatter.string(from: p.date)
                Text("\(timeText)  \(p.temperature)ºC")
            }
        }
        .onAppear { vm.load(lat: 40.4168, lon: -3.7038) }
    }
}
