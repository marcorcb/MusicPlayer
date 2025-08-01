//
//  MiniPlayerView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import SwiftUI

struct MiniPlayerView: View {

    // MARK: - Public properties

    @ObservedObject var playerManager: MusicPlayerManager
    @Binding var expandPlayer: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: 16) {
                ArtworkImage(artworkURL: playerManager.smallArtworkURL)

            Text(playerManager.songTitle)
                .foregroundStyle(.backgroundPrimaryInverted)
                .font(.system(size: 16, weight: .regular))
                .lineLimit(1)

            Spacer()

            Group {
                Button {
                    playerManager.togglePlayPause()
                } label: {
                    let systemName = playerManager.isPlaying ? "pause.fill" : "play.fill"

                    Image(systemName: systemName)
                        .resizable()
                }
                .disabled(playerManager.isLoading)
                .frame(width: 22, height: 22)

                Button {
                    playerManager.nextSong()
                } label: {
                    Image(systemName: "forward.fill")
                        .resizable()
                }
                .disabled(playerManager.isLoading)
                .frame(width: 22, height: 22)
            }
            .foregroundStyle(.backgroundPrimaryInverted)
        }
        .padding(10)
        .frame(height: 55)
        .contentShape(.rect)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var expandPlayer: Bool = false

    MiniPlayerView(playerManager: MusicPlayerManager(),
                   expandPlayer: $expandPlayer)
}
