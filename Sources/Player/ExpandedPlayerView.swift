//
//  ExpandedPlayerView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import SwiftUI

struct ExpandedPlayerView: View {

    // MARK: - Public properties

    // MARK: - Private properties

    private let safeArea: EdgeInsets
    @Binding private var expandPlayer: Bool
    @ObservedObject private var playerManager: MusicPlayerManager

    // MARK: - Initialization

    init(safeArea: EdgeInsets, expandPlayer: Binding<Bool>, playerManager: MusicPlayerManager) {
        self.safeArea = safeArea
        _expandPlayer = expandPlayer
        self.playerManager = playerManager
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()

                Capsule()
                    .fill(.white.secondary)
                    .frame(width: 35, height: 5)
                    .offset(y: -10)

                Spacer()

                if let song = playerManager.currentSong {
                    MoreOptionsButtonView(song: song, expandPlayer: $expandPlayer)
                }
            }

            Spacer()

            ArtworkImage(artworkURL: playerManager.largeArtworkURL, width: 400, height: 400)

            Spacer()

            VStack(alignment: .leading, spacing: 0) {
                MarqueeText(
                    text: playerManager.songTitle,
                    font: .system(size: 24, weight: .regular)
                )
                .foregroundStyle(.backgroundPrimaryInverted)
                .frame(height: 30)

                Text(playerManager.artistName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.textSecondary)

                Slider(
                    value: Binding(
                        get: { playerManager.sliderValue },
                        set: { newValue in playerManager.sliderValue = newValue }
                    ),
                    in: 0...max(playerManager.duration, 1),
                    onEditingChanged: { isEditing in
                        if !isEditing {
                            playerManager.finishSeeking()
                        }
                    }
                )
                .tint(.backgroundPrimaryInverted)

                HStack {
                    Text(playerManager.formattedCurrentTime)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.lightGrey)

                    Spacer()

                    Text(playerManager.formattedDuration)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.lightGrey)
                }
            }

            HStack(alignment: .center, spacing: 20) {
                Button {
                    playerManager.toggleShuffle()
                } label: {
                    Image(systemName: "shuffle")
                        .resizable()
                        .foregroundStyle(playerManager.isShuffleOn ? Color.accentColor : .secondary)
                        .frame(width: 20, height: 20)
                }

                Spacer()

                Button {
                    playerManager.previousSong()
                } label: {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .foregroundStyle(.backgroundPrimaryInverted)
                        .frame(width: 32, height: 32)
                }
                .disabled(!playerManager.hasPreviousSong)
                .opacity(playerManager.hasPreviousSong ? 1.0 : 0.4)

                Button {
                    playerManager.togglePlayPause()
                } label: {
                    let systemName = playerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill"

                    Image(systemName: systemName)
                        .resizable()
                        .foregroundStyle(.backgroundPrimaryInverted)
                        .frame(width: 64, height: 64)
                }
                .disabled(playerManager.isLoading)
                .opacity(playerManager.isLoading ? 0.4 : 1.0)

                Button {
                    playerManager.nextSong()
                } label: {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .foregroundStyle(.backgroundPrimaryInverted)
                        .frame(width: 32, height: 32)
                }
                .disabled(!playerManager.hasNextSong)
                .opacity(playerManager.hasNextSong ? 1.0 : 0.4)

                Spacer()

                Button {
                    playerManager.isRepeatOn.toggle()
                } label: {
                    Image(systemName: "repeat")
                        .resizable()
                        .foregroundStyle(playerManager.isRepeatOn ? Color.accentColor : .secondary)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(.top, safeArea.top + 16)
        .padding(.bottom, safeArea.bottom + 16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var expandPlayer: Bool = false

    ExpandedPlayerView(safeArea: EdgeInsets(),
                       expandPlayer: $expandPlayer,
                       playerManager: MusicPlayerManager())
}
