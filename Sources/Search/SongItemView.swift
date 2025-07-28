//
//  SongItemView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import SwiftUI

struct SongItemView: View {

    // MARK: - Private properties

    private let song: Music

    // MARK: - Initialization

    init(song: Music) {
        self.song = song
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ArtworkImage(artworkURL: URL(string: song.artworkUrl100))

            VStack(alignment: .leading, spacing: 4) {
                Text(song.trackName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.songTitle)

                Text(song.artistName)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.songArtist)
            }
        }
    }
}

// MARK: - Preview

//#Preview {
//    SongItemView(title: "Afterlife", artist: "Avenged Sevenfold")
//}
