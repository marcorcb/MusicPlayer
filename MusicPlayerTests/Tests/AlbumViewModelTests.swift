//
//  AlbumViewModelTests.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 01/08/25.
//

import Testing
import Foundation
@testable import MusicPlayer

struct AlbumViewModelTests : ~Copyable {

    // MARK: - Public properties

    var searchServiceMock: ItunesSearchServiceMock!
    var playerManager: MusicPlayerManager!
    var testSong: Song!
    var viewModel: AlbumViewModel!

    // MARK: - Initialization

    init(){
        searchServiceMock = ItunesSearchServiceMock()
        playerManager = MusicPlayerManager()
        testSong = TestDataFactory.createTestSong(collectionId: 12345)
    }

    deinit {
        searchServiceMock.reset()
    }

    // MARK: - Private methods

    // Helper method to create viewModel with mocked auto loading
    private mutating func createViewModel(shouldAutoLoad: Bool = false) {
        if shouldAutoLoad {
            let albumData = TestDataFactory.createTestAlbumData(albumId: testSong.collectionId)
            searchServiceMock.setAlbumResult(albumData)
        }

        viewModel = AlbumViewModel(
            selectedSong: testSong,
            playerManager: playerManager,
            itunesSearchService: searchServiceMock
        )
    }

    // MARK: - Tests

    @Test("Initialization with auto load")
    mutating func test_initialization_withAutoLoad() async throws {
        let expectedAlbumData = TestDataFactory.createTestAlbumData(albumId: testSong.collectionId, trackCount: 3)
        searchServiceMock.setAlbumResult(expectedAlbumData)

        createViewModel(shouldAutoLoad: true)

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 3)
        #expect(viewModel.album != nil)
        #expect(viewModel.album?.album.collectionName == expectedAlbumData.album.collectionName)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)

