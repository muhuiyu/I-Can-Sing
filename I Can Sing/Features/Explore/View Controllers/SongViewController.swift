//
//  SongViewController.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import UIKit
import RxSwift
import RxRelay

class SongViewController: Base.MVVMViewController<SongViewModel> {
    
    // MARK: - Views
    private let textView = UITextView()
    private let activityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
        viewModel.setup()
    }
    
}

// MARK: - View Config
extension SongViewController {
    private func configureViews() {
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .compose,
                                                            primaryAction: UIAction(handler: { [weak self] _ in
            self?.didTapAddNote()
        }))
        
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = .systemFont(ofSize: 16)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(textView)
        
        activityIndicatorView.isHidden = true
        view.addSubview(activityIndicatorView)
    }
    
    private func configureConstraints() {
        textView.snp.remakeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view.layoutMarginsGuide)
        }
        activityIndicatorView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func configureBindings() {
        viewModel.isFetching
            .asObservable()
            .subscribe { [weak self] isFetching in
                DispatchQueue.main.async {
                    self?.configureActivityIndicatorShows()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.song
            .asObservable()
            .subscribe { [weak self] _ in
                DispatchQueue.main.async {
                    self?.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func configureActivityIndicatorShows() {
        let isFetching = viewModel.isFetching.value
        
        if isFetching {
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.isHidden = true
            activityIndicatorView.stopAnimating()
        }
    }
    
}

// MARK: - Handlers
extension SongViewController {
    private func reloadData() {
        title = viewModel.song.value?.name
        textView.text = viewModel.song.value?.lyrics
    }
    
    private func didTapAddNote() {
        do {
            try viewModel.addSongToLibrary()
            navigateToAnnotateViewController()
        } catch {
            print(error)
            let alert = Factory.makeErrorAlertController(with: "Failed to add song", for: error)
            present(alert, animated: true)
        }
    }
    
    private func navigateToAnnotateViewController() {
        if let viewController = viewModel.makeAnnotateViewController() {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
