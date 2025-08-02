//
//  EmptyStateView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 31/07/25.
//

import SwiftUI

struct EmptyStateView: View {

    // MARK: - Private properties

    private let title: String
    private let message: String

    // MARK: - Initialization

    init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundStyle(.textSecondary)

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.backgroundPrimaryInverted)

            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

// MARK: - Preview

#Preview {
    EmptyStateView(title: "Empty State title",
                   message: "Empty State message")
}
