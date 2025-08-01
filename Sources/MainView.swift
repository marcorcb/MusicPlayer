//
//  MainView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import SwiftUI

struct MainView: View {

    // MARK: - Private properties

    @StateObject private var playerManager: MusicPlayerManager
    @State private var navigationService: NavigationService

    // MARK: - Initialization

    init(playerManager: MusicPlayerManager = MusicPlayerManager(),
         navigationService: NavigationService = NavigationService()) {
        _playerManager = .init(wrappedValue: playerManager)
        self.navigationService = navigationService
    }

    // MARK: - Body

    var body: some View {
        TabView {
            Tab.init("Search", systemImage: "magnifyingglass") {
                NavigationStack {
                    SongsView(playerManager: playerManager)
                        .environment(navigationService)
                        .navigationDestination(item: $navigationService.shouldNavigateToAlbum) { song in
                            AlbumView(selectedSong: song, playerManager: playerManager)
                                .environment(navigationService)
                        }
                }
                .tint(.backgroundPrimaryInverted)
                .toolbarRole(.editor)
            }
        }
        .universalOverlay(show: .constant(playerManager.currentSong != nil)) {
            ExpandableMusicPlayerView(
                playerManager: playerManager
            )
            .environment(navigationService)
        }
    }
}

// MARK: - Preview

#Preview {
    RootView {
        MainView()
    }
}
