//
//  DataProviderTests.swift
//  I Can SingTests
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import XCTest
@testable import I_Can_Sing

final class DataProviderTests: XCTestCase {

    func testSearchingLyrics() async {
        do {
            let result = try await DataProvider().searchSongs(for: "say you say me")
            print(result)
            XCTAssertEqual(result.songs.count, 5)
        } catch {
            print(error)
        }
    }
    
    func testFetchSongLyrics() async {
        do {
            let result = try await DataProvider().fetchSong(for: SongResponse(url: "https://www.azlyrics.com/lyrics/lionelrichie/sayyousayme.html", autocomplete: "\"Say You, Say Me\"  - Lionel Richie"))
            print(result)
            XCTAssertNotEqual(result.lyrics, "")
        } catch {
            print(error)
        }
    }

}
