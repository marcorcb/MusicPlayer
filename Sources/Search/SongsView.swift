//
//  SongsView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 25/07/25.
//

import SwiftUI

struct SongsView: View {

    // MARK: - Public properties

    // MARK: - Private properties

    @StateObject private var viewModel: SongsViewModel
    @State private var isSearching = false
    @Environment(NavigationService.self) private var navigationService

    // MARK: - Initialization

    init(playerManager: MusicPlayerManager,
         itunesSearchService: ItunesSearchServiceProtocol = ItunesSearchService()) {
        _viewModel = .init(wrappedValue: SongsViewModel(
            itunesSearchService: itunesSearchService,
            playerManager: playerManager
        ))
    }

    // MARK: - Body

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.songs) { song in
                    SongItemView(song: song) {
                        viewModel.playerManager.play(song: song, songList: viewModel.songs)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8,
                                              leading: 0,
                                              bottom: 8,
                                              trailing: 0))
                    .contentShape(Rectangle())
                    .onAppear {
                        viewModel.loadMoreSongsIfNeeded(currentSong: song)
                    }
                }

                if viewModel.isLoading {
                    HStack {
                        Spacer()

                        ProgressView("Loading songs...")
                            .padding()

                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                if let errorMessage = viewModel.errorMessage {
                    HStack {
                        Spacer()

                        ErrorView(title: "Song search error",
                                  message: errorMessage) {
                            viewModel.searchSong(term: viewModel.searchText)
                        }

                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                if !viewModel.isLoading && viewModel.songs.isEmpty && viewModel.errorMessage == nil {
                    HStack {
                        Spacer()

                        let title = viewModel.didSearch ? "No tracks found" : "Welcome to MusicPlayer!"
                        let message = viewModel.didSearch ? "This search didn't return any results." : "Search for some music to start."

                        EmptyStateView(title: title,
                                       message: message)

                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                if !viewModel.hasMoreResults && !viewModel.songs.isEmpty {
                    HStack {
                        Spacer()

                        Text("No more songs to show! :)")
                            .foregroundColor(.textSecondary)
                            .padding()

                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .refreshable {
                viewModel.searchSong(term: viewModel.searchText)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Songs")
        .searchable(
            text: $viewModel.searchText,
            isPresented: $isSearching,
            placement: .toolbar,
            prompt: "Search"
        )
        .onSubmit(of: .search) {
            viewModel.searchSong(term: viewModel.searchText)
            isSearching = false
        }
        .onChange(of: viewModel.searchText) { oldValue, newValue in
            if newValue.isEmpty {
                viewModel.songs = []
                viewModel.hasMoreResults = true
                viewModel.errorMessage = nil
                viewModel.didSearch = false
            }
        }
        .background(.backgroundPrimary)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SongsView(playerManager: MusicPlayerManager())
            .environment(NavigationService())
    }
}
