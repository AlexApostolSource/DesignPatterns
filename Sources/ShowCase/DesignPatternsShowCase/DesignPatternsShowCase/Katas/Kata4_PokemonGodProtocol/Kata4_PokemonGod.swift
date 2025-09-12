//
//  Kata4_PokemonGod.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//

//
//  Kata4_PokemonGodProtocol.swift
//  Anti-ejemplo para refactorizar (viola ISP; UI depende de un mega-protocolo)
//

import SwiftUI

// Un único protocolo gigante obliga a implementarlo todo (mal)
protocol PokemonManaging {
    func fetchList(limit: Int, offset: Int, completion: @escaping ([(name: String, url: String)]) -> Void)
    func fetchDetail(nameOrId: String, completion: @escaping (Data?) -> Void)
    func prefetchSprites(urls: [URL])
    func cancelAll()
    func logEvent(_ name: String, params: [String: Any])
    func clearCache()
    func currentCacheSize() -> Int
}

// Una implementación que mezcla red, cache, analítica y colas (mal)
final class PokemonManagerBad: PokemonManaging {
    private var tasks: [URLSessionDataTask] = []
    func fetchList(limit: Int, offset: Int, completion: @escaping ([(name: String, url: String)]) -> Void) {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)")!
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: String]] else { completion([]); return }
            let mapped = results.compactMap { ( $0["name"].map { ($0, $0) } ) } // url “fake”
            completion(mapped)
        }
        tasks.append(task); task.resume()
    }

    func fetchDetail(nameOrId: String, completion: @escaping (Data?) -> Void) {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(nameOrId)")!
        let t = URLSession.shared.dataTask(with: url) { data, _, _ in completion(data) }
        tasks.append(t); t.resume()
    }

    func prefetchSprites(urls: [URL]) { /* dispara N tasks sin límite (mal) */ urls.forEach { URLSession.shared.dataTask(with: $0).resume() } }
    func cancelAll() { tasks.forEach { $0.cancel() }; tasks.removeAll() }
    func logEvent(_ name: String, params: [String : Any]) { print("LOG \(name) \(params)") }
    func clearCache() { /* n/a */ }
    func currentCacheSize() -> Int { 0 }
}

// La vista está acoplada al mega-protocolo (mal)
struct PokemonListBadView: View {
    let manager: PokemonManaging = PokemonManagerBad()
    @State private var items: [String] = []

    var body: some View {
        List(items, id: \.self) { Text($0.capitalized) }
            .onAppear {
                manager.fetchList(limit: 50, offset: 0) { results in
                    self.items = results.map(\.name)
                    // Pide detalles desde la vista (mal)
                    if let first = self.items.first {
                        manager.fetchDetail(nameOrId: first) { _ in print("Detail fetched") }
                    }
                }
            }
            .navigationTitle("Pokémon")
    }
}
