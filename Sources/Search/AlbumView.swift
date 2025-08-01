//
//  AlbumView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 29/07/25.
//

import SwiftUI

struct AlbumView: View {

    // MARK: - Private properties

    @StateObject private var viewModel: AlbumViewModel

    // MARK: - Initialization

    init(selectedSong: Song, playerManager: MusicPlayerManager) {
        _viewModel = .init(wrappedValue: AlbumViewModel(selectedSong: selectedSong,
                                                        playerManager: playerManager))
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .background(.backgroundPrimary)

            if viewModel.isLoading && viewModel.songs.isEmpty {
                loadingView
            } else {
                songsListView
            }
        }
        .background(.backgroundPrimary)
    }

    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 8) {
            if !viewModel.isLoading && viewModel.errorMessage == nil {
                ArtworkImage(artworkURL: viewModel.album?.largeArtworkURL, width: 200, height: 200)
                    .padding(.vertical, 8)
            }

            if let album = viewModel.album {
                Text(album.albumTitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.backgroundPrimaryInverted)

                Text(album.artistName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()

            ProgressView()
                .scaleEffect(1.2)

            Text("Loading album songs...")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.textSecondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var songsListView: some View {
        List {
            ForEach(viewModel.songs) { song in
                AlbumItemView(song: song) {
                    viewModel.playerManager.play(song: song, songList: viewModel.songs)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8,
                                          leading: 0,
                                          bottom: 8,
                                          trailing: 0))
                .contentShape(Rectangle())
            }

            if viewModel.isLoading && !viewModel.songs.isEmpty {
                HStack {
                    Spacer()
                    ProgressView("Loading more tracks...")
                        .font(.caption)
                        .padding()
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            if let errorMessage = viewModel.errorMessage {
                HStack {
                    Spacer()

                    ErrorView(title: "Error loading tracks",
                              message: errorMessage) {
                        viewModel.loadAlbumSongs()
                    }

                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            if !viewModel.isLoading && viewModel.songs.isEmpty && viewModel.errorMessage == nil {
                HStack {
                    Spacer()

                    EmptyStateView(title: "No tracks found",
                                   message: "This album doesn't have any available tracks.")

                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            Spacer(minLength: 55)
                .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .background(.backgroundPrimary)
        .refreshable {
            viewModel.refreshAlbumSongs()
        }
    }
}

// MARK: - Preview

#Preview {
    AlbumView(selectedSong: .mockSong,
              playerManager: MusicPlayerManager())
}
