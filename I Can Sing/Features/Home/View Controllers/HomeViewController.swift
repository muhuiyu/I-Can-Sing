//
//  HomeViewController.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import UIKit
import RxSwift

class HomeViewController: Base.MVVMViewController<HomeViewModel> {
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let activityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
    }
}

// MARK: - View Config
extension HomeViewController {
    private func configureViews() {
        searchBar.placeholder = "Search for lyrics"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        activityIndicatorView.isHidden = true
        view.addSubview(activityIndicatorView)
    }
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        activityIndicatorView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    private func configureBindings() {
        viewModel.isFetching
            .asObservable()
            .subscribe { [weak self] isLoading in
                self?.activityIndicatorView.isHidden = !isLoading
            }
            .disposed(by: disposeBag)
        
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

// MARK: - SearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
 
        Task {
            await viewModel.searchSongs(for: text)
        }
    }
}

// MARK: - TableView DataSource and Delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.songs.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.text = viewModel.songs.value[indexPath.row].autocomplete
        cell.contentConfiguration = content
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        let url = viewModel.songs.value[indexPath.row].url
        
        if let viewController = viewModel.generateSongViewController(at: indexPath) {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}

