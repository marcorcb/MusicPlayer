//
//  SongsViewModel.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import Foundation

final class SongsViewModel: ObservableObject {

    // MARK: - Private Properties

    private let itunesSearchService: ItunesSearchServiceProtocol

    // MARK: - Public Properties

    @Published var searchText = ""
    @Published var songs: [Music] = []

    // MARK: Initialization

    init(itunesSearchService: ItunesSearchServiceProtocol = ItunesSearchService()) {
        self.itunesSearchService = itunesSearchService
    }

    func searchSong(term: String) {
        Task {
            do {
                let songs = try await itunesSearchService.fetchSongs(term: term)

                await MainActor.run {
                    self.songs = songs
                }
            } catch let error {
                print(error)
            }
        }
    }
}
