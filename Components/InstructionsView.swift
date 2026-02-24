//
//  InstructionsView.swift
//  TorisExam
//
//  Created by kartikay on 24/02/26.
//

import SwiftUI

struct InstructionsView: View {
    let onContinue: () -> Void
    @State private var isVisible = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack {
                Spacer()

                Text("HOW TO PLAY")
                    .font(.custom("AmericanTypewriter-Bold", size: 52))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.1))
                    .padding(.bottom, 5)

                Rectangle()
                    .fill(Color(red: 0.2, green: 0.15, blue: 0.1))
                    .frame(height: 4)
                    .frame(maxWidth: 400)
                    .cornerRadius(2)
                    .padding(.bottom, 30)

                VStack(alignment: .leading, spacing: 30) {
                    InstructionRow(text: "Tap anywhere on screen to advance the dialogue.")
                    // InstructionRow(text: "Interact with glowing objects when prompted.")
                    InstructionRow(text: "Pay close attention! TorisExam depends on you.")
                }
                .padding(.horizontal, 50)

                Spacer()

                Button(action: onContinue) {
                    Text("Continue")
                        .font(.custom("AmericanTypewriter-Bold", size: 28))
                        .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.1))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.85, green: 0.75, blue: 0.6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.35, green: 0.25, blue: 0.15), lineWidth: 3)
                        )
                }
                .padding(.bottom, 25)
            }
            .frame(width: 650, height: 520)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.94, green: 0.87, blue: 0.73))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        Color(red: 0.65, green: 0.45, blue: 0.25),
                        lineWidth: 16
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        Color(red: 0.35, green: 0.25, blue: 0.15),
                        lineWidth: 3
                    )
                    .padding(10)
            )
            .shadow(color: .black.opacity(0.6), radius: 25, x: 5, y: 15)
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
}

struct InstructionRow: View {
    var text: String

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Circle()
                .fill(Color(red: 0.2, green: 0.15, blue: 0.1))
                .frame(width: 14, height: 14)

            Text(text)
                .font(.custom("AmericanTypewriter", size: 28))
                .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.1))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
        }
    }
}

#Preview {
    InstructionsView(onContinue: {})
}
