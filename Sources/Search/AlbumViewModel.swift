//
//  AlbumViewModel.swift
//  MusicPlayer
//
//  Created by Marco Braga on 30/07/25.
//

import Foundation

@MainActor
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
    }

    // MARK: - Public methods

    func loadAlbumSongs() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let album = try await itunesSearchService.fetchSongsFromAlbum(albumID: selectedSong.collectionId)

            self.album = album
            self.songs = album.sortedTracks
            self.isLoading = false
        } catch let error {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    func refreshAlbumSongs() async {
        album = nil
        songs = []

        await loadAlbumSongs()
    }
}
