//
//  AnnotateViewModel.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/22/23.
//

import UIKit
import RxSwift
import RxRelay

class AnnotateViewModel: Base.ViewModel {
    
    private let databaseManager: DatabaseManager
    
    let isFetching = BehaviorRelay(value: true)
    let songID: BehaviorRelay<SongID?> = BehaviorRelay(value: nil)
    let song: BehaviorRelay<AnnotatedSong?> = BehaviorRelay(value: nil)
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        super.init()
        
        self.songID
            .asObservable()
            .subscribe { [weak self] id in
            guard let self, let id else { return }
            let song = self.databaseManager.loadAnnotatedSong(for: id)
            self.song.accept(song)
        }
        .disposed(by: disposeBag)
    }
}

extension AnnotateViewModel {
    func addNote(for word: String, at range: NSRange, with note: String) throws {
        guard var song = song.value else { return }
        
        if var oldValue = song.notes[range] {
            oldValue.note = note
            song.notes[range] = oldValue
        } else {
            song.notes[range] = AnnotatedSongNote(range: range, note: note)
        }
        self.song.accept(song)

        try databaseManager.saveAnnotatedSong(song)
    }
}

