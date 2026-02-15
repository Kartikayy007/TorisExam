//
//  RobotIdeaScene.swift
//  Tori's Exam
//
//  Created by kartikay on 25/01/26.
//

import SpriteKit
import SwiftUI

class RobotIdeaScene: BaseScene {

    private var robot: SKSpriteNode!
    private var dialogBox: DialogBox!
    private var dialogues: [String] = []
    private var currentIndex = 0

    override func sceneDidSetup() {
        setupScene()
        setupDialogBox()
        startDialogSequence()
    }

    private func setupScene() {
        backgroundColor = SKColor(red: 0.835, green: 0.773, blue: 0.647, alpha: 1.0)

        robot = SKSpriteNode(imageNamed: "RoboIdea")
        robot.position = CGPoint(x: size.width / 2, y: size.height / 2)
        robot.zPosition = 0
        let scaleX = size.width / robot.size.width
        let scaleY = size.height / robot.size.height
        robot.setScale(max(scaleX, scaleY))
        gameLayer.addChild(robot)
    }

    private func setupDialogBox() {
        dialogBox = DialogBox()
        dialogBox.position = CGPoint(x: size.width / 2, y: 120)
        dialogBox.zPosition = 100
        gameLayer.addChild(dialogBox)

        dialogBox.onDialogComplete = { [weak self] in
            self?.advanceDialog()
        }
    }

    private func startDialogSequence() {
        dialogues = [
            "I have an idea!",
            "Why don't you get ready, and I'll teach you OOP along the way!",
        ]
        currentIndex = 0
        showCurrentDialog()
    }

    private func showCurrentDialog() {
        guard currentIndex < dialogues.count else {
            dialogBox.hideDialog()
            return
        }
        dialogBox.showDialog(name: "Robot", text: dialogues[currentIndex])
    }

    private func advanceDialog() {
        currentIndex += 1
        if currentIndex >= dialogues.count {
            transitionToNextScene()
        } else {
            showCurrentDialog()
        }
    }

    private func transitionToNextScene() {
        navigateTo(.thankYou)
    }

    override func handleTouch(at location: CGPoint, touch: UITouch) {
        dialogBox.handleTap()
    }
}
