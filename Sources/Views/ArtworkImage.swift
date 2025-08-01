//
//  ArtworkImage.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import SwiftUI

struct ArtworkImage: View {
    
    // MARK: - Private properties
    
    private let artworkURL: URL?
    private let width: CGFloat
    private let height: CGFloat
    
    // MARK: - Initialization
    
    init(artworkURL: URL?, width: CGFloat = 45, height: CGFloat = 45) {
        self.artworkURL = artworkURL
        self.width = width
        self.height = height
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            AsyncImage(url: artworkURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ZStack {
                    Image(.iconMusicNote)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .tint(.backgroundPrimaryInverted)
                }
                .frame(width: width, height: height)
                .background(.backgroundArtworkPlaceholder)
            }
        }
        .frame(width: width, height: height)
        .clipShape(.rect(cornerRadius: 8))
    }
}

// MARK: - Preview

#Preview {
    ArtworkImage(artworkURL: nil)
}
