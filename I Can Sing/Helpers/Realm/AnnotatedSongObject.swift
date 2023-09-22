//
//  AnnotatedSongObject.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import Foundation
import RealmSwift

final class AnnotatedSongObject: Object {
    override class func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: UUID = UUID()
    @objc dynamic var name = ""
    @objc dynamic var artist = ""
    @objc dynamic var lyrics = ""
    dynamic var notes = List<AnnotatedSongNoteObject>()
    @objc dynamic var lastUpdated = Date.now
    
    convenience init(annotatedSong: AnnotatedSong) {
        self.init()
        self.id = annotatedSong.id
        self.name = annotatedSong.name
        self.artist = annotatedSong.artist
        self.lyrics = annotatedSong.lyrics
        self.notes = annotatedSong.notes.values.reduce(into: List<AnnotatedSongNoteObject>(), { $0.append($1.managedObject()) })
        self.lastUpdated = annotatedSong.lastUpdated
    }
}


final class AnnotatedSongNoteObject: Object {
    override class func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: UUID = UUID()
    @objc dynamic var location = 0
    @objc dynamic var length = 0
    @objc dynamic var note = ""
    
    convenience init(id: UUID, range: NSRange, note: String = "") {
        self.init()
        self.id = id
        self.location = range.location
        self.length = range.length
        self.note = note
    }
}
