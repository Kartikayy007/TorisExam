//
//  PauseMenuView.swift
//  TorisExam
//
//  Created by kartikay on 07/02/26.
//

import SwiftUI

struct PauseMenuView: View {
    let onResume: () -> Void
    let onQuit: () -> Void
    let onReset: () -> Void

    @State private var isVisible = false
    @State private var showingInstructions = false
    @ObservedObject private var audioManager = AudioManager.shared

    var body: some View {
        ZStack {
            Image("Room")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .blur(radius: 12)
                .opacity(isVisible ? 1 : 0)

            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("PAUSED")
                    .font(.custom("AmericanTypewriter-Bold", size: 64))
                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                    .shadow(color: .black.opacity(0.8), radius: 4, x: 2, y: 2)

                VStack(spacing: 16) {
                    Button("Resume") {
                        onResume()
                    }
                    .buttonStyle(MenuButtonStyle())

                    Button("Restart") {
                        onReset()
                    }
                    .buttonStyle(MenuButtonStyle())

                    Button("Help") {
                        withAnimation { showingInstructions = true }
                    }
                    .buttonStyle(MenuButtonStyle())

                    Button(action: {
                        audioManager.toggleMute()
                    }) {
                        HStack(spacing: 12) {
                            Image(
                                systemName: audioManager.isMuted
                                    ? "speaker.slash.fill" : "speaker.wave.3.fill"
                            )
                            .font(.system(size: 24))

                            Text("Sound")
                        }
                    }
                    .buttonStyle(MenuButtonStyle())

                    Button("Quit to Menu") {
                        onQuit()
                    }
                    .buttonStyle(MenuButtonStyle())
                }
                .padding(.top, 20)
            }
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)

            if showingInstructions {
                InstructionsView(
                    onContinue: {
                        withAnimation { showingInstructions = false }
                    },
                    onDismiss: {
                        withAnimation { showingInstructions = false }
                    }
                )
                .zIndex(100)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isVisible = true
            }
        }
    }
}

struct MenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("AmericanTypewriter-Bold", size: 28))
            .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.1))
            .frame(width: 260, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.94, green: 0.87, blue: 0.73))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.35, green: 0.25, blue: 0.15), lineWidth: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    PauseMenuView(onResume: {}, onQuit: {}, onReset: {})
}
