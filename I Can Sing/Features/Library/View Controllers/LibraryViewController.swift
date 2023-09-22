//
//  LibraryViewController.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import UIKit
import RxSwift
import RxRelay

class LibraryViewController: Base.MVVMViewController<LibraryViewModel> {
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
    }
    
}

// MARK: - View Config
extension LibraryViewController {
    private func configureViews() {
        title = "Library"
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    private func configureBindings() {
        viewModel.songs
            .asObservable()
            .subscribe { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - TableView DataSource and Delegate
extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.songs.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.text = viewModel.songs.value[indexPath.row].name
        content.secondaryText = viewModel.songs.value[indexPath.row].artist
        cell.contentConfiguration = content
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if let viewController = viewModel.makeAnnotateViewController(at: indexPath) {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}

