//
//  ContentView.swift
//  TorisExam
//
//  Created by kartikay on 23/01/26.
//

import SpriteKit
import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameStateManager()
    @State private var isTransitioning = false

    var body: some View {
        ZStack {
            switch gameState.currentScreen {
            case .mainMenu:
                MainMenuView(onStart: {
                    // Trigger the blur
                    withAnimation(.easeInOut(duration: 0.6)) {
                        isTransitioning = true
                    }

                    // Wait for the screen to blur, then swap the view underneath
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        gameState.startGame()
                        // Fade the blur back out into the new scene
                        withAnimation(.easeInOut(duration: 0.8)) {
                            isTransitioning = false
                        }
                    }
                })

            case .playing:
                GamePlayView(gameState: gameState)
            }
        }
        .blur(radius: isTransitioning ? 30 : 0)
        .opacity(isTransitioning ? 0 : 1.0)
        .background(Color.black.ignoresSafeArea())
    }
}

struct GamePlayView: View {
    @ObservedObject var gameState: GameStateManager

    var body: some View {
        ZStack {
            if let scene = gameState.currentScene {
                PersistentSpriteView(scene: scene)
                    .ignoresSafeArea()
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        gameState.pauseGame()
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 3)
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 30)
                    .opacity(gameState.isPaused ? 0 : 1)
                }
                Spacer()
            }

            if gameState.isPaused {
                PauseMenuView(
                    onResume: {
                        withAnimation(.easeIn(duration: 0.2)) {
                            gameState.resumeGame()
                        }
                    },
                    onQuit: {
                        withAnimation(.easeIn(duration: 0.2)) {
                            gameState.quitToMainMenu()
                        }
                    },
                    onReset: {
                        withAnimation(.easeIn(duration: 0.2)) {
                            gameState.resetProgress()
                        }
                    }
                )
                .transition(.opacity)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
