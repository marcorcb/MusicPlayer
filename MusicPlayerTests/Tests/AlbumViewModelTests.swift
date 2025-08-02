//
//  AlbumViewModelTests.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 01/08/25.
//

import Testing
import Foundation
@testable import MusicPlayer

@MainActor
struct AlbumViewModelTests: ~Copyable {

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
        viewModel = AlbumViewModel(
            selectedSong: testSong,
            playerManager: playerManager,
            itunesSearchService: searchServiceMock
        )
    }

    deinit {
        searchServiceMock.reset()
    }

    // MARK: - Tests

    @Test("Initialization")
    func test_initialization() async throws {
        #expect(viewModel.songs.count == 0)
        #expect(viewModel.album == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Load album songs success")
    func test_loadAlbumSongs_success() async throws {
        let expectedAlbumData = TestDataFactory.createTestAlbumData(albumId: testSong.collectionId, trackCount: 4)
        searchServiceMock.setAlbumResult(expectedAlbumData)

        await viewModel.loadAlbumSongs()

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
    func test_loadAlbumSongs_error() async throws {

        let testError = NetworkingError.otherError(innerError: NSError(
            domain: "TestError",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "Album not found"]
        ))
        searchServiceMock.setError(testError)

        await viewModel.loadAlbumSongs()

        #expect(viewModel.songs.count == 0)
        #expect(viewModel.album == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)

        #expect(searchServiceMock.callCount == 1)
    }

    @Test("Load album songs loading state")
    func test_loadAlbumSongs_loadingState() async throws {
        let albumData = TestDataFactory.createTestAlbumData()
        searchServiceMock.setAlbumResult(albumData)

        await confirmation() { confirmation in
            if viewModel.isLoading == true {
                confirmation()
            }

            if viewModel.errorMessage == nil {
                confirmation()
            }

            await viewModel.loadAlbumSongs()
          }
    }

    @Test("Load album songs prevents concurrent loads")
    func test_loadAlbumSongs_preventsDuringLoading() async throws {
        let albumData = TestDataFactory.createTestAlbumData()
        searchServiceMock.setAlbumResult(albumData)

        let viewModel = self.viewModel

        async let firstLoad: () = viewModel!.loadAlbumSongs()
        async let secondLoad: () = viewModel!.loadAlbumSongs()
        _ = await (firstLoad, secondLoad)

        #expect(searchServiceMock.callCount == 1)
    }

    @Test("Refresh album songs")
    func test_refreshAlbumSongs() async throws {
        let newAlbumData = TestDataFactory.createTestAlbumData(albumId: testSong.collectionId, trackCount: 5)
        searchServiceMock.setAlbumResult(newAlbumData)
        await viewModel.refreshAlbumSongs()

        #expect(viewModel.album != nil)
        #expect(viewModel.songs.count == 5)
        #expect(viewModel.isLoading == false)
        #expect(searchServiceMock.callCount == 1)
    }

    @Test("Refresh album songs error")
    func test_refreshAlbumSongs_error() async throws {
        let initialAlbumData = TestDataFactory.createTestAlbumData()
        searchServiceMock.setAlbumResult(initialAlbumData)

        await viewModel.loadAlbumSongs()

        #expect(viewModel.album != nil)

        // Setup error for refresh
        let testError = NetworkingError.otherError(innerError: NSError(
            domain: "RefreshError",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Refresh failed"]
        ))
        searchServiceMock.reset()
        searchServiceMock.setError(testError)

        await viewModel.refreshAlbumSongs()

        #expect(viewModel.album == nil)
        #expect(viewModel.songs.count == 0)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
    }

    @Test("Songs sorting")
    func test_songsSorting() async throws {
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


        let albumData = AlbumData(album: album, tracks: unsortedTracks)
        searchServiceMock.setAlbumResult(albumData)

        await viewModel.loadAlbumSongs()

        #expect(viewModel.songs.count == 3)
        #expect(viewModel.songs[0].trackNumber == 1)
        #expect(viewModel.songs[1].trackNumber == 2)
        #expect(viewModel.songs[2].trackNumber == 3)
        #expect(viewModel.songs[0].trackName == "Track 1")
        #expect(viewModel.songs[1].trackName == "Track 2")
        #expect(viewModel.songs[2].trackName == "Track 3")
    }

    @Test("Empty tracks in album")
    func test_emptyTracksInAlbum() async throws {
        let album = Album(
            collectionId: testSong.collectionId,
            collectionName: "Empty Album",
            artistName: "Test Artist",
            artworkUrl100: "https://example.com/artwork100.jpg"
        )

        let albumData = AlbumData(album: album, tracks: [])
        searchServiceMock.setAlbumResult(albumData)

        await viewModel.loadAlbumSongs()

        #expect(viewModel.songs.count == 0)
        #expect(viewModel.album != nil)
        #expect(viewModel.album?.album.collectionName == album.collectionName)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Complete album flow")
    func test_completeAlbumFlow() async throws {


        let albumData = TestDataFactory.createTestAlbumData(trackCount: 4)
        searchServiceMock.setAlbumResult(albumData)

        // Initial load
        await viewModel.loadAlbumSongs()

        #expect(viewModel.songs.count == 4)
        #expect(viewModel.album != nil)
        #expect(viewModel.isLoading == false)

        // Refresh
        await viewModel.refreshAlbumSongs()

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

        await viewModel.refreshAlbumSongs()

        #expect(viewModel.songs.count == 0)
        #expect(viewModel.album == nil)
        #expect(viewModel.isLoading == false)
    }
}
