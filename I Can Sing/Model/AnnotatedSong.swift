//
//  AnnotatedSong.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import Foundation
import RealmSwift

struct AnnotatedSong {
    let id: SongID
    let name: String
    let artist: String
    let lyrics: String
    var notes: [NSRange: AnnotatedSongNote]
    let lastUpdated: Date
}

extension AnnotatedSong {
    init(song: Song) {
        self.id = song.id
        self.name = song.name
        self.artist = song.artist
        self.lyrics = song.lyrics
        self.notes = [:]
        self.lastUpdated = Date.now
    }
}

extension AnnotatedSong: Persistable {
    init(managedObject: AnnotatedSongObject) {
        self.id = managedObject.id
        self.name = managedObject.name
        self.artist = managedObject.artist
        self.lyrics = managedObject.lyrics
        self.notes = managedObject.notes.reduce(into: [NSRange: AnnotatedSongNote](), {
            $0[NSRange(location: $1.location, length: $1.length)] = AnnotatedSongNote(managedObject: $1)
        })
        self.lastUpdated = managedObject.lastUpdated
    }
    func managedObject() -> AnnotatedSongObject {
        return AnnotatedSongObject(annotatedSong: self)
    }
}

struct AnnotatedSongNote {
    let id: UUID
    var range: NSRange
    var note: String
    
    init(range: NSRange, note: String) {
        self.id = UUID()
        self.range = range
        self.note = note
    }
}

extension AnnotatedSongNote: Persistable {
    init(managedObject: AnnotatedSongNoteObject) {
        self.id = managedObject.id
        self.range = NSRange(location: managedObject.location, length: managedObject.length)
        self.note = managedObject.note
    }
    func managedObject() -> AnnotatedSongNoteObject {
        return AnnotatedSongNoteObject(id: self.id, range: self.range, note: self.note)
    }
}
