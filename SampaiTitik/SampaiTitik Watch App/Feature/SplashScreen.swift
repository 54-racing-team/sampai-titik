//
//  SplashScreen.swift
//  SampaiTitik
//
//  Created by Ahmad Yasri Zaenuri on 27/08/26.
//

import SwiftUI

// MARK: - Splash Screen

struct SplashScreen<Content: View>: View {
    @State private var showHome = false
    @State private var revealed = false
    @Namespace private var logoAnimation

    // Child view of splash screen
    let content: Content

    // Respects the user's iOS accessibility setting — if they've asked for
    // reduced motion, skip straight to the final frame instead of animating.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let logoSize: CGFloat = 32
    private let dotSize: CGFloat = 9
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        if showHome {
            content
                .transition(.opacity)
        } else {
            ZStack {
                Color(red: 0.129, green: 0.525, blue: 0.757).ignoresSafeArea()
                logoLayout
            }
            .onAppear { runAnimation() }
        }
    }

    // matchedGeometryEffect bridges the two automatically.
    @ViewBuilder
    private var logoLayout: some View {
        HStack(spacing: 0) {
            Text("S")
                .font(.montserrat(size: logoSize))
                .foregroundColor(.white)
                .matchedGeometryEffect(id: "letterS", in: logoAnimation)

            if revealed {
                Text("ampai")
                    .font(.montserrat(size: logoSize))
                    .foregroundColor(.white)
                    .transition(.opacity)
                    .padding(.leading, 1)
            }

            Circle()
                .fill(Color.white)
                .frame(width: dotSize, height: dotSize)
                .matchedGeometryEffect(id: "dot", in: logoAnimation)
                .padding(.leading, revealed ? 6 : 6)
                .alignmentGuide(VerticalAlignment.center) { d in d[.bottom] - 23
                }
        }
    }

    private func runAnimation() {
        if reduceMotion {
            revealed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showHome = true
            }
            return
        }

        // Step 1: hold on "S." briefly so it registers as its own moment.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                revealed = true
            }
        }

        // Step 2: after the reveal finishes, hand off to Home.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.4)) {
                showHome = true
            }
        }
    }
}

#Preview {
    SplashScreen {
        RootView()
    }
}
