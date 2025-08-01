//
//  Song.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

struct SongSearchResponse: Decodable {
    let results: [Song]
}

struct Song: Decodable, Hashable {
    let trackId: Int
    let collectionId: Int
    let artistName: String
    let trackName: String
    let artworkUrl60: String
    let artworkUrl100: String
    let previewUrl: String?
    let collectionName: String
    let trackNumber: Int?

    var trackNumberString: String {
        String(trackNumber ?? 0)
    }
}

extension Song: Identifiable {
    var id: Int { trackId }
}