        #expect(searchServiceMock.callCount == 1)
        #expect(searchServiceMock.lastAlbumID == testSong.collectionId)
    }

    @Test("Initialization")
    mutating func test_initialization() async throws {
        createViewModel(shouldAutoLoad: false)

        #expect(viewModel.songs.count == 0)
        #expect(viewModel.album == nil)
        #expect(viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Load album songs success")
    mutating func test_loadAlbumSongs_success() async throws {
        createViewModel(shouldAutoLoad: false)

        let expectedAlbumData = TestDataFactory.createTestAlbumData(albumId: testSong.collectionId, trackCount: 4)
        // Reset from init call
        searchServiceMock.reset()
        searchServiceMock.setAlbumResult(expectedAlbumData)

        viewModel.loadAlbumSongs()

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 4)
        #expect(viewModel.album != nil)
        #expect(viewModel.album?.album.collectionName == expectedAlbumData.album.collectionName)
        #expect(viewModel.album?.tracks.count == 4)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)

        #expect(searchServiceMock.callCount == 1)
        #expect(searchServiceMock.lastAlbumID == testSong.collectionId)
    }

    @Test("Load album songs error")
    mutating func test_loadAlbumSongs_error() async throws {
        createViewModel(shouldAutoLoad: false)
        let testError = NetworkingError.otherError(innerError: NSError(
            domain: "TestError",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "Album not found"]
        ))
        searchServiceMock.setError(testError)

        try? await Task.sleep(nanoseconds: 100_000_000)

        // Reset and setup error
        searchServiceMock.reset()
        searchServiceMock.setError(testError)

        viewModel.loadAlbumSongs()

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 0)
        #expect(viewModel.album == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)

        #expect(searchServiceMock.callCount == 1)
    }

    @Test("Load album songs loading state")
    mutating func test_loadAlbumSongs_loadingState() async throws {
        createViewModel(shouldAutoLoad: false)
        let albumData = TestDataFactory.createTestAlbumData()
        searchServiceMock.setAlbumResult(albumData)
        searchServiceMock.fetchDelay = 0.5

        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)
        }

        viewModel.loadAlbumSongs()

        #expect(viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Load album songs prevents concurrent loads")
    mutating func test_loadAlbumSongs_preventsDuringLoading() async throws {
        createViewModel(shouldAutoLoad: false)
        let albumData = TestDataFactory.createTestAlbumData()
        searchServiceMock.setAlbumResult(albumData)
        searchServiceMock.fetchDelay = 0.2

        try? await Task.sleep(nanoseconds: 300_000_000)

        // Reset call count
        searchServiceMock.callCount = 0

        // Start first load
        viewModel.loadAlbumSongs()
        #expect(viewModel.isLoading)

        // Try to start second load while first is loading
        viewModel.loadAlbumSongs()

        try? await Task.sleep(nanoseconds: 300_000_000)

        #expect(searchServiceMock.callCount == 1)
    }

    @Test("Load album songs clears error on new load")
    mutating func test_loadAlbumSongs_clearsErrorOnNewLoad() async throws {
        createViewModel(shouldAutoLoad: false)

        // First load with error
        let testError = NetworkingError.otherError(innerError: NSError(
            domain: "TestError",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Server error"]
        ))
        searchServiceMock.setError(testError)

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.errorMessage != nil)

        let albumData = TestDataFactory.createTestAlbumData()
        searchServiceMock.reset()
        searchServiceMock.setAlbumResult(albumData)

        viewModel.loadAlbumSongs()
        #expect(viewModel.errorMessage == nil)

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.album != nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Refresh album songs")
    mutating func test_refreshAlbumSongs() async throws {
        createViewModel(shouldAutoLoad: true)
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.album != nil)
        #expect(viewModel.songs.count > 0)

        // Setup new data for refresh
        let newAlbumData = TestDataFactory.createTestAlbumData(albumId: testSong.collectionId, trackCount: 5)
        searchServiceMock.reset()
        searchServiceMock.setAlbumResult(newAlbumData)

        viewModel.refreshAlbumSongs()

        // Immediate reset
        #expect(viewModel.album == nil)
        #expect(viewModel.songs.count == 0)
        #expect(viewModel.isLoading)

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.album != nil)
        #expect(viewModel.songs.count == 5)
        #expect(viewModel.isLoading == false)
        #expect(searchServiceMock.callCount == 1)
    }

    @Test("Refresh album songs error")
    mutating func test_refreshAlbumSongs_error() async throws {
        let initialAlbumData = TestDataFactory.createTestAlbumData()
        searchServiceMock.setAlbumResult(initialAlbumData)
        createViewModel(shouldAutoLoad: true)
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.album != nil)

        // Setup error for refresh
        let testError = NetworkingError.otherError(innerError: NSError(
            domain: "RefreshError",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Refresh failed"]
        ))
        searchServiceMock.reset()
        searchServiceMock.setError(testError)

        viewModel.refreshAlbumSongs()
        #expect(viewModel.album == nil)
        #expect(viewModel.songs.count == 0)

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.album == nil)
        #expect(viewModel.songs.count == 0)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
    }

    @Test("Songs sorting")
    mutating func test_songsSorting() async throws {
        let album = Album(
            collectionId: testSong.collectionId,
            collectionName: "Test Album",
            artistName: "Test Artist",
            artworkUrl100: "https://example.com/album_artwork100.jpg"
        )

        // Create tracks in reverse order
        let unsortedTracks = [
            Song(trackId: 3,
                 collectionId: testSong.collectionId,
                 artistName: "Test Artist",
                 trackName: "Track 3",
                 artworkUrl60: "",
                 artworkUrl100: "",
                 previewUrl: nil,
                 collectionName: "Test Album",
                 trackNumber: 3),
            Song(trackId: 1,
                 collectionId: testSong.collectionId,
                 artistName: "Test Artist",
                 trackName: "Track 1",
                 artworkUrl60: "",
                 artworkUrl100: "",
                 previewUrl: nil,
                 collectionName: "Test Album",
                 trackNumber: 1),
            Song(trackId: 2,
                 collectionId: testSong.collectionId,
                 artistName: "Test Artist",
                 trackName: "Track 2",
                 artworkUrl60: "",
                 artworkUrl100: "",
                 previewUrl: nil,
                 collectionName: "Test Album",
                 trackNumber: 2)
        ]

        createViewModel(shouldAutoLoad: false)

        let albumData = AlbumData(album: album, tracks: unsortedTracks)
        searchServiceMock.setAlbumResult(albumData)

        viewModel.loadAlbumSongs()

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 3)
        #expect(viewModel.songs[0].trackNumber == 1)
        #expect(viewModel.songs[1].trackNumber == 2)
        #expect(viewModel.songs[2].trackNumber == 3)
        #expect(viewModel.songs[0].trackName == "Track 1")
        #expect(viewModel.songs[1].trackName == "Track 2")
        #expect(viewModel.songs[2].trackName == "Track 3")
    }

    @Test("Empty tracks in album")
    mutating func test_emptyTracksInAlbum() async throws {
        let album = Album(
            collectionId: testSong.collectionId,
            collectionName: "Empty Album",
            artistName: "Test Artist",
            artworkUrl100: "https://example.com/artwork100.jpg"
        )

        createViewModel(shouldAutoLoad: false)

        let albumData = AlbumData(album: album, tracks: [])
        searchServiceMock.setAlbumResult(albumData)

        viewModel.loadAlbumSongs()

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 0)
        #expect(viewModel.album != nil)
        #expect(viewModel.album?.album.collectionName == album.collectionName)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Complete album flow")
    mutating func test_completeAlbumFlow() async throws {
        createViewModel(shouldAutoLoad: false)

        let albumData = TestDataFactory.createTestAlbumData(trackCount: 4)
        searchServiceMock.setAlbumResult(albumData)

        // Initial load
        viewModel.loadAlbumSongs()
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 4)
        #expect(viewModel.album != nil)
        #expect(viewModel.isLoading == false)

        // Refresh
        viewModel.refreshAlbumSongs()
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 4)
        #expect(viewModel.album != nil)
        #expect(viewModel.isLoading == false)

        // Error scenario
        searchServiceMock.reset()
        searchServiceMock.setError(NetworkingError.otherError(innerError: NSError(
            domain: "NetworkError",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Network failed"]
        )))

        viewModel.refreshAlbumSongs()
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 0)
        #expect(viewModel.album == nil)
        #expect(viewModel.isLoading == false)
    }
}
