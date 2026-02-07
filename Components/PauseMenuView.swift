//
//  PauseMenuView.swift
//  Donut
//
//  Created by kartikay on 07/02/26.
//

import SwiftUI

struct PauseMenuView: View {
    let onResume: () -> Void
    let onRestart: () -> Void

    @State private var isVisible = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.15, green: 0.12, blue: 0.2),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(isVisible ? 1 : 0)

            VStack(spacing: 30) {
                Text("PAUSED")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                VStack(spacing: 16) {
                    Button("Resume") {
                        onResume()
                    }
                    .buttonStyle(PauseButtonStyle())

                    Button("Restart") {
                        onRestart()
                    }
                    .buttonStyle(PauseButtonStyle())
                }
                .padding(.top, 20)
            }
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isVisible = true
            }
        }
    }

    func animateOut(completion: @escaping () -> Void) {
        withAnimation(.easeIn(duration: 0.2)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion()
        }
    }
}

struct PauseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 200, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(configuration.isPressed ? 0.6 : 0.8))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    PauseMenuView(onResume: {}, onRestart: {})
}
