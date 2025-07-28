//
//  Music.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

struct MusicResponse: Decodable {
    let results: [Music]
}

struct Music: Decodable {
    let trackId: Int
    let artistName: String
    let trackName: String
    let artworkUrl60: String
    let artworkUrl100: String
}
