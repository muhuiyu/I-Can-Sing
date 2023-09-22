//
//  LibraryViewModel.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import UIKit
import RxSwift
import RxRelay

class LibraryViewModel: Base.ViewModel {
    
    private let databaseManager: DatabaseManager
    
    let songs: BehaviorRelay<[AnnotatedSong]> = BehaviorRelay(value: [])
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }
    
}

extension LibraryViewModel {
    func makeAnnotateViewController(at indexPath: IndexPath) -> AnnotateViewController? {
        guard songs.value.count > indexPath.row else { return nil }
        let song = songs.value[indexPath.row]
        return Factory.makeAnnotateViewController(for: song.id, databaseManager)
    }
}

