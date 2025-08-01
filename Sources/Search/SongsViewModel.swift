//
//  SongsViewModel.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import Foundation

final class SongsViewModel: ObservableObject {

    // MARK: - Public properties

    @Published var searchText = ""
    @Published var songs: [Song] = []
    @Published var isLoading: Bool = false
    @Published var hasMoreResults: Bool = true
    @Published var playerManager: MusicPlayerManager
    @Published var errorMessage: String?
    @Published var didSearch: Bool = false

    // MARK: - Private properties

    private let itunesSearchService: ItunesSearchServiceProtocol
    private var currentOffset: Int = 0
    private let limit: Int = 50
    private var currentSearchTerm: String = ""

    // MARK: Initialization

    init(itunesSearchService: ItunesSearchServiceProtocol = ItunesSearchService(),
         playerManager: MusicPlayerManager) {
        self.itunesSearchService = itunesSearchService
        self.playerManager = playerManager
    }

    // MARK: - Public methods

    func searchSong(term: String, shouldReset: Bool = true) {
        if shouldReset {
            currentSearchTerm = term
            currentOffset = 0
            songs = []
            hasMoreResults = true
            errorMessage = nil
            didSearch = false
        }

        guard !isLoading && hasMoreResults else { return }

        isLoading = true

        Task {
            do {
                let newSongs = try await itunesSearchService.searchSongs(term: term, offset: currentOffset, limit: limit)

                await MainActor.run {
                    if shouldReset {
                        self.songs = newSongs
                    } else {
                        self.songs.append(contentsOf: newSongs)
                    }

                    self.currentOffset += newSongs.count
                    self.hasMoreResults = !newSongs.isEmpty
                    self.isLoading = false
                    didSearch = true
                }
            } catch let error {
                await MainActor.run {
                    self.isLoading = false
                    didSearch = true
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    func loadMoreSongsIfNeeded(currentSong: Song) {
        guard let lastSong = songs.last else { return }

        if currentSong.trackId == lastSong.trackId && hasMoreResults {
            searchSong(term: currentSearchTerm, shouldReset: false)
        }
    }
}
