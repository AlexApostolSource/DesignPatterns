//
//  Kata1_MassiveViewController.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 11/9/25.
//

//
//  Kata1_MassiveViewController.swift
//  Anti-ejemplo para refactorizar (viola SRP, acopla UI/red/cache/analytics)
//

import UIKit

struct JPPost: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

final class MassivePostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var posts: [JPPost] = []
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Posts"
        view.backgroundColor = .systemBackground
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        // Todo mezclado aquí:
        fetchPostsAndDoEverything()
    }

    override init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Red + parseo + persistencia + analítica + UI en un mismo método (mal)
    private func fetchPostsAndDoEverything(page: Int = 1) {
        guard !isLoading else { return }
        isLoading = true
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self else { return }
            if let error { print("ERROR NETWORK \(error)"); self.loadFromCacheIfAny(); return }
            guard let data else { print("NO DATA"); self.loadFromCacheIfAny(); return }
            let decoded = (try? JSONDecoder().decode([JPPost].self, from: data)) ?? []
            // Persistencia directa desde el VC (mal)
            do {
                try data.write(to: self.cacheURL(), options: .atomic)
            } catch { print("CACHE_WRITE_FAIL \(error)") }
            // Analítica ad hoc (mal)
            print("ANALYTICS: posts_loaded count=\(decoded.count) page=\(page)")
            self.posts = decoded
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.isLoading = false
            }
        }.resume()
    }

    private func cacheURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("jp_posts.json")
    }

    private func loadFromCacheIfAny() {
        let url = cacheURL()
        if let data = try? Data(contentsOf: url),
           let items = try? JSONDecoder().decode([JPPost].self, from: data) {
            print("CACHE_HIT: \(items.count)")
            self.posts = items
        } else {
            print("CACHE_MISS")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.isLoading = false
        }
    }

    // MARK: - UITableView
    func tableView(_ t: UITableView, numberOfRowsInSection section: Int) -> Int { posts.count }
    func tableView(_ t: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let p = posts[indexPath.row]
        cell.textLabel?.text = "#\(p.id) \(p.title)"
        cell.detailTextLabel?.text = p.body
        return cell
    }
}
