//
//  ErrorView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 31/07/25.
//

import SwiftUI

struct ErrorView: View {
    
    // MARK: - Private properties
    
    private let title: String
    private let message: String
    private let action: () -> Void
    
    // MARK: - Initialization
    
    init(title: String, message: String, action: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24))
                .foregroundStyle(.red)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.backgroundPrimaryInverted)
            
            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
            
            Button {
                action()
            } label: {
                Text("Try Again")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.backgroundPrimary)
            }
            .buttonStyle(.borderedProminent)
            .tint(.backgroundPrimaryInverted)
        }
        .padding()
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

// MARK: - Preview

#Preview {
    ErrorView(title: "Error title",
              message: "Error message") { }
}
