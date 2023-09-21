//
//  HomeViewModel.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import UIKit
import RxSwift
import RxRelay

class HomeViewModel: Base.ViewModel {
    
    private let dataProvider: DataProvider
    
    let songs: BehaviorRelay<[SongResponse]> = BehaviorRelay(value: [])
    let isFetching = BehaviorRelay(value: false)
    
    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
    }
}

extension HomeViewModel {
    func searchSongs(for keyword: String) async {
        isFetching.accept(true)
        
        do {
            let result = try await dataProvider.searchSongs(for: keyword)
            isFetching.accept(false)
            songs.accept(result.songs)
        } catch {
            // TODO: - Show error here
            isFetching.accept(false)
        }
    }
    
    func generateSongViewController(at indexPath: IndexPath) -> SongViewController? {
        guard songs.value.count >= indexPath.row else { return nil }
        return SongViewController(viewModel: SongViewModel(dataProvider: dataProvider,
                                                           songResponse: songs.value[indexPath.row]))
    }
}
