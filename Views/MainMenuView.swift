//
//  MainMenuView.swift
//  TorisExam
//
//  Created by kartikay on 07/02/26.
//

import SwiftUI

struct MainMenuView: View {
    let onStart: () -> Void

    @State private var isVisible = false
    @State private var showingInstructions = false
    @State private var floatOffset: CGFloat = 0.0
    @State private var hoveredIndex: Int? = 0

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
                        Text("TorisExam")
                            .font(.custom("AmericanTypewriter-Bold", size: 84))
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                            .shadow(color: .black.opacity(0.6), radius: 4, x: 2, y: 2)
                    }

                    VStack(alignment: .leading, spacing: 15) {
                        Button(action: {
                            withAnimation { showingInstructions = true }
                        }) {
                            Text("Start Packing")
                        }
                        .buttonStyle(MainMenuButtonStyle(index: 0, hoveredIndex: $hoveredIndex))
                        .onHover { isHovered in if isHovered { withAnimation { hoveredIndex = 0 } }
                        }

                        Button(action: {}) {
                            Text("Options")
                        }
                        .buttonStyle(MainMenuButtonStyle(index: 1, hoveredIndex: $hoveredIndex))
                        .onHover { isHovered in if isHovered { withAnimation { hoveredIndex = 1 } }
                        }

                        Button(action: {
                            withAnimation { showingInstructions = true }
                        }) {
                            Text("Help")
                        }
                        .buttonStyle(MainMenuButtonStyle(index: 2, hoveredIndex: $hoveredIndex))
                        .onHover { isHovered in if isHovered { withAnimation { hoveredIndex = 2 } }
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

            if showingInstructions {
                InstructionsView(onContinue: {
                    withAnimation { showingInstructions = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onStart()
                    }
                })
                .zIndex(100)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
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
            .font(.custom("AmericanTypewriter-Bold", size: isSelected ? 42 : 28))
            .foregroundColor(
                isSelected ? Color(red: 1.0, green: 0.8, blue: 0.2) : .white.opacity(0.6)
            )
            .shadow(color: isSelected ? .black.opacity(0.8) : .clear, radius: 4, x: 2, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: isSelected)
            .contentShape(Rectangle())
    }
}

#Preview {
    MainMenuView(onStart: {})
        .previewInterfaceOrientation(.landscapeLeft)
}
