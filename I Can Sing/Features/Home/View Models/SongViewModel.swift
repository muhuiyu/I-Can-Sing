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
    
    private let dataProvider: DataProvider
    private let songResponse: SongResponse
    
    let isFetching = BehaviorRelay(value: true)
    let song: BehaviorRelay<Song?> = BehaviorRelay(value: nil)
    
    init(dataProvider: DataProvider, songResponse: SongResponse) {
        self.songResponse = songResponse
        self.dataProvider = dataProvider
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
            let result = try await dataProvider.fetchSong(for: songResponse)
            isFetching.accept(false)
            song.accept(result)
        } catch {
            // TODO: - Show error
        }
    }
}
