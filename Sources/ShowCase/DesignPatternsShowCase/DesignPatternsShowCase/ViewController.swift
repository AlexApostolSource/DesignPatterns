//
//  ViewController.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 11/9/25.
//
//
import UIKit

class ViewController: UITableViewController {
    private let katas: [UIViewController] = [MassivePostsViewController()]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Design Patterns Showcase"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return katas.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let viewController = katas[indexPath.row]
        cell.textLabel?.text = String(describing: type(of: viewController))
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedViewController = katas[indexPath.row]
        navigationController?.pushViewController(selectedViewController, animated: true)
    }
}
