//
//  AlbumViewModel.swift
//  MusicPlayer
//
//  Created by Marco Braga on 30/07/25.
//

import Foundation

final class AlbumViewModel: ObservableObject {

    // MARK: - Public properties

    @Published var songs: [Song] = []
    @Published var playerManager: MusicPlayerManager
    @Published var album: AlbumData?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private properties

    private let itunesSearchService: ItunesSearchServiceProtocol
    private let selectedSong: Song

    // MARK: Initialization

    init(selectedSong: Song,
         playerManager: MusicPlayerManager,
         itunesSearchService: ItunesSearchServiceProtocol = ItunesSearchService()) {
        self.selectedSong = selectedSong
        self.playerManager = playerManager
        self.itunesSearchService = itunesSearchService
        loadAlbumSongs()
    }

    // MARK: - Public methods

    func loadAlbumSongs() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let album = try await itunesSearchService.fetchSongsFromAlbum(albumID: selectedSong.collectionId)

                await MainActor.run {
                    self.album = album
                    self.songs = album.sortedTracks
                    self.isLoading = false
                }
            } catch let error {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func refreshAlbumSongs() {
        album = nil
        songs = []

        loadAlbumSongs()
    }
}
