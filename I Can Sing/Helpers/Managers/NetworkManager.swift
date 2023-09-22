//
//  NetworkManager.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import Foundation
import SwiftSoup

class NetworkManager {
    
    private var baseURL = "https://search.azlyrics.com"
    
    enum NetworkManagerError: Error {
        case invalidURL
        case dataNotFound
    }
    
}

// MARK: - SongSearchable
protocol SongSearchable {
    func searchSongs(for query: String) async throws -> SearchSongResponse
    func fetchSong(for songResponse: SongResponse) async throws -> Song
}

extension NetworkManager: SongSearchable {
    func searchSongs(for query: String) async throws -> SearchSongResponse {
        let urlString = "\(baseURL)/suggest.php?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: urlString) else {
            throw NetworkManagerError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(SearchSongResponse.self, from: data)
    }
    
    func fetchSong(for songResponse: SongResponse) async throws -> Song {
        guard let url = URL(string: songResponse.url) else {
            throw NetworkManagerError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let contents = String(data: data, encoding: .utf8), let (name, artist) = parseSongAutoComplete(songResponse.autocomplete) {
            let lyrics = try parseLyrics(from: contents, response)
            return Song(id: UUID(), name: name, artist: artist, lyrics: lyrics)
        } else {
            throw NetworkManagerError.dataNotFound
        }
    }
    
}

extension NetworkManager {
    static var copyRightLabelContent: String {
        "<!-- Usage of azlyrics.com content by any third-party lyrics provider is prohibited by our licensing agreement. Sorry about that. -->"
    }
    
    private func parseLyrics(from html: String, _ response: URLResponse) throws -> String {
        let doc = try SwiftSoup.parse(html)
        let divsWithNoClassOrAttributes = try doc.select("div:not([class]):not([*])")       // lyrics div
        
        guard let div = divsWithNoClassOrAttributes.first(where: { $0.hasText() }) else { return "" }
        
        let html = try div.html()
            .replacingOccurrences(of: NetworkManager.copyRightLabelContent, with: "")
            .replacingOccurrences(of: "<br>", with: "\n")
        
        return html
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
}
    
// MARK: - Models
struct SearchSongResponse: Decodable {
    let term: String
    let songs: [SongResponse]
}

struct SongResponse: Decodable {
    let url: String
    let autocomplete: String
}
