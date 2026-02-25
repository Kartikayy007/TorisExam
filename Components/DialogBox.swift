//
//  DialogBox.swift
//  TorisExam
//
//  Created by kartikay on 23/01/26.
//

import SpriteKit
import SwiftUI

class DialogBox: SKNode {

    private var backgroundBox: SKShapeNode!
    private var nameLabel: SKLabelNode!
    private var dialogLabel: SKLabelNode!
    private var continueIndicator: SKLabelNode!

    private var fullText: String = ""
    private var currentCharacterIndex: Int = 0
    private var isTyping: Bool = false

    private let boxHeight: CGFloat = 220
    private let padding: CGFloat = 40

    var onDialogComplete: (() -> Void)?

    override init() {
        super.init()
        setupDialogBox()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDialogBox()
    }

    private func setupDialogBox() {
        let boxWidth: CGFloat = 1400
        let cornerRadius: CGFloat = 25

        let rect = CGRect(x: -boxWidth / 2, y: 0, width: boxWidth, height: boxHeight)
        backgroundBox = SKShapeNode(rect: rect, cornerRadius: cornerRadius)
        backgroundBox.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 0.9)
        backgroundBox.strokeColor = SKColor(red: 0.4, green: 0.35, blue: 0.3, alpha: 1.0)
        backgroundBox.lineWidth = 4
        backgroundBox.zPosition = 100
        addChild(backgroundBox)

        nameLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        nameLabel.fontSize = 40
        nameLabel.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0)
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.verticalAlignmentMode = .top
        nameLabel.position = CGPoint(x: -boxWidth / 2 + padding, y: boxHeight - 20)
        nameLabel.zPosition = 101
        addChild(nameLabel)

        dialogLabel = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        dialogLabel.fontSize = 35
        dialogLabel.fontColor = .white
        dialogLabel.horizontalAlignmentMode = .left
        dialogLabel.verticalAlignmentMode = .top
        dialogLabel.position = CGPoint(x: -boxWidth / 2 + padding, y: boxHeight - 60)
        dialogLabel.preferredMaxLayoutWidth = boxWidth - (padding * 2)
        dialogLabel.numberOfLines = 3
        dialogLabel.zPosition = 101
        addChild(dialogLabel)

        continueIndicator = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        continueIndicator.text = ">"
        continueIndicator.fontSize = 30
        continueIndicator.fontColor = .white
        continueIndicator.position = CGPoint(x: boxWidth / 2 - padding - 20, y: 25)
        continueIndicator.zPosition = 101
        continueIndicator.alpha = 0
        addChild(continueIndicator)

        self.alpha = 0
    }

    func showDialog(name: String, text: String, typingSpeed: TimeInterval = 0.005) {
        nameLabel.text = name
        fullText = text
        currentCharacterIndex = 0
        dialogLabel.text = ""
        isTyping = true
        continueIndicator.alpha = 0
        continueIndicator.removeAllActions()

        self.run(SKAction.fadeIn(withDuration: 0.3))

        startTypewriter(speed: typingSpeed)
    }

    func hideDialog() {
        self.removeAction(forKey: "typewriter")
        self.run(SKAction.fadeOut(withDuration: 0.3))
    }

    func handleTap() {
        if isTyping {
            self.removeAction(forKey: "typewriter")
            dialogLabel.text = fullText
            isTyping = false
            showContinueIndicator()
        } else {
            let action = onDialogComplete
            onDialogComplete = nil
            action?()
        }
    }

    private func startTypewriter(speed: TimeInterval) {
        self.removeAction(forKey: "typewriter")
        currentCharacterIndex = 0

        let typeAction = SKAction.run { [weak self] in
            guard let self = self else { return }

            if self.currentCharacterIndex < self.fullText.count {
                let index = self.fullText.index(
                    self.fullText.startIndex, offsetBy: self.currentCharacterIndex)
                self.dialogLabel.text = String(self.fullText[...index])
                self.currentCharacterIndex += 1
            } else {
                self.removeAction(forKey: "typewriter")
                self.isTyping = false
                self.showContinueIndicator()
            }
        }

        let waitAction = SKAction.wait(forDuration: speed)
        let sequence = SKAction.sequence([typeAction, waitAction])
        let repeatAction = SKAction.repeatForever(sequence)

        self.run(repeatAction, withKey: "typewriter")
    }

    private func showContinueIndicator() {
        let fadeIn = SKAction.fadeIn(withDuration: 0.4)
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.4)
        let blink = SKAction.sequence([fadeIn, fadeOut])
        continueIndicator.run(SKAction.repeatForever(blink))
    }
}

private class DialogBoxPreviewScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.12, blue: 0.2, alpha: 1.0)

        let dialog = DialogBox()
        dialog.position = CGPoint(x: size.width / 2, y: 80)
        dialog.zPosition = 100
        addChild(dialog)

        dialog.showDialog(
            name: "Robot",
            text:
                "This is your closet! Here, Shirt and Pants INHERIT from Clothing. They share color & size, but add their own properties!"
        )
    }
}

struct DialogBox_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(scene: DialogBoxPreviewScene(size: CGSize(width: 1920, height: 1080)))
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
