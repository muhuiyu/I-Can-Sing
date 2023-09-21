//
//  DataProvider.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import Foundation
import SwiftSoup

class DataProvider {
    
    private var baseURL = "https://search.azlyrics.com"
    
    enum DataProviderError: Error {
        case invalidURL
        case dataNotFound
    }
    
}

extension DataProvider {
    
    func searchSongs(for query: String) async throws -> SearchSongResponse {
        
        let urlString = "\(baseURL)/suggest.php?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: urlString) else {
            throw DataProviderError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(SearchSongResponse.self, from: data)
    }
    
    func fetchSong(for songResponse: SongResponse) async throws -> Song {
        guard let url = URL(string: songResponse.url) else {
            throw DataProviderError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let contents = String(data: data, encoding: .utf8), let (name, artist) = parseSongAutoComplete(songResponse.autocomplete) {
            let lyrics = try parseLyrics(from: contents, response)
            return Song(name: name, artist: artist, lyrics: lyrics)
        } else {
            throw DataProviderError.dataNotFound
        }
    }
    
}

extension DataProvider {
    private func parseLyrics(from html: String, _ response: URLResponse) throws -> String {
        do {
            let doc = try SwiftSoup.parse(html)
            let divsWithNoClassOrAttributes = try doc.select("div:not([class]):not([*])")       // lyrics div
            print(divsWithNoClassOrAttributes.count)
            
            if let div = divsWithNoClassOrAttributes.first(where: { $0.hasText() }) {
                let html = try div.html().replacingOccurrences(of: "<!-- Usage of azlyrics.com content by any third-party lyrics provider is prohibited by our licensing agreement. Sorry about that. -->", with: "").replacingOccurrences(of: "<br>", with: "\n")
                return html
            } else {
                return ""
            }
            
        } catch {
            print("An error occurred: \(error)")
            throw error
        }
    }
    
    private func parseSongAutoComplete(_ input: String) -> (songName: String, artistName: String)? {
        // Find the last occurrence of " - " to split the string
        if let range = input.range(of: " - ", options: .backwards) {
            let songName = String(input[..<range.lowerBound])
            let artistName = String(input[range.upperBound...])

            return (songName.trimmingCharacters(in: .whitespaces), artistName.trimmingCharacters(in: .whitespaces))
        } else {
            return nil
        }
    }

    
//    override internal func parsePopularManga(from element: Element) -> SourceManga? {
//        do {
//            guard let linkSelector = popularMangaSelector.link, let titleSelector = popularMangaSelector.title, let thumbnailSelector = popularMangaSelector.image else { return nil }
//
//            let urlString = try element.select(linkSelector).attr("href")
//            guard let url = URL(string: urlString) else { return nil }
//            let title = try element.select(titleSelector).text()
//            let thumbnailURLString = try element.select(thumbnailSelector[0]).attr(thumbnailSelector[1])
//            print("parsed", title, urlString, thumbnailURLString)
//            guard !title.isEmpty && !thumbnailURLString.isEmpty else { return nil }
//            return SourceManga(url: url.absoluteString, title: title, thumbnailURL: thumbnailURLString, sourceID: sourceID)
//        } catch {
//            return nil
//        }
//    }
}


//extension DataProvider: SongDetailsFetchable, SongSearchable {
//
//}
//
//protocol SongSearchable {
//    func searchSongs(for query: String) async throws -> SearchSongResponse
//}
//
//protocol SongDetailsFetchable {
//    func fetchSong(for songResponse: SongResponse) -> Song
//}
//



struct SearchSongResponse: Decodable {
    let term: String
    let songs: [SongResponse]
}

struct SongResponse: Decodable {
    let url: String
    let autocomplete: String
}

struct Song {
    let name: String
    let artist: String
    let lyrics: String
}
