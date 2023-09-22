//
//  DatabaseManager.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import Foundation
import UIKit
import RealmSwift

class DatabaseManager {
    
    internal let realm: Realm

    public convenience init() throws {
        try self.init(realm: Realm())
    }

    internal init(realm: Realm) {
        self.realm = realm
//        setup()
    }
}

extension DatabaseManager {
    
    func loadAnnotatedSongs() -> [AnnotatedSong] {
        let songs = realm
            .objects(AnnotatedSongObject.self)
            .map({ AnnotatedSong(managedObject: $0) })
            .sorted(by: { $0.lastUpdated > $1.lastUpdated })
        return Array(songs)
    }
    
    func loadAnnotatedSong(for id: SongID) -> AnnotatedSong? {
        return realm
            .objects(AnnotatedSongObject.self)
            .first(where: { $0.id == id })
            .map({ AnnotatedSong(managedObject: $0) })
    }
    
    func addSong(_ song: Song) throws {
        try realm.write({
            let _ = realm.create(AnnotatedSongObject.self,
                                 value: AnnotatedSong(song: song).managedObject())
        })
    }
    
    func saveAnnotatedSong(_ annotatedSong: AnnotatedSong) throws {
        try realm.write {
            realm.add(annotatedSong.managedObject(), update: .modified)
        }
    }
    
    func deleteAnnotatedSong(for id: SongID) throws {
        guard let object = realm.objects(AnnotatedSongObject.self).where({ $0.id == id }).first else { return }
        realm.delete(object)
    }
    
}
