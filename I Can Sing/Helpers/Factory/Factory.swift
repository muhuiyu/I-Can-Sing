//
//  Factory.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/22/23.
//

import UIKit

class Factory {
    
    static func makeAnnotateViewController(for songID: SongID,
                                           _ databaseManager: DatabaseManager) -> AnnotateViewController {
        let viewModel = AnnotateViewModel(databaseManager: databaseManager)
        viewModel.songID.accept(songID)
        return AnnotateViewController(viewModel: viewModel)
    }
    
    static func makeErrorAlertController(with title: String, for error: Error) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok, got it", style: .default))
        return alert
    }
    
}
