//
//  SongViewModel.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import UIKit
import RxSwift
import RxRelay

class SongViewModel: Base.ViewModel {
    
    private let networkManager: NetworkManager
    private let databaseManager: DatabaseManager
    private let songResponse: SongResponse
    
    let isFetching = BehaviorRelay(value: true)
    let song: BehaviorRelay<Song?> = BehaviorRelay(value: nil)
    
    init(networkManager: NetworkManager, databaseManager: DatabaseManager, songResponse: SongResponse) {
        self.networkManager = networkManager
        self.databaseManager = databaseManager
        self.songResponse = songResponse
    }
    
    func setup() {
        // fetch song
        Task {
            await self.fetchSong()
        }
    }
}

extension SongViewModel {
    private func fetchSong() async {
        isFetching.accept(true)
        do {
            let result = try await networkManager.fetchSong(for: songResponse)
            isFetching.accept(false)
            song.accept(result)
        } catch {
            // TODO: - Show error
        }
    }
    
    func addSongToLibrary() throws {
        guard let song = song.value else { return }
        try databaseManager.addSong(song)
    }
    
    func makeAnnotateViewController() -> AnnotateViewController? {
        guard let id = song.value?.id else { return nil }
        return Factory.makeAnnotateViewController(for: id, databaseManager)
    }
}
