//
//  BlueprintScene.swift
//  Donut
//
//  Created by kartikay on 25/01/26.
//

import SpriteKit
import SwiftUI

class BlueprintScene: BaseScene {

    private var boy: SKSpriteNode!
    private var dialogBox: DialogBox!
    private var codeLabel: SKLabelNode!

    private var clothesSlot: SKSpriteNode!
    private var bagSlot: SKSpriteNode!

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
        setupCodePanel()
        setupSlots()
        setupDialogBox()
        showIntroDialog()
    }

    private func setupScene() {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)

        boy = SKSpriteNode(imageNamed: "Standing")
        boy.position = CGPoint(x: size.width * 0.65, y: size.height * 0.5)
        boy.zPosition = 1
        let boyScale = (size.height * 0.7) / boy.size.height
        boy.setScale(boyScale)
        boy.alpha = 0.4
        gameLayer.addChild(boy)
    }

    private func setupCodePanel() {
        let codeText = """
            class Human {
                var clothes: Clothing?
                var bag: Bag?
            }
            """

        codeLabel = SKLabelNode(fontNamed: "Menlo")
        codeLabel.text = codeText
        codeLabel.fontSize = 24
        codeLabel.fontColor = .green
        codeLabel.numberOfLines = 0
        codeLabel.horizontalAlignmentMode = .left
        codeLabel.verticalAlignmentMode = .top
        codeLabel.position = CGPoint(x: 40, y: size.height - 40)
        codeLabel.zPosition = 10
        gameLayer.addChild(codeLabel)
    }

    private func setupSlots() {
        clothesSlot = SKSpriteNode(color: .gray, size: CGSize(width: 80, height: 80))
        clothesSlot.position = CGPoint(x: size.width * 0.65, y: size.height * 0.7)
        clothesSlot.alpha = 0.3
        clothesSlot.zPosition = 5
        clothesSlot.name = "clothesSlot"
        gameLayer.addChild(clothesSlot)

        let clothesLabel = SKLabelNode(text: "👕")
        clothesLabel.fontSize = 40
        clothesLabel.position = .zero
        clothesSlot.addChild(clothesLabel)

        bagSlot = SKSpriteNode(color: .gray, size: CGSize(width: 80, height: 80))
        bagSlot.position = CGPoint(x: size.width * 0.65, y: size.height * 0.35)
        bagSlot.alpha = 0.3
        bagSlot.zPosition = 5
        bagSlot.name = "bagSlot"
        gameLayer.addChild(bagSlot)

        let bagLabel = SKLabelNode(text: "🎒")
        bagLabel.fontSize = 40
        bagLabel.position = .zero
        bagSlot.addChild(bagLabel)
    }

    private func setupDialogBox() {
        dialogBox = DialogBox()
        dialogBox.position = CGPoint(x: size.width / 2, y: 120)
        dialogBox.zPosition = 100
        gameLayer.addChild(dialogBox)

        dialogBox.onDialogComplete = { [weak self] in
            self?.dialogBox.hideDialog()
        }
    }

    private func showIntroDialog() {
        dialogBox.showDialog(
            name: "Robot", text: "This is YOU! But you're not ready yet. Let's fill these slots!")
    }

    override func handleTouch(at location: CGPoint, touch: UITouch) {
        let tappedNodes = nodes(at: location)

        for node in tappedNodes {
            if node.name == "clothesSlot" {
                return
            }
            if node.name == "bagSlot" {
                return
            }
        }

        dialogBox.handleTap()
    }
}
