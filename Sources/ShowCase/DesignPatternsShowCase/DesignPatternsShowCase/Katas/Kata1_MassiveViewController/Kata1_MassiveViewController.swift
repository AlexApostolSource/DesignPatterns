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

final class MassivePostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var posts: [Kata1Post] = []
    private var isLoading = false
    private let viewModel: Kata1ViewModelProtocol
    private var cancellable: AnyCancellable?
    private let footerSpinner: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.hidesWhenStopped = true
        v.frame = .init(x: 0, y: 0, width: .zero, height: 44)
        return v
    }()
    private let prefetchBuffer = 10


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Posts"
        view.backgroundColor = .systemBackground
        tableView.frame = view.bounds
        tableView.tableFooterView = footerSpinner
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        view.addSubview(tableView)
        bind(viewModel: viewModel)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancellable?.cancel()
        cancellable = nil
    }


    private func bind(viewModel: Kata1ViewModelProtocol) {
        cancellable = viewModel.driver
            .receive(on: RunLoop.main)
            .sink(
                receiveValue: {
                    [ weak self ]
                    in self?.handleState(state: $0)
                })
    }

    private func handleState(state: Kata1ViewModelState) {
        cancellable = viewModel.driver
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
            switch state {
                case .loading:
                print("Loading...")
            case .success(let posts):
                self?.posts += posts
                self?.tableView.reloadData()
            case .failure(let error):
                // Show error view
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

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let triggerRow = max(0, posts.count - prefetchBuffer)
        let shouldLoad = indexPaths.contains { $0.section == 0 && $0.row >= triggerRow }

//        if shouldLoad {
//            Task {
//                try await viewModel.getPosts()
//            }
//        }
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        let lastRow = max(0, posts.count - 1)
        if indexPath.section == 0, indexPath.row == lastRow {
            Task {
                try await viewModel.getPosts()
            }
        }
    }
}
