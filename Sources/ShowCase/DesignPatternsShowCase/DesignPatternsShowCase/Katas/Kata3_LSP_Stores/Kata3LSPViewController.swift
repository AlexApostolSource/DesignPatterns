//
//  Kata3LSPViewController.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 6/10/25.
//

import UIKit
import Combine

final class Kata3LSPViewController: UITableViewController, UISearchResultsUpdating {
	private var cancellable: AnyCancellable?
	private let viewModel: Kata3LSPViewModelProtocol
	private var dataSource: [Book] = []
	private let searchController = UISearchController(searchResultsController: nil)

	init(viewModel: Kata3LSPViewModelProtocol) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(BookCell.self, forCellReuseIdentifier: BookCell.reuseID)
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Book"
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = true
		bind(to: viewModel)
	}

	func updateSearchResults(for searchController: UISearchController) {
		let text = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

		Task {
			try await viewModel.loadBooks(query: text)
		}
	}


	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		cancellable = nil
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func bind(to viewModel: Kata3LSPViewModelProtocol) {
		cancellable = viewModel.driver.receive(on: RunLoop.main).sink(receiveValue: { [weak self] in
			self?.handleState(state: $0)
		})
	}

	private func handleState(state: Kata3LSPViewModelState) {
		switch state {
			case .void:
					break
			case .loading:
				break
			case .loaded(let array):
				self.dataSource = array
				tableView.reloadData()
			case .error:
				break
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		dataSource.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let book = dataSource[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: BookCell.reuseID, for: indexPath) as! BookCell
		cell.configure(with: book)
		return cell
	}
}

final class BookCell: UITableViewCell {
	static let reuseID = "BookCell"

	private let coverView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 8
		iv.backgroundColor = .secondarySystemBackground
		return iv
	}()

	private let titleLabel: UILabel = {
		let l = UILabel()
		l.font = .systemFont(ofSize: 16, weight: .semibold)
		l.numberOfLines = 2
		return l
	}()

	private let subtitleLabel: UILabel = {
		let l = UILabel()
		l.font = .systemFont(ofSize: 13)
		l.textColor = .secondaryLabel
		l.numberOfLines = 2
		return l
	}()

	private var imageTask: Task<Void, Never>?

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}

	required init?(coder: NSCoder) { fatalError("init(coder:) no soportado") }

	override func prepareForReuse() {
		super.prepareForReuse()
		imageTask?.cancel()
		coverView.image = nil
		titleLabel.text = nil
		subtitleLabel.text = nil
	}

	private func setup() {
		accessoryType = .disclosureIndicator
		let vstack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
		vstack.axis = .vertical
		vstack.spacing = 4

		contentView.addSubview(coverView)
		contentView.addSubview(vstack)

		coverView.translatesAutoresizingMaskIntoConstraints = false
		vstack.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			coverView.widthAnchor.constraint(equalToConstant: 60),
			coverView.heightAnchor.constraint(equalToConstant: 80),
			coverView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			coverView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

			vstack.leadingAnchor.constraint(equalTo: coverView.trailingAnchor, constant: 12),
			vstack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			vstack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12),
			vstack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
			vstack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}

	func configure(with book: Book) {
		titleLabel.text = book.title
		let authors = (book.author_name ?? []).joined(separator: ", ")
		subtitleLabel.text = authors.isEmpty ? "Autor desconocido" : authors


			coverView.image = UIImage(systemName: "book")
		
	}
}

