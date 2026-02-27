//
//  GameState.swift
//  TorisExam
//
//  Created by kartikay on 07/02/26.
//

import SpriteKit
import SwiftUI

enum GameScreen {
    case mainMenu
    case playing
    case examHall
}

@MainActor
class GameStateManager: ObservableObject {
    @Published var currentScreen: GameScreen = .mainMenu
    @Published var isPaused: Bool = false
    @Published var currentScene: BaseScene?
    @Published var storyCompleted: Bool = UserDefaults.standard.bool(forKey: "storyCompleted")

    init() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("TriggerStartExam"), object: nil, queue: .main
        ) { [weak self] _ in
            self?.startExam()
        }
        NotificationCenter.default.addObserver(
            forName: Notification.Name("StoryCompleted"), object: nil, queue: .main
        ) { [weak self] _ in
            self?.markStoryCompleted()
        }
    }

    func markStoryCompleted() {
        storyCompleted = true
        UserDefaults.standard.set(true, forKey: "storyCompleted")
    }

    func startGame() {
        let scene = BedroomScene(size: CGSize(width: 1920, height: 1080))
        scene.scaleMode = .aspectFill
        currentScene = scene
        currentScreen = .playing
        isPaused = false
    }

    func startExam() {
        currentScene?.removeFromParent()
        currentScene = nil
        currentScreen = .examHall
        isPaused = false
    }

    func pauseGame() {
        currentScene?.pause()
        isPaused = true
    }

    func resumeGame() {
        isPaused = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.currentScene?.resume()
        }
    }

    func restartGame() {
        isPaused = false
        guard let oldScene = currentScene else { return }

        let newScene = type(of: oldScene).init(size: oldScene.size)
        newScene.scaleMode = oldScene.scaleMode

        if let view = oldScene.view {
            view.presentScene(newScene)
        }
        currentScene = newScene
    }

    func quitToMainMenu() {
        isPaused = false
        currentScene?.removeFromParent()
        currentScene = nil
        currentScreen = .mainMenu
    }

    func resetProgress() {
        SceneNavigator.shared.reset()
        isPaused = false
        let scene = BedroomScene(size: CGSize(width: 1920, height: 1080))
        scene.scaleMode = .aspectFill
        if let view = currentScene?.view {
            view.presentScene(scene)
        }
        currentScene = scene
    }
}
