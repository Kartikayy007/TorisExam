//
//  PauseMenuView.swift
//  Tori's Exam
//
//  Created by kartikay on 07/02/26.
//

import SwiftUI

struct PauseMenuView: View {
    let onResume: () -> Void
    let onQuit: () -> Void
    let onReset: () -> Void

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
                    .buttonStyle(MenuButtonStyle(color: .blue))

                    Button("Reset Progress") {
                        onReset()
                    }
                    .buttonStyle(MenuButtonStyle(color: .orange))

                    Button("Quit to Menu") {
                        onQuit()
                    }
                    .buttonStyle(MenuButtonStyle(color: .red))
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
}

struct MenuButtonStyle: ButtonStyle {
    var color: Color = .blue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 220, height: 55)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(configuration.isPressed ? 0.6 : 0.8))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    PauseMenuView(onResume: {}, onQuit: {}, onReset: {})
}
