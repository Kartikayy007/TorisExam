//
//  MainMenuView.swift
//  TorisExam
//
//  Created by kartikay on 07/02/26.
//

import SwiftUI

struct MainMenuView: View {
    let onStart: () -> Void
    let onStartExam: () -> Void
    let storyCompleted: Bool

    @State private var isVisible = false
    @State private var showingInstructions = false
    @State private var showingCredits = false
    @State private var showingTheory = false
    @State private var isHelpPopup = false
    @State private var showingLockedPopup = false
    @State private var hoveredIndex: Int? = 0
    @ObservedObject private var audioManager = AudioManager.shared

    var body: some View {
        ZStack {
            Image("Room")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            Color.black.opacity(0.3)
                .ignoresSafeArea()

            HStack {
                VStack(alignment: .leading, spacing: 30) {
                    Spacer()

                    VStack(alignment: .leading, spacing: -5) {
                        Text("Tori's Exam")
                            .font(.custom("AmericanTypewriter-Bold", size: 84))
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                            .shadow(color: .black.opacity(0.6), radius: 4, x: 2, y: 2)
                    }

                    VStack(alignment: .leading, spacing: 15) {
                        Button(action: {
                            isHelpPopup = false
                            withAnimation { showingInstructions = true }
                        }) {
                            Text("Start")
                        }
                        .buttonStyle(MainMenuButtonStyle(index: 0, hoveredIndex: $hoveredIndex))
                        .onHover { isHovered in if isHovered { withAnimation { hoveredIndex = 0 } }
                        }

                        Button(action: {
                            withAnimation { showingCredits = true }
                        }) {
                            Text("Credits")
                        }
                        .buttonStyle(MainMenuButtonStyle(index: 1, hoveredIndex: $hoveredIndex))
                        .onHover { isHovered in if isHovered { withAnimation { hoveredIndex = 1 } }
                        }

                        Button(action: {
                            isHelpPopup = true
                            withAnimation { showingInstructions = true }
                        }) {
                            Text("Help")
                        }
                        .buttonStyle(MainMenuButtonStyle(index: 2, hoveredIndex: $hoveredIndex))
                        .onHover { isHovered in if isHovered { withAnimation { hoveredIndex = 2 } }
                        }

                        Button(action: {
                            if storyCompleted {
                                withAnimation { showingTheory = true }
                            } else {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    showingLockedPopup = true
                                }
                            }
                        }) {
                            LockedMenuLabel(
                                text: "Revise", isLocked: !storyCompleted, index: 3,
                                hoveredIndex: $hoveredIndex)
                        }
                        .buttonStyle(MainMenuButtonStyle(index: 3, hoveredIndex: $hoveredIndex))
                        .onHover { isHovered in if isHovered { withAnimation { hoveredIndex = 3 } }
                        }

                        Button(action: {
                            if storyCompleted {
                                onStartExam()
                            } else {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    showingLockedPopup = true
                                }
                            }
                        }) {
                            LockedMenuLabel(
                                text: "Final Exam", isLocked: !storyCompleted, index: 4,
                                hoveredIndex: $hoveredIndex)
                        }
                        .buttonStyle(MainMenuButtonStyle(index: 4, hoveredIndex: $hoveredIndex))
                        .onHover { isHovered in if isHovered { withAnimation { hoveredIndex = 4 } }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.leading, 10)

                    Spacer()
                }
                .padding(.leading, 220)
                .padding(.bottom, 20)

                Spacer()
            }
            .opacity(isVisible ? 1 : 0)

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        audioManager.toggleMute()
                    }) {
                        Image(
                            systemName: audioManager.isMuted
                                ? "speaker.slash.fill" : "speaker.wave.3.fill"
                        )
                        .font(.system(size: 36))
                        .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.1))
                        .frame(width: 70, height: 70)
                        .background(Circle().fill(Color.white))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                    }
                    .padding(.top, 40)
                    .padding(.trailing, 180)
                }
                Spacer()
            }
            .opacity(isVisible ? 1 : 0)

            if showingInstructions {
                InstructionsView(
                    onContinue: {
                        withAnimation { showingInstructions = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onStart()
                        }
                    },
                    onDismiss: {
                        withAnimation { showingInstructions = false }
                    },
                    isHelpMenu: isHelpPopup
                )
                .zIndex(100)
            }

            if showingCredits {
                CreditsView(
                    onDismiss: {
                        withAnimation { showingCredits = false }
                    }
                )
                .zIndex(101)
            }

            if showingTheory {
                TheoryView {
                    withAnimation { showingTheory = false }
                }
                .zIndex(102)
            }

            if showingLockedPopup {
                LockedFeaturePopup {
                    withAnimation { showingLockedPopup = false }
                }
                .zIndex(102)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isVisible = true
            }
        }
    }
}

