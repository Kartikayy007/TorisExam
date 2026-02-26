//
//  CreditsView.swift
//  TorisExam
//
//  Created by Kartikay on 26/02/26.
//

import SwiftUI

struct CreditsView: View {
    let onDismiss: () -> Void
    @State private var isVisible = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack {
                Spacer()

                Text("CREDITS")
                    .font(.custom("AmericanTypewriter-Bold", size: 52))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.1))
                    .padding(.bottom, 5)

                Rectangle()
                    .fill(Color(red: 0.2, green: 0.15, blue: 0.1))
                    .frame(height: 4)
                    .frame(maxWidth: 400)
                    .cornerRadius(2)
                    .padding(.bottom, 30)

                Text(
                    "All art, code, and design in Tori's Exam was created entirely by me.\n\nWith the exception of three assets, every visual in this project was hand-made from scratch. The Clock Background and the Blurred Kitchen Background were generated using AI. The Bus Window Scenery is a free vector graphic sourced from Vecteezy.\n\nThank you for playing!"
                )
                .font(.custom("AmericanTypewriter", size: 22))
                .foregroundColor(Color(red: 0.25, green: 0.2, blue: 0.15))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 40)

                Spacer()

                Button(action: onDismiss) {
                    Text("Close")
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
            .frame(width: 800, height: 600)
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

#Preview {
    CreditsView(onDismiss: {})
}
