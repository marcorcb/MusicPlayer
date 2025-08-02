//
//  SongsViewModelTests.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 01/08/25.
//

import Testing
import Foundation
@testable import MusicPlayer

struct SongsViewModelTests : ~Copyable {

    // MARK: - Public properties

    var searchServiceMock: ItunesSearchServiceMock!
    var playerManager: MusicPlayerManager!
    var viewModel: SongsViewModel!

    // MARK: - Initialization

    init(){
        searchServiceMock = ItunesSearchServiceMock()
        playerManager = MusicPlayerManager()
        viewModel = SongsViewModel(
            itunesSearchService: searchServiceMock,
            playerManager: playerManager
        )
    }

    deinit {
        searchServiceMock.reset()
    }

    // MARK: - Tests

    @Test("Initialization")
    func test_initialization() async throws {
        #expect(viewModel.searchText == "")
        #expect(viewModel.songs.count == 0)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.hasMoreResults)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.didSearch == false)
    }

    @Test("Search song success")
    func test_searchSongSuccess() async throws {
        let testSongs = TestDataFactory.createTestSongs(count: 3)
        searchServiceMock.setSearchResult(testSongs)

        let searchTerm = "Beatles"
        viewModel.searchSong(term: searchTerm)

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 3)
        #expect(viewModel.songs[0].trackName == testSongs[0].trackName)
        #expect(viewModel.songs[1].trackName == testSongs[1].trackName)
        #expect(viewModel.songs[2].trackName == testSongs[2].trackName)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.didSearch)
        #expect(viewModel.errorMessage == nil)

