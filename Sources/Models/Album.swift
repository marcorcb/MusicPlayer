//
//  Album.swift
//  MusicPlayer
//
//  Created by Marco Braga on 30/07/25.
//

import Foundation

struct AlbumLookupResponse: Decodable {
    let results: [AlbumItem]
}

enum AlbumItem: Decodable {
    case collection(Album)
    case track(Song)

    private enum CodingKeys: String, CodingKey {
        case wrapperType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let wrapperType = try container.decode(String.self, forKey: .wrapperType)

        switch wrapperType {
        case "collection":
            self = .collection(try Album(from: decoder))
        case "track":
            self = .track(try Song(from: decoder))
        default:
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "Unknown wrapperType: \(wrapperType)")
            )
        }
    }
}

struct Album: Decodable {
    let collectionId: Int
    let collectionName: String
    let artistName: String
    let artworkUrl100: String
}

struct AlbumData {
    let album: Album
    let tracks: [Song]

    var sortedTracks: [Song] {
        tracks.sorted { (track1: Song, track2: Song) -> Bool in
            let trackNumber1 = track1.trackNumber ?? Int.max
            let trackNumber2 = track2.trackNumber ?? Int.max
            return trackNumber1 < trackNumber2
        }
    }

    var albumTitle: String {
        album.collectionName
    }

    var artistName: String {
        album.artistName
    }

    var largeArtworkURL: URL? {
        URL(string: album.artworkUrl100.itunesLargeImageURL())
    }
}
