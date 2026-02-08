//
//  RobotIntroScene.swift
//  Tori's Exam
//
//  Created by kartikay on 24/01/26.
//

import SpriteKit
import SwiftUI

class RobotIntroScene: BaseScene {

    private var robotDone: SKSpriteNode!
    private var dialogBox: DialogBox!
    private var dialogues: [String] = []
    private var currentIndex = 0

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
        setupDialogBox()
        startDialogSequence()
    }

    private func setupScene() {
        backgroundColor = SKColor(red: 0.835, green: 0.773, blue: 0.647, alpha: 1.0)

        robotDone = SKSpriteNode(imageNamed: "RobotDone")
        robotDone.position = CGPoint(x: size.width / 2, y: size.height / 2)
        robotDone.zPosition = 0
        let scaleX = size.width / robotDone.size.width
        let scaleY = size.height / robotDone.size.height
        robotDone.setScale(max(scaleX, scaleY))
        gameLayer.addChild(robotDone)
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
            "AHHHHH!!!",
            "I'm going to fail!",
            "I don't know what to do... IDK IDK...",
            "Someone help me!!",
        ]
        currentIndex = 0
        showCurrentDialog()
    }

    private func showCurrentDialog() {
        guard currentIndex < dialogues.count else {
            dialogBox.hideDialog()
            return
        }
        dialogBox.showDialog(name: "", text: dialogues[currentIndex])

        let wait = SKAction.wait(forDuration: 1.5)
        let advance = SKAction.run { [weak self] in
            self?.advanceDialog()
        }
        run(SKAction.sequence([wait, advance]))
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
        let nextScene = KidScaredScene(size: self.size)
        nextScene.scaleMode = .aspectFill
        self.view?.presentScene(nextScene, transition: .fade(withDuration: 0.5))
    }

    override func handleTouch(at location: CGPoint, touch: UITouch) {
        dialogBox.handleTap()
    }
}
