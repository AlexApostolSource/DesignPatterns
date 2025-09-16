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
import Combine

public struct JPPost: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String

    public init(id: Int, userId: Int, title: String, body: String) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
    }
}

final class MassivePostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var posts: [Kata1Post] = []
    private var isLoading = false
    private let viewModel: Kata1ViewModelProtocol
    private var cancellable: AnyCancellable?



    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Posts"
        view.backgroundColor = .systemBackground
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        handleState()
        viewModel.viewDidLoad()
    }

    deinit {
        cancellable = nil
    }

    @MainActor
    private func handleState() {
        cancellable = viewModel.driver.sink { [weak self] state in
            switch state {
                case .loading:
                print("Loading...")
            case .success(let posts):
                self?.posts = posts
                self?.tableView.reloadData()
            case .failure(let error):
                print("Error: \(error)")
            case .void:
                Task { [weak self] in
                    try await self?.viewModel.getPosts()
                }
            }
        }
    }

    init(viewModel: Kata1ViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
