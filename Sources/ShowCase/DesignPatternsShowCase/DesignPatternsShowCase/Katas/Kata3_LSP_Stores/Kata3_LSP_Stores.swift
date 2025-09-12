//
//  Kata3_LSP_Stores.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//

//
//  Kata3_LSP_Stores.swift
//  Anti-ejemplo para refactorizar (viola LSP, usa herencia con fatalError)
//

import Foundation

struct Book: Decodable {
    let key: String
    let title: String
    let author_name: [String]?
    let cover_i: Int?
}

protocol BookStore {
    func search(query: String) throws -> [Book]
}

class RemoteBookStore: BookStore {
    func search(query: String) throws -> [Book] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://openlibrary.org/search.json?q=\(encoded)")!
        let sem = DispatchSemaphore(value: 0)
        var out: [Book] = []
        var anyError: Error?
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { sem.signal() }
            if let error { anyError = error; return }
            guard let data else { anyError = NSError(domain: "no_data", code: -1); return }
            // Parse parcial y frágil (mal)
            struct Resp: Decodable { let docs: [Book] }
            out = (try? JSONDecoder().decode(Resp.self, from: data))?.docs ?? []
        }.resume()
        _ = sem.wait(timeout: .now() + 10)
        if let e = anyError { throw e }
        return out
    }
}

// Subclase que rompe el contrato: hace fatalError si no hay cache (mal)
final class CachedBookStore: RemoteBookStore {
    private var cache: [String: [Book]] = [:]

    override func search(query: String) throws -> [Book] {
        if let cached = cache[query] {
            return cached
        }
        // LSP VIOLATION: el protocolo prometía throws (error tipado),
        // aquí directamente crashea si no hay dato en cache.
        fatalError("Cache miss for query \(query)")
    }

    // API ad hoc para rellenar cache (mal diseño de contrato)
    func warm(query: String) {
        if let results = try? super.search(query: query) {
            cache[query] = results
        }
    }
}
