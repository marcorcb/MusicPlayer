//
//  MoreOptionsButtonView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 29/07/25.
//

import SwiftUI

struct MoreOptionsButtonView: View {

    // MARK: - Private properties

    private let song: Song
    @Binding private var expandPlayer: Bool
    @Environment(NavigationService.self) private var navigationService

    // MARK: - Initialization

    init(song: Song, expandPlayer: Binding<Bool> = .constant(false)) {
        self.song = song
        _expandPlayer = expandPlayer
    }

    // MARK: - Body

    var body: some View {
        Menu {
            Button {
                handleAlbumNavigation()
            } label: {
                HStack(spacing: 16) {
                    Image(.iconAlbum)
                        .resizable()
                        .foregroundStyle(.backgroundPrimaryInverted)
                        .frame(width: 24, height: 24)

                    Text("Open album")
                        .foregroundStyle(.backgroundPrimaryInverted)
                        .font(.system(size: 16, weight: .medium))

                    Spacer()
                }
            }
            .clipShape(Capsule())
        } label: {
            Image(.iconMoreVertical)
                .resizable()
                .foregroundStyle(.backgroundPrimaryInverted)
                .frame(width: 20, height: 20)
        }
        .buttonStyle(PlainButtonStyle())
        .clipShape(Rectangle())
    }

    // MARK: - Private methods

    private func handleAlbumNavigation() {
        if expandPlayer == true {
            expandPlayer.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                navigationService.navigateToAlbum(song)
            }
        } else {
            navigationService.navigateToAlbum(song)
        }
    }
}

// MARK: - Preview

#Preview {
    MoreOptionsButtonView(song: .mockSong)
        .environment(NavigationService())
}
