//
//  MainTabBarController.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private let networkManager: NetworkManager
    private let databaseManager: DatabaseManager
    
    init(networkManager: NetworkManager, databaseManager: DatabaseManager) {
        self.networkManager = networkManager
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureControllers()
    }
}

extension MainTabBarController {
    private func configureControllers() {
        let libraryViewController = LibraryViewController(
            viewModel: LibraryViewModel(databaseManager: databaseManager)
        )
        libraryViewController.tabBarItem = UITabBarItem(title: "Library",
                                                        image: UIImage(systemName: "music.note"),
                                                        selectedImage: UIImage(systemName: "music.note.list"))
        
        let exploreViewController = ExploreViewController(
            viewModel: ExploreViewModel(networkManager: networkManager, databaseManager: databaseManager)
        )
        exploreViewController.tabBarItem = UITabBarItem(title: "Explore",
                                                        image: UIImage(systemName: "safari"),
                                                        selectedImage: UIImage(systemName: "safari.fill"))
        
        viewControllers = [
            libraryViewController.embedInNavgationController(),
            exploreViewController.embedInNavgationController()
        ]
    }
}
