//
//  ExpandedPlayerView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import SwiftUI

struct ExpandedPlayerView: View {

    // MARK: - Private properties

    private let safeArea: EdgeInsets

    // MARK: - Initialization

    init(safeArea: EdgeInsets) {
        self.safeArea = safeArea
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(.white.secondary)
                .frame(width: 35, height: 5)
                .offset(y: -10)

            ArtworkImage(artworkURL: nil, width: 300, height: 300)
        }
        .padding(16)
        .padding(.top, safeArea.top)
    }
}

// MARK: - Preview

#Preview {
    ExpandedPlayerView(safeArea: EdgeInsets())
}
