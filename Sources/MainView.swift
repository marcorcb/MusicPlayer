//
//  MainView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import SwiftUI

struct MainView: View {

    // MARK: - Private properties

    @State private var showMiniPlayer: Bool = false

    // MARK: - Body

    var body: some View {
        TabView {
            Tab.init("Search", systemImage: "magnifyingglass") {
                SongsView()
            }
        }
        .universalOverlay(show: $showMiniPlayer) {
            ExpandableMusicPlayerView(show: $showMiniPlayer)
        }
        .onAppear() {
            showMiniPlayer = true
        }
    }
}

// MARK: - Preview

#Preview {
    RootView {
        MainView()
    }
}
