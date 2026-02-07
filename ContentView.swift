//
//  ContentView.swift
//  Donut
//
//  Created by kartikay on 23/01/26.
//

import SpriteKit
import SwiftUI

struct ContentView: View {
    @State private var isPaused = false
    @State private var showPauseMenu = false
    @State private var scene: BaseScene = {
        let scene = BedroomScene(size: CGSize(width: 1920, height: 1080))
        scene.scaleMode = .aspectFill
        return scene
    }()

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        togglePause()
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 3)
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 30)
                    .opacity(showPauseMenu ? 0 : 1)
                }
                Spacer()
            }

            if showPauseMenu {
                PauseMenuView(
                    onResume: {
                        resumeGame()
                    },
                    onRestart: {
                        restartGame()
                    }
                )
                .transition(.opacity)
            }
        }
    }

    private func togglePause() {
        scene.pause()
        withAnimation(.easeOut(duration: 0.3)) {
            showPauseMenu = true
        }
    }

    private func resumeGame() {
        withAnimation(.easeIn(duration: 0.2)) {
            showPauseMenu = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            scene.resume()
        }
    }

    private func restartGame() {
        withAnimation(.easeIn(duration: 0.2)) {
            showPauseMenu = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            scene.restartScene()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
