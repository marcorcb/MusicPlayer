//
//  MarqueeText.swift
//  MusicPlayer
//
//  Created by Marco Braga on 31/07/25.
//

import SwiftUI

struct MarqueeText: View {
    
    // MARK: - Private properties
    
    @State private var animate = false
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var animationTask: Task<Void, Never>?
    
    private let text: String
    private let font: Font
    private let startDelay: Double
    private let pauseBetweenCycles: Double
    
    private var animationDuration: Double {
        Double(textWidth / 30)
    }
    
    // MARK: - Initialization
    
    init(text: String,
         font: Font,
         startDelay: Double = 2.0,
         pauseBetweenCycles: Double = 1.0
    ) {
        self.text = text
        self.font = font
        self.startDelay = startDelay
        self.pauseBetweenCycles = pauseBetweenCycles
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if textWidth > geometry.size.width {
                    HStack(spacing: 0) {
                        Text(text)
                            .font(font)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Spacer()
                            .frame(width: 40)
                        
                        Text(text)
                            .font(font)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .offset(x: animate ? -(textWidth + 40) : 0)
                    .animation(
                        animate ?
                        Animation.linear(duration: animationDuration) :
                                .none,
                        value: animate
                    )
                    .onAppear {
                        containerWidth = geometry.size.width
                        startAnimationCycle()
                    }
                    .onDisappear {
                        stopAnimation()
                    }
                    .clipped()
                } else {
                    Text(text)
                        .font(font)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onAppear {
                            containerWidth = geometry.size.width
                        }
                }
            }
        }
        .background(
            Text(text)
                .font(font)
                .fixedSize(horizontal: true, vertical: false)
                .background(GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            textWidth = proxy.size.width
                        }
                        .onChange(of: text) {
                            textWidth = proxy.size.width
                            stopAnimation()
                            
                            if textWidth > containerWidth {
                                startAnimationCycle()
                            }
                        }
                })
                .opacity(0)
        )
        .onChange(of: containerWidth) {
            stopAnimation()
            if textWidth > containerWidth {
                startAnimationCycle()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if textWidth > containerWidth {
                stopAnimation()
                startAnimationCycle()
            }
        }
    }
    
    @MainActor
    private func startAnimationCycle() {
        guard textWidth > containerWidth else { return }
        
        animate = false
        stopAnimation()
        
        animationTask = Task {
            try? await Task.sleep(for: .seconds(startDelay))
            guard !Task.isCancelled else { return }
            await startSingleAnimation()
        }
    }
    
    @MainActor
    private func startSingleAnimation() async {
        guard !Task.isCancelled else { return }
        
        animate = true
        
        let totalCycleTime = animationDuration + pauseBetweenCycles
        
        try? await Task.sleep(for: .seconds(totalCycleTime))
        guard !Task.isCancelled else { return }
        
        animate = false
        
        try? await Task.sleep(for: .seconds(0.1))
        guard !Task.isCancelled else { return }
        
        await startSingleAnimation()
    }
    
    private func stopAnimation() {
        animate = false
        animationTask?.cancel()
        animationTask = nil
    }
}

// MARK: - Preview

struct MarqueeText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MarqueeText(
                text: "Short Title",
                font: .system(size: 24, weight: .regular),
                startDelay: 1.0
            )
            .frame(height: 30)
            .foregroundStyle(.backgroundPrimaryInverted)
            
            MarqueeText(
                text: "This is a very long song title that should start in place and then scroll to the left like Apple Music",
                font: .system(size: 24, weight: .regular),
                startDelay: 2.0
            )
            .frame(height: 30)
            .foregroundStyle(.backgroundPrimaryInverted)
            
            MarqueeText(
                text: "Another long title that also should scroll smoothly from left to right",
                font: .system(size: 18, weight: .medium),
                startDelay: 1.5
            )
            .frame(height: 25)
            .foregroundStyle(.backgroundPrimaryInverted)
        }
        .padding()
    }
}
