//
//  ExploreViewModel.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import UIKit
import RxSwift
import RxRelay

class ExploreViewModel: Base.ViewModel {
    
    private let networkManager: NetworkManager
    private let databaseManager: DatabaseManager
    
    let songs: BehaviorRelay<[SongResponse]> = BehaviorRelay(value: [])
    let isFetching = BehaviorRelay(value: false)
    
    init(networkManager: NetworkManager, databaseManager: DatabaseManager) {
        self.networkManager = networkManager
        self.databaseManager = databaseManager
    }
}

extension ExploreViewModel {
    func searchSongs(for keyword: String) async {
        isFetching.accept(true)
        
        do {
            let result = try await networkManager.searchSongs(for: keyword)
            isFetching.accept(false)
            songs.accept(result.songs)
        } catch {
            // TODO: - Show error here
            print(error.localizedDescription)
            isFetching.accept(false)
        }
    }
    
    func makeSongViewController(at indexPath: IndexPath) -> SongViewController? {
        guard songs.value.count >= indexPath.row else { return nil }
        return SongViewController(viewModel: SongViewModel(networkManager: networkManager,
                                                           databaseManager: databaseManager,
                                                           songResponse: songs.value[indexPath.row]))
    }
}
