//
//  Extensions.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 31/07/25.
//

import Foundation
import Testing
@testable import MusicPlayer

extension Song {
    static func mock(
        trackId: Int = 1,
        collectionId: Int = 1,
        artistName: String = "Test Artist",
        trackName: String = "Test Song",
        artworkUrl60: String = "https://example.com/artwork60.jpg",
        artworkUrl100: String = "https://example.com/artwork100.jpg",
        previewUrl: String? = "https://example.com/preview.mp3",
        collectionName: String = "Test Collection",
        trackNumber: Int? = 1
    ) -> Song {
        Song(trackId: trackId,
             collectionId: collectionId,
             artistName: artistName,
             trackName: trackName,
             artworkUrl60: artworkUrl60,
             artworkUrl100: artworkUrl100,
             previewUrl: previewUrl,
             collectionName: collectionName,
             trackNumber: trackNumber)
    }
}

extension Tag {
    @Tag static var progress: Self
    @Tag static var timeFormatter: Self
}