struct LockedMenuLabel: View {
    let text: String
    let isLocked: Bool
    let index: Int
    @Binding var hoveredIndex: Int?

    var isSelected: Bool { hoveredIndex == index }

    var body: some View {
        HStack(spacing: 10) {
            Text(text)
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: isSelected ? 28 : 22))
                    .opacity(0.7)
            }
        }
        .opacity(isLocked ? 0.6 : 1.0)
    }
}

struct LockedFeaturePopup: View {
    let onDismiss: () -> Void
    @State private var isVisible = false

    private let warmBg = Color(red: 0.94, green: 0.87, blue: 0.73)
    private let borderOuter = Color(red: 0.65, green: 0.45, blue: 0.25)
    private let borderInner = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let textPrimary = Color(red: 0.2, green: 0.15, blue: 0.1)
    private let textSecondary = Color(red: 0.35, green: 0.27, blue: 0.18)

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                Spacer()

                Text("Feature Locked")
                    .font(.custom("AmericanTypewriter-Bold", size: 36))
                    .foregroundColor(textPrimary)
                    .padding(.bottom, 6)

                Rectangle()
                    .fill(textPrimary)
                    .frame(height: 3)
                    .frame(maxWidth: 320)
                    .cornerRadius(2)
                    .padding(.bottom, 22)

                Text("Complete Tori's story to unlock\nthe Theory guide and Final Exam.")
                    .font(.custom("AmericanTypewriter", size: 22))
                    .foregroundColor(textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 40)

                // Text("Reach the last scene — Tori on the bus — to unlock these features.")
                //     .font(.custom("AmericanTypewriter", size: 16))
                //     .foregroundColor(textSecondary.opacity(0.75))
                //     .multilineTextAlignment(.center)
                //     .lineSpacing(4)
                //     .padding(.horizontal, 40)
                //     .padding(.top, 10)

                Spacer()

                Button(action: onDismiss) {
                    Text("Got it!")
                        .font(.custom("AmericanTypewriter-Bold", size: 26))
                        .foregroundColor(textPrimary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.85, green: 0.75, blue: 0.6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(borderInner, lineWidth: 3)
                        )
                }
                .padding(.bottom, 28)
            }
            .frame(width: 560, height: 420)
            .background(warmBg)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(borderOuter, lineWidth: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(borderInner, lineWidth: 3)
                    .padding(8)
            )
            .shadow(color: .black.opacity(0.6), radius: 25, x: 5, y: 15)
            .scaleEffect(isVisible ? 1 : 0.85)
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
}

struct MainMenuButtonStyle: ButtonStyle {
    let index: Int
    @Binding var hoveredIndex: Int?

    func makeBody(configuration: Configuration) -> some View {
        let isSelected = hoveredIndex == index

        configuration.label
            .font(.custom("AmericanTypewriter-Bold", size: isSelected ? 52 : 36))
            .foregroundColor(
                isSelected ? Color(red: 1.0, green: 0.8, blue: 0.2) : .white
            )
            .shadow(
                color: isSelected ? .black.opacity(0.8) : .black.opacity(0.5), radius: 4, x: 2, y: 2
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: isSelected)
            .contentShape(Rectangle())
    }
}

//#Preview {
//    MainMenuView(onStart: {}, onStartExam: {}, onShowTheory: {}, storyCompleted: false)
//        .previewInterfaceOrientation(.landscapeLeft)
//}
