//
//  ItunesSearchServiceTests.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 01/08/25.
//

import Testing
import Foundation
@testable import MusicPlayer

struct ItunesSearchServiceTests : ~Copyable {

    // MARK: - Public properties

    var urlSessionMock: URLSessionMock!
    var itunesService: ItunesSearchService!

    // MARK: - Initialization

    init() {
        urlSessionMock = URLSessionMock()
        itunesService = ItunesSearchService(urlSession: urlSessionMock)
    }
    
    deinit {
        urlSessionMock.reset()
    }

    // MARK: - Tests

    @Test("Search songs success")
    func test_searchSongs_success() async throws {
        let expectedTerm = "Beatles"
        let expectedOffset = 0
        let expectedLimit = 50
        let mockData = TestDataFactory.createSongSearchResponse(withSongCount: 2)
        urlSessionMock.setSuccess(data: mockData)
        
        let result = try await itunesService.searchSongs(
            term: expectedTerm,
            offset: expectedOffset,
            limit: expectedLimit
        )
        
        #expect(result.count == 2)
        #expect(result[0].trackName == "Song 1")
        #expect(result[0].artistName == "Artist 1")
        #expect(result[1].trackName == "Song 2")
        #expect(result[1].artistName == "Artist 2")
        #expect(urlSessionMock.requestCount == 1)
        
        let requestedURL = try #require(urlSessionMock.requestedURL)
        
        #expect(requestedURL.scheme == "https")
        #expect(requestedURL.host == "itunes.apple.com")
        #expect(requestedURL.path == "/search")
        
        let urlComponents = URLComponents(url: requestedURL, resolvingAgainstBaseURL: false)
        let queryItems = urlComponents?.queryItems ?? []
        
        #expect(queryItems.contains(URLQueryItem(name: "term", value: expectedTerm)))
        #expect(queryItems.contains(URLQueryItem(name: "media", value: "music")))
        #expect(queryItems.contains(URLQueryItem(name: "entity", value: "song")))
        #expect(queryItems.contains(URLQueryItem(name: "limit", value: String(expectedLimit))))
        #expect(queryItems.contains(URLQueryItem(name: "offset", value: String(expectedOffset))))
    }
    
    @Test("Search songs empty results")
    func test_searchSongs_emptyResults() async throws {
        let mockData = TestDataFactory.createEmptyResponse()
        urlSessionMock.setSuccess(data: mockData)
        
        let result = try await itunesService.searchSongs(term: "Nonexistent Artist", offset: 0, limit: 50)
        
        #expect(result.count == 0)
        #expect(urlSessionMock.requestCount == 1)
    }
    
