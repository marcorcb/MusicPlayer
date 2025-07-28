//
//  SongsView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 25/07/25.
//

import SwiftUI

struct SongsView: View {

    // MARK: - Private properties

    @StateObject private var viewModel = SongsViewModel()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.songs, id: \.trackId) { song in
                    SongItemView(song: song)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0,
                                                  leading: 0,
                                                  bottom: 16,
                                                  trailing: 0))
                }
            }
            .navigationTitle("Songs")
        }
        .searchable(
            text: $viewModel.searchText,
            placement: .automatic,
            prompt: "Search"
        )
        .onSubmit(of: .search) {
            viewModel.searchSong(term: viewModel.searchText)
        }
    }
}

// MARK: - Preview

#Preview {
    RootView {
        SongsView()
    }
}
