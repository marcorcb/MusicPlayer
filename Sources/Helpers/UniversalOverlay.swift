//
//  UniversalOverlay.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func universalOverlay<Content: View>(
        animation: Animation = .snappy,
        show: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .modifier(UniversalOverlayModifier(animation: animation, show: show, viewContent: content))
    }
}

/// Root View Wrapper
struct RootView<Content: View>: View {
    var content: Content
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var properties = UniversalOverlayProperties()
    
    var body: some View {
        content
            .environment(properties)
            .onAppear {
                setupWindow()
                setupKeyboardObservers()
            }
            .onDisappear {
                removeKeyboardObservers()
            }
    }
    
    private func setupWindow() {
        if let windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene), properties.window == nil {
            let window = PassThroughWindow(windowScene: windowScene)
            window.isHidden = false
            window.isUserInteractionEnabled = true
            window.windowLevel = UIWindow.Level.normal + 0.1
            /// Setting Up SwiftUI Based RootView Controller
            let rootViewController = UIHostingController(rootView: UniversalOverlayViews().environment(properties))
            rootViewController.view.backgroundColor = .clear
            window.rootViewController = rootViewController
            
            properties.window = window
        }
    }
    
    @MainActor
    private func setupKeyboardObservers() {
        Task {
            for await _ in NotificationCenter.default.notifications(named: UIResponder.keyboardWillShowNotification) {
                properties.window?.windowLevel = UIWindow.Level.normal - 1
            }
        }
        
        Task {
            for await _ in NotificationCenter.default.notifications(named: UIResponder.keyboardWillHideNotification) {
                properties.window?.windowLevel = UIWindow.Level.normal + 1
            }
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

/// Shared Universal Overlay Properties
@MainActor
@Observable
class UniversalOverlayProperties {
    var window: UIWindow?
    var views: [OverlayView] = []
    
    struct OverlayView: Identifiable {
        var id: String = UUID().uuidString
        var view: AnyView
    }
}

fileprivate struct UniversalOverlayModifier<ViewContent: View>: ViewModifier {
    var animation: Animation
    @Binding var show: Bool
    @ViewBuilder var viewContent: ViewContent
    /// Local View Properties
    @Environment(UniversalOverlayProperties.self) private var properties
    @State private var viewID: String?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: show, initial: true) { oldValue, newValue in
                if newValue {
                    addView()
                } else {
                    removeView()
                }
            }
    }
    
    private func addView() {
        if properties.window != nil && viewID == nil {
            viewID = UUID().uuidString
            guard let viewID else { return }
            
            withAnimation(animation) {
                properties.views.append(.init(id: viewID, view: .init(viewContent)))
            }
        }
    }
    
    private func removeView() {
        if let viewID {
            withAnimation(animation) {
                properties.views.removeAll(where: { $0.id == viewID })
            }
            
            self.viewID = nil
        }
    }
}

fileprivate struct UniversalOverlayViews: View {
    @Environment(UniversalOverlayProperties.self) private var properties
    var body: some View {
        ZStack {
            ForEach(properties.views) {
                $0.view
            }
        }
    }
}

fileprivate class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event),
              let rootView = rootViewController?.view
        else { return nil }
        
        if #available(iOS 18, *) {
            for subview in rootView.subviews.reversed() {
                /// Finding if any of rootview's is receving hit test
                let pointInSubView = subview.convert(point, from: rootView)
                if subview.hitTest(pointInSubView, with: event) != nil {
                    return hitView
                }
            }
            
            return nil
        } else {
            return hitView == rootView ? nil : hitView
        }
    }
}