        #expect(searchServiceMock.callCount == 1)
        #expect(searchServiceMock.lastSearchTerm == searchTerm)
        #expect(searchServiceMock.lastOffset == 0)
        #expect(searchServiceMock.lastLimit == 50)
    }

    @Test("Search song empty results")
    func test_searchSong_emptyResults() async throws {
        searchServiceMock.setSearchResult([])

        viewModel.searchSong(term: "Nonexistent Artist")

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 0)
        #expect(viewModel.hasMoreResults == false)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.didSearch == true)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Search song error")
    func test_searchSong_error() async throws {
        let testError = NetworkingError.otherError(innerError: NSError(
            domain: "TestError",
            code: 500
        ))
        searchServiceMock.setError(testError)

        viewModel.searchSong(term: "Beatles")

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 0)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.didSearch)
        #expect(viewModel.errorMessage != nil)
    }

    @Test("Search song loading state")
    func test_searchSong_loadingState() async throws {
        let testSongs = TestDataFactory.createTestSongs(count: 2)
        searchServiceMock.setSearchResult(testSongs)
        searchServiceMock.searchDelay = 0.5

        viewModel.searchSong(term: "Beatles")

        #expect(viewModel.isLoading)
        #expect(viewModel.didSearch == false)
    }

    @Test("Search song reset")
    func test_searchSong_reset() async throws {
        // First search
        let firstSongs = TestDataFactory.createTestSongs(count: 2)
        searchServiceMock.setSearchResult(firstSongs)
        viewModel.searchSong(term: "Beatles")
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 2)

        // New search
        let secondSongs = TestDataFactory.createTestSongs(count: 3, startingId: 10)
        searchServiceMock.setSearchResult(secondSongs)
        viewModel.searchSong(term: "Queen")
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 3)
        #expect(viewModel.songs[0].trackId == secondSongs[0].trackId)
        #expect(searchServiceMock.callCount == 2)
    }

    @Test("Search song load more")
    func test_searchSong_loadMore() async throws {
        // First search
        let firstSongs = TestDataFactory.createTestSongs(count: 2, startingId: 1)
        searchServiceMock.setSearchResult(firstSongs)
        viewModel.searchSong(term: "Beatles")
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 2)

        // Load more
        let secondSongs = TestDataFactory.createTestSongs(count: 3, startingId: 3)
        searchServiceMock.setSearchResult(secondSongs)
        viewModel.searchSong(term: "Beatles", shouldReset: false)
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 5)
        #expect(viewModel.songs[0].trackId == firstSongs[0].trackId)
        #expect(viewModel.songs[2].trackId == secondSongs[0].trackId)
        #expect(searchServiceMock.callCount == 2)
        #expect(searchServiceMock.lastOffset == 2)
    }

    @Test("Load more songs if needed triggers load more")
    func test_loadMoreSongsIfNeeded_triggersLoadMore() async throws {
        let firstSongs = TestDataFactory.createTestSongs(count: 2)
        searchServiceMock.setSearchResult(firstSongs)
        viewModel.searchSong(term: "Beatles")
        try? await Task.sleep(nanoseconds: 100_000_000)

        let secondSongs = TestDataFactory.createTestSongs(count: 2, startingId: 3)
        searchServiceMock.setSearchResult(secondSongs)

        let lastSong = viewModel.songs.last!
        viewModel.loadMoreSongsIfNeeded(currentSong: lastSong)
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 4)
        #expect(searchServiceMock.callCount == 2)
    }

    @Test("Load more songs if needed does not trigger for middle song")
    func test_loadMoreSongsIfNeeded_doesNotTriggerForMiddleSong() async throws {
        let songs = TestDataFactory.createTestSongs(count: 3)
        searchServiceMock.setSearchResult(songs)
        viewModel.searchSong(term: "Beatles")
        try? await Task.sleep(nanoseconds: 100_000_000)

        let middleSong = viewModel.songs[1]
        viewModel.loadMoreSongsIfNeeded(currentSong: middleSong)
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 3)
        #expect(searchServiceMock.callCount == 1)
    }

    @Test("Load more songs if needed does not trigger when no more results")
    func test_loadMoreSongsIfNeeded_doesNotTriggerWhenNoMoreResults() async throws {
        let songs = TestDataFactory.createTestSongs(count: 2)
        searchServiceMock.setSearchResult(songs)
        viewModel.searchSong(term: "Beatles")
        try? await Task.sleep(nanoseconds: 100_000_000)

        // No more results on second call
        searchServiceMock.setSearchResult([])
        let lastSong = viewModel.songs.last!
        viewModel.loadMoreSongsIfNeeded(currentSong: lastSong)
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.hasMoreResults == false)

        // Try to load more again
        viewModel.loadMoreSongsIfNeeded(currentSong: lastSong)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Should not make another call
        #expect(searchServiceMock.callCount == 2)
    }

    @Test("Search song prevents concurrent searches")
    func test_searchSong_PreventsDuringLoading() async throws {
        let songs = TestDataFactory.createTestSongs(count: 2)
        searchServiceMock.setSearchResult(songs)
        searchServiceMock.searchDelay = 0.2

        viewModel.searchSong(term: "Beatles")
        #expect(viewModel.isLoading)

        // Try to start second search while first is loading
        viewModel.searchSong(term: "Queen")

        try? await Task.sleep(nanoseconds: 300_000_000)

        #expect(searchServiceMock.callCount == 1)
        #expect(searchServiceMock.lastSearchTerm == "Beatles") // First search term
    }

    @Test("Complete search flow")
    func test_completeSearchFlow() async throws {
        let firstSongs = TestDataFactory.createTestSongs(count: 2, startingId: 1)
        let secondSongs = TestDataFactory.createTestSongs(count: 2, startingId: 3)

        // Initial search
        searchServiceMock.setSearchResult(firstSongs)
        viewModel.searchSong(term: "Beatles")
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 2)
        #expect(viewModel.hasMoreResults)
        #expect(viewModel.didSearch)
        #expect(viewModel.songs.last?.trackId == firstSongs.last?.trackId)

        // Load more
        searchServiceMock.setSearchResult(secondSongs)
        let lastSong = viewModel.songs.last!
        viewModel.loadMoreSongsIfNeeded(currentSong: lastSong)
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 4)
        #expect(viewModel.songs.last?.trackId == secondSongs.last?.trackId)

        // No more results
        searchServiceMock.setSearchResult([])
        let newLastSong = viewModel.songs.last!
        viewModel.loadMoreSongsIfNeeded(currentSong: newLastSong)
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.hasMoreResults == false)

        // New search
        let newSearchSongs = TestDataFactory.createTestSongs(count: 1, startingId: 10)
        searchServiceMock.setSearchResult(newSearchSongs)
        viewModel.searchSong(term: "Queen")
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.songs.count == 1)
        #expect(viewModel.songs[0].trackId == newSearchSongs[0].trackId)
        #expect(viewModel.hasMoreResults)
    }
}
