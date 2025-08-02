//
//  TestDataFactory.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 01/08/25.
//

import Foundation
@testable import MusicPlayer

final class TestDataFactory {
    static func createSongSearchResponse(withSongCount count: Int = 2) -> Data {
        let songs = (1...count).map { index in
             """
             {
                 "trackId": \(index),
                 "collectionId": \(index),
                 "trackName": "Song \(index)",
                 "artistName": "Artist \(index)",
                 "collectionName": "Album \(index)",
                 "trackNumber": \(index),
                 "trackCount": \(count),
                 "releaseDate": "2025-01-01T00:00:00Z",
                 "primaryGenreName": "Rock",
                 "previewUrl": "https://example.com/preview\(index).m4a",
                 "artworkUrl30": "https://example.com/artwork30_\(index).jpg",
                 "artworkUrl60": "https://example.com/artwork60_\(index).jpg",
                 "artworkUrl100": "https://example.com/artwork100_\(index).jpg",
                 "collectionPrice": 9.99,
                 "trackPrice": 1.29,
                 "currency": "USD"
             }
             """
        }

        let jsonString = """
         {
             "resultCount": \(count),
             "results": [\(songs.joined(separator: ","))]
         }
         """

        return jsonString.data(using: .utf8)!
    }

    static func createAlbumLookupResponse() -> Data {
        let jsonString = """
            {
                "resultCount": 3,
                "results": [
                    {
                        "wrapperType": "collection",
                        "collectionType": "Album",
                        "collectionId": 123456,
                        "collectionName": "Test Album",
                        "artistName": "Test Artist",
                        "collectionPrice": 9.99,
                        "releaseDate": "2025-01-01T00:00:00Z",
                        "primaryGenreName": "Rock",
                        "artworkUrl60": "https://example.com/album_artwork60.jpg",
                        "artworkUrl100": "https://example.com/album_artwork100.jpg",
                        "trackCount": 2
                    },
                    {
                        "wrapperType": "track",
                        "trackId": 1,
                        "collectionId": 123456,
                        "trackName": "Track 1",
                        "artistName": "Test Artist",
                        "collectionName": "Test Album",
                        "trackNumber": 1,
                        "trackCount": 2,
                        "releaseDate": "2025-01-01T00:00:00Z",
                        "primaryGenreName": "Rock",
                        "previewUrl": "https://example.com/preview1.m4a",
                        "artworkUrl30": "https://example.com/artwork30_1.jpg",
                        "artworkUrl60": "https://example.com/artwork60_1.jpg",
                        "artworkUrl100": "https://example.com/artwork100_1.jpg",
                        "collectionPrice": 9.99,
                        "trackPrice": 1.29,
                        "currency": "USD"
                    },
                    {
                        "wrapperType": "track",
                        "trackId": 2,
                        "collectionId": 123456,
                        "trackName": "Track 2",
                        "artistName": "Test Artist",
                        "collectionName": "Test Album",
                        "trackNumber": 2,
                        "trackCount": 2,
                        "releaseDate": "2025-01-01T00:00:00Z",
                        "primaryGenreName": "Rock",
                        "previewUrl": "https://example.com/preview2.m4a",
                        "artworkUrl30": "https://example.com/artwork30_2.jpg",
                        "artworkUrl60": "https://example.com/artwork60_2.jpg",
                        "artworkUrl100": "https://example.com/artwork100_2.jpg",
                        "collectionPrice": 9.99,
                        "trackPrice": 1.29,
                        "currency": "USD"
                    }
                ]
            }
            """

        return jsonString.data(using: .utf8)!
    }

    static func createInvalidJSON() -> Data {
        return "{ invalid json }".data(using: .utf8)!
    }

    static func createEmptyResponse() -> Data {
        return """
            {
                "resultCount": 0,
                "results": []
            }
            """.data(using: .utf8)!
    }

    static func createMalformedResponse() -> Data {
        return """
        {
            "resultCount": 1,
            "results": [
                {
                    "wrapperType": "track"
                }
            ]
        }
        """.data(using: .utf8)!
    }

    static func createTestSongs(count: Int, startingId: Int = 1, collectionId: Int? = nil) -> [Song] {
        return (startingId..<(startingId + count)).map { id in
            Song(trackId: id,
                 collectionId: collectionId ?? id,
                 artistName: "Test Artist \(id)",
                 trackName: "Test Song \(id)",
                 artworkUrl60: "https://example.com/artwork60_\(id).jpg",
                 artworkUrl100: "https://example.com/artwork100_\(id).jpg",
                 previewUrl: "https://example.com/preview\(id).m4a",
                 collectionName: "Test Album \(id)",
                 trackNumber: 10)
        }
    }

    static func createTestAlbumData(albumId: Int = 123456, trackCount: Int = 3) -> AlbumData {
        let album = Album(collectionId: albumId,
                          collectionName: "Test Album",
                          artistName: "Test Artist",
                          artworkUrl100: "https://example.com/album_artwork100.jpg")

        let tracks = createTestSongs(count: trackCount)

        return AlbumData(album: album, tracks: tracks)
    }

    static func createTestSong(collectionId: Int = 12345) -> Song {
        createTestSongs(count: 1, collectionId: collectionId)[0]
    }
}