    @Test("Search songs network error")
    func test_searchSongs_networkError() async throws {
        let networkError = URLError(.notConnectedToInternet)
        urlSessionMock.setError(networkError)
        
        await #expect {
            try await itunesService.searchSongs(term: "Beatles", offset: 0, limit: 50)
        } throws: { error in
            guard let error = error as? NetworkingError else {
                return false
            }
            
            switch error {
                case .urlMalformed:
                    return false
                case .otherError(let innerError):
                    let urlError = innerError as! URLError
                    #expect(innerError is URLError)
                    #expect(urlError.code == .notConnectedToInternet)
                    #expect(urlSessionMock.requestCount == 1)
                    return true
            }
        }
    }
    
    @Test("Search songs invalid JSON")
    func test_searchSongs_invalidJSON() async throws {
        let invalidData = TestDataFactory.createInvalidJSON()
        urlSessionMock.setSuccess(data: invalidData)
        
        await #expect {
            try await itunesService.searchSongs(term: "Beatles", offset: 0, limit: 50)
        } throws: { error in
            guard let error = error as? NetworkingError else {
                return false
            }
            
            switch error {
                case .urlMalformed:
                    return false
                case .otherError(let innerError):
                    #expect(innerError is DecodingError)
                    return true
            }
        }
    }
    
    @Test("Fetch songs from album success")
    func test_fetchSongsFromAlbum_success() async throws {
        let albumID = 123456
        let mockData = TestDataFactory.createAlbumLookupResponse()
        urlSessionMock.setSuccess(data: mockData)
        
        let result = try await itunesService.fetchSongsFromAlbum(albumID: albumID)
        
        #expect(result.album.collectionName == "Test Album")
        #expect(result.album.artistName == "Test Artist")
        #expect(result.tracks.count == 2)
        #expect(result.tracks[0].trackName == "Track 1")
        #expect(result.tracks[1].trackName == "Track 2")
        #expect(urlSessionMock.requestCount == 1)
        
        let requestedURL = try #require(urlSessionMock.requestedURL)
        
        #expect(requestedURL.scheme == "https")
        #expect(requestedURL.host == "itunes.apple.com")
        #expect(requestedURL.path == "/lookup")
        
        let urlComponents = URLComponents(url: requestedURL, resolvingAgainstBaseURL: false)
        let queryItems = urlComponents?.queryItems ?? []
        
        #expect(queryItems.contains(URLQueryItem(name: "id", value: String(albumID))))
        #expect(queryItems.contains(URLQueryItem(name: "entity", value: "song")))
        #expect(queryItems.contains(URLQueryItem(name: "limit", value: "200")))
    }
    
    @Test("Fetch songs from album not found")
    func test_fetchSongsFromAlbum_notFound() async throws {
        let mockData = TestDataFactory.createEmptyResponse()
        urlSessionMock.setSuccess(data: mockData)
        
        await #expect {
            try await itunesService.fetchSongsFromAlbum(albumID: 123456)
        } throws: { error in
            guard let error = error as? NetworkingError else {
                return false
            }
            
            switch error {
                case .urlMalformed:
                    return false
                case .otherError(let innerError):
                    let nsError = innerError as NSError
                    #expect(nsError.domain == "AlbumLookup")
                    #expect(nsError.code == 404)
                    #expect(nsError.localizedDescription == "Album collection not found")
                    return true
            }
        }
    }
    
    @Test("Fetch songs from album network error")
    func test_fetchSongsFromAlbum_networkError() async throws {
        let networkError = URLError(.timedOut)
        urlSessionMock.setError(networkError)
        
        await #expect {
            try await itunesService.fetchSongsFromAlbum(albumID: 123456)
        } throws: { error in
            guard let error = error as? NetworkingError else {
                return false
            }
            
            switch error {
                case .urlMalformed:
                    return false
                case .otherError(let innerError):
                    #expect(innerError is URLError)
                    let urlError = innerError as! URLError
                    #expect(urlError.code == .timedOut)
                    return true
            }
        }
    }
    
    @Test("Search songs with special characters")
    func testSearchSongs_WithSpecialCharacters() async throws {
        let termWithSpecialChars = "AC/DC & Metallica"
        let mockData = TestDataFactory.createSongSearchResponse(withSongCount: 1)
        urlSessionMock.setSuccess(data: mockData)
        
        let result = try await itunesService.searchSongs(term: termWithSpecialChars, offset: 0, limit: 50)
        
        #expect(result.count == 1)
        
        let requestedURL = try #require(urlSessionMock.requestedURL)
        
        let urlComponents = URLComponents(url: requestedURL, resolvingAgainstBaseURL: false)
        let termQueryItem = urlComponents?.queryItems?.first { $0.name == "term" }
        #expect(termQueryItem?.value == termWithSpecialChars)
    }
    
    @Test("Multiple search sequential calls")
    func test_multipleSearchSequentialCalls() async throws {
        let mockData = TestDataFactory.createSongSearchResponse(withSongCount: 1)
        urlSessionMock.setSuccess(data: mockData)
        
        let result1 = try await itunesService.searchSongs(term: "Beatles", offset: 0, limit: 50)
        let result2 = try await itunesService.searchSongs(term: "Queen", offset: 0, limit: 50)
        let result3 = try await itunesService.searchSongs(term: "Metallica", offset: 0, limit: 50)
        
        #expect(result1.count == 1)
        #expect(result2.count == 1)
        #expect(result3.count == 1)
        #expect(urlSessionMock.requestCount == 3)
    }
}
