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

@MainActor
final class WeatherViewModelBad: ObservableObject {
    @Published var points: [HourPoint] = []
    @Published var status: String = "idle"

    func load(lat: Double, lon: Double) {
        status = "loading"
        // URL montada a mano (mal) + zona horaria del sistema (no inyectable)
        let tz = TimeZone.current.identifier
        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&hourly=temperature_2m&timezone=\(tz)"
        guard let url = URL(string: urlStr) else { status = "bad_url"; return }

        // Retries manuales con sleep en main thread (mal)
        var attempts = 0
        func go() {
            attempts += 1
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error {
                    print("ERR \(error)")
                    if attempts < 3 {
                        // Reintento tosco (mal)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { go() }
                    } else {
                        Task { @MainActor in self.status = "error" }
                    }
                    return
                }
                guard
                    let data,
                    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let hourly = json["hourly"] as? [String: Any],
                    let times = hourly["time"] as? [String],
                    let temps = hourly["temperature_2m"] as? [Double]
                else { Task { @MainActor in self.status = "parse_error" }; return }

                let merged: [HourPoint] = zip(times, temps).map { HourPoint(time: $0.0, temperature_2m: $0.1) }
                Task { @MainActor in
                    self.points = merged
                    self.status = "loaded at \(Date())" // usa Date() directo (mal)
                }
            }.resume()
        }
        go()
    }
}

struct WeatherBadView: View {
    @StateObject private var vm = WeatherViewModelBad()
    var body: some View {
        VStack {
            Text(vm.status)
            List(vm.points, id: \.time) { p in
                Text("\(p.time)  \(p.temperature_2m ?? .nan)ºC")
            }
        }
        .onAppear { vm.load(lat: 40.4168, lon: -3.7038) }
    }
}
