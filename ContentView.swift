//
//  ContentView.swift
//  Tori's Exam
//
//  Created by kartikay on 23/01/26.
//

import SpriteKit
import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameStateManager()

    var body: some View {
        ZStack {
            switch gameState.currentScreen {
            case .mainMenu:
                MainMenuView(onStart: {
                    gameState.startGame()
                })

            case .playing:
                GamePlayView(gameState: gameState)
            }
        }
    }
}

struct GamePlayView: View {
    @ObservedObject var gameState: GameStateManager

    var body: some View {
        ZStack {
            if let scene = gameState.currentScene {
                SpriteView(scene: scene)
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
                    onRestart: {
                        withAnimation(.easeIn(duration: 0.2)) {
                            gameState.restartGame()
                        }
                    },
                    onQuit: {
                        withAnimation(.easeIn(duration: 0.2)) {
                            gameState.quitToMainMenu()
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
