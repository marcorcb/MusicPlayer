//
//  AlbumItemView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 30/07/25.
//

import SwiftUI

struct AlbumItemView: View {

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
                Text(song.trackNumberString)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(song.previewUrl != nil ? .textSecondary : .gray)
                    .frame(width: 25, alignment: .leading)

                Text(song.trackName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(song.previewUrl != nil ? .backgroundPrimaryInverted : .gray)
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .opacity(song.previewUrl != nil ? 1 : 0.5)
        .onTapGesture {
            if song.previewUrl != nil {
                onTap()
            }
        }
    }
}

#Preview {
    AlbumItemView(song: .mockSong) {}
}
