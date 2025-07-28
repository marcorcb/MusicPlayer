//
//  ExpandableMusicPlayerView.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import SwiftUI

struct ExpandableMusicPlayerView: View {

    // MARK: - Public properties

    @Binding var show: Bool

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
            
            ZStack(alignment: .top) {
                ZStack {
                    Rectangle()
                        .fill(.songArtist)
                }
                .clipShape(.rect(cornerRadius: 8))
                .frame(height: expandPlayer ? nil : 55)
                .shadow(color: .primary.opacity(0.06), radius: 5, x: 5, y: 5)
                .shadow(color: .primary.opacity(0.06), radius: 5, x: -5, y: -5)
                
                MiniPlayerView()
                    .opacity(expandPlayer ? 0 : 1)
                    .onTapGesture {
                        withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                            expandPlayer = true
                        }

                        UIView.animate(withDuration: 0.3) {
                            resizeWindow(0.1)
                        }
                    }

                ExpandedPlayerView(safeArea: safeArea)
                    .opacity(expandPlayer ? 1 : 0)
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
            .ignoresSafeArea()
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

    private func resetWindowWithAnimation() {
        if let mainWindow = mainWindow?.subviews.first {
            UIView.animate(withDuration: 0.3) {
                mainWindow.layer.cornerRadius = 0
                mainWindow.transform = .identity
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var showMiniPlayer: Bool = false

    ExpandableMusicPlayerView(show: $showMiniPlayer)
}
