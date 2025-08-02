//
//  ItunesSearchServiceMock.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 01/08/25.
//

import Foundation
@testable import MusicPlayer

final class ItunesSearchServiceMock: ItunesSearchServiceProtocol {
    // Songs
    var searchResult: [Song] = []
    var lastSearchTerm: String?
    var lastOffset: Int?
    var lastLimit: Int?

    // Album
    var albumResult: AlbumData?
    var lastAlbumID: Int?

    var shouldThrowError = false
    var errorToThrow: Error = NetworkingError.otherError(innerError: NSError(domain: "Test", code: 500))
    var callCount = 0

    func searchSongs(term: String, offset: Int, limit: Int) async throws -> [Song] {
        callCount += 1
        lastSearchTerm = term
        lastOffset = offset
        lastLimit = limit

        if shouldThrowError {
            throw errorToThrow
        }

        return searchResult
    }

    func fetchSongsFromAlbum(albumID: Int) async throws -> AlbumData {
        callCount += 1
        lastAlbumID = albumID

        if shouldThrowError {
            throw errorToThrow
        }

        guard let result = albumResult else {
            throw NetworkingError.otherError(innerError: NSError(
                domain: "TestError",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Album not found"]
            ))
        }

        return result
    }

    func reset() {
        searchResult = []
        albumResult = nil
        shouldThrowError = false
        callCount = 0
        lastSearchTerm = nil
        lastAlbumID = nil
        lastOffset = nil
        lastLimit = nil
    }

    func setSearchResult(_ songs: [Song]) {
        searchResult = songs
    }

    func setAlbumResult(_ album: AlbumData) {
        albumResult = album
    }

    func setError(_ error: Error) {
        shouldThrowError = true
        errorToThrow = error
    }
}
