//
//  MiniPlayerView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import SwiftUI

struct MiniPlayerView: View {

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            ArtworkImage(artworkURL: nil)

            Text("Afterlife")

            Spacer()

            Group {
                Button("", systemImage: "play.fill") {

                }

                Button("", systemImage: "forward.fill") {

                }
            }
            .font(.title3)
            .foregroundStyle(.primary)
        }
        .padding(.horizontal, 10)
        .frame(height: 55)
        .contentShape(.rect)
    }
}

// MARK: - Preview

#Preview {
    MiniPlayerView()
}
