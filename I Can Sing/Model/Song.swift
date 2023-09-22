//
//  Song.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import Foundation

typealias SongID = UUID

struct Song {
    let id: UUID
    let name: String
    let artist: String
    let lyrics: String
}
