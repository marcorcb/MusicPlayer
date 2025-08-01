//
//  ExpandableMusicPlayerView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import SwiftUI

struct ExpandableMusicPlayerView: View {

    // MARK: - Public properties

    @ObservedObject var playerManager: MusicPlayerManager

    // MARK: - Private properties

    @State private var expandPlayer: Bool = false
    @State private var offsetY: CGFloat = 0
    @State private var mainWindow: UIWindow?
    @State private var windowProgress: CGFloat = 0

    // MARK: - Body

    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            let cornerRadius: CGFloat = safeArea.bottom == 0 ? 0 : 45

            ZStack(alignment: .top) {
                ZStack {
                    Rectangle()
                        .fill(expandPlayer ? .backgroundPrimary : .backgroundMiniPlayer)
                }
                .clipShape(.rect(cornerRadius: expandPlayer ? cornerRadius : 15))
                .frame(height: expandPlayer ? nil : 55)

                MiniPlayerView(playerManager: playerManager, expandPlayer: $expandPlayer)
                    .opacity(expandPlayer ? 0 : 1)
                    .onTapGesture {
                        withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                            expandPlayer = true
                        }

                        UIView.animate(withDuration: 0.3) {
                            resizeWindow(0.1)
                        }
                    }

                if expandPlayer {
                    ExpandedPlayerView(safeArea: safeArea, expandPlayer: $expandPlayer, playerManager: playerManager)
                }
            }
            .frame(height: expandPlayer ? nil : 55, alignment: .top)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, expandPlayer ? 0 : safeArea.bottom + 55)
            .padding(.horizontal, expandPlayer ? 0 : 15)
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        guard expandPlayer else { return }

                        let translation = max(value.translation.height, 0)
                        offsetY = translation
                        windowProgress = max(min(translation / size.height, 1), 0) * 0.1

                        resizeWindow(0.1 - windowProgress)
                    })
                    .onEnded({ value in
                        guard expandPlayer else { return }

                        let translation = max(value.translation.height, 0)
                        let velocity = value.velocity.height / 5

                        withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                            if (translation + velocity) > (size.height * 0.5) {
                                expandPlayer = false
                                windowProgress = 0
                                resetWindowWithAnimation()
                            } else {
                                UIView.animate(withDuration: 0.3) {
                                    resizeWindow(0.1)
                                }
                            }

                            offsetY = 0
                        }
                    })
            )
            .onChange(of: expandPlayer) { if expandPlayer == false { resetWindowWithAnimation(duration: 0.2) }
            }
            .ignoresSafeArea()
            .alert("Error", isPresented: .constant(playerManager.playerError != nil)) {
                Button("OK") {
                    playerManager.playerError = nil
                }
            } message: {
                Text(playerManager.playerError ?? "")
            }
        }
        .onAppear() {
            if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow, mainWindow == nil {
                mainWindow = window
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if expandPlayer {
                mainWindow?.subviews.first?.transform = .identity
            }
        }
    }

    // MARK: - Private methods

    private func resizeWindow(_ progress: CGFloat) {
        if let mainWindow = mainWindow?.subviews.first {
            let offsetY = (mainWindow.frame.height * progress) / 2

            mainWindow.layer.cornerRadius = (progress / 0.1) * 30
            mainWindow.layer.masksToBounds = true

            mainWindow.transform = .identity.scaledBy(x: 1 - progress, y: 1 - progress).translatedBy(x: 0, y: offsetY)
        }
    }

    private func resetWindowWithAnimation(duration: TimeInterval = 0.3) {
        if let mainWindow = mainWindow?.subviews.first {
            UIView.animate(withDuration: duration) {
                mainWindow.layer.cornerRadius = 0
                mainWindow.transform = .identity
            }
        }
    }

    private func resetWindowWithoutAnimation() {
        if let mainWindow = mainWindow?.subviews.first {
            mainWindow.layer.cornerRadius = 0
            mainWindow.transform = .identity
        }
    }
}

// MARK: - Preview

#Preview {
    ExpandableMusicPlayerView(playerManager: MusicPlayerManager())
}
