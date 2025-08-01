//
//  SongItemView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import SwiftUI

struct SongItemView: View {

    // MARK: - Private properties

    private let song: Song
    private let onTap: () -> Void

    // MARK: - Initialization

    init(song: Song, onTap: @escaping () -> Void) {
        self.song = song
        self.onTap = onTap
    }

    // MARK: - Body

    var body: some View {
        HStack {
            HStack(alignment: .center, spacing: 16) {
                ArtworkImage(artworkURL: URL(string: song.artworkUrl100))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.trackName)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.backgroundPrimaryInverted)

                    Text(song.artistName)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.textSecondary)
                }
                
                Spacer()
                
                
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            
            MoreOptionsButtonView(song: song)
        }
    }
}

// MARK: - Preview

#Preview {
    SongItemView(song: .mockSong) {}
        .environment(NavigationService())
}
