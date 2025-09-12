//
//  Kata6_SpaceX_Spaghetti.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//


//
//  Kata6_SpaceX_Spaghetti.swift
//  Anti-ejemplo para refactorizar (UI orquesta endpoints v4/v5 y mapea DTOs)
//

import SwiftUI

// DTOs mínimos (duplicados y dispersos, mal)
struct LaunchV5: Decodable { let name: String; let date_utc: String; let success: Bool?; let links: Links?
    struct Links: Decodable { let webcast: String?; let article: String? }
}
struct LaunchV4: Decodable { let name: String; let date_utc: String; let upcoming: Bool }

// Funciones globales que la UI llama directamente (mal)
func fetchLatestV5(completion: @escaping (LaunchV5?) -> Void) {
    let url = URL(string: "https://api.spacexdata.com/v5/launches/latest")!
    URLSession.shared.dataTask(with: url) { data, _, _ in
        let v = data.flatMap { try? JSONDecoder().decode(LaunchV5.self, from: $0) }
        completion(v)
    }.resume()
}
func fetchNextV4(completion: @escaping (LaunchV4?) -> Void) {
    let url = URL(string: "https://api.spacexdata.com/v4/launches/next")!
    URLSession.shared.dataTask(with: url) { data, _, _ in
        let v = data.flatMap { try? JSONDecoder().decode(LaunchV4.self, from: $0) }
        completion(v)
    }.resume()
}

// La vista mezcla mapeos y reintentos rudimentarios (mal)
struct SpaceXBadView: View {
    @State private var latest: LaunchV5?
    @State private var next: LaunchV4?
    @State private var status: String = "idle"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status: \(status)")
            if let l = latest {
                Text("Latest: \(l.name)")
                Text("Date: \(l.date_utc)")
                Text("Success: \(l.success == true ? "✅" : "❌")")
                if let url = l.links?.webcast { Text("Webcast: \(url)") }
            }
            Divider()
            if let n = next {
                Text("Next: \(n.name)")
                Text("Date: \(n.date_utc)")
                Text("Upcoming: \(n.upcoming ? "Yes" : "No")")
            }
            Button("Reload") { loadAll() }
        }
        .padding()
        .onAppear { loadAll() }
    }

    private func loadAll() {
        status = "loading"
        fetchLatestV5 { l in
            if l == nil {
                // “Fallback” improvisado a v4 next aunque no sea equivalente (mal)
                fetchNextV4 { n in
                    DispatchQueue.main.async {
                        self.next = n
                        self.status = n == nil ? "error" : "fallback_to_v4_next"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.latest = l
                    self.status = "loaded_v5"
                }
                // Lanza también el “next” por curiosidad (UI orquesta múltiple, mal)
                fetchNextV4 { n in
                    DispatchQueue.main.async { self.next = n }
                }
            }
        }
    }
}
