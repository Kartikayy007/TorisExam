//
//  RobotIdeaScene.swift
//  TorisExam
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
        let bgBlurNode = SKEffectNode()
        bgBlurNode.shouldRasterize = true
        bgBlurNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 8])
        bgBlurNode.zPosition = 0

        let roomBg = SKSpriteNode(imageNamed: "Room")
        roomBg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let roomScale = max(size.width / roomBg.size.width, size.height / roomBg.size.height)
        roomBg.setScale(roomScale)
        bgBlurNode.addChild(roomBg)
        gameLayer.addChild(bgBlurNode)

        let blurOverlay = SKShapeNode(
            rectOf: CGSize(width: size.width * 2, height: size.height * 2))
        blurOverlay.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        blurOverlay.strokeColor = .clear
        blurOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        blurOverlay.zPosition = 1
        gameLayer.addChild(blurOverlay)

        robot = SKSpriteNode(imageNamed: "RoboIdea")
        robot.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        robot.zPosition = 5
        let robotScale = (size.height * 0.85) / robot.size.height
        robot.setScale(robotScale)
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
            "I have an idea! Why don't you get ready, and I'll teach you OOP along the way!"
        ]
        currentIndex = 0
        showCurrentDialog()
    }

    private func showCurrentDialog() {
        guard currentIndex < dialogues.count else {
            dialogBox.hideDialog()
            return
        }
        dialogBox.onDialogComplete = { [weak self] in
            self?.advanceDialog()
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
