//
//  OOPIntroScene.swift
//  Toris Exam
//
//  Created by kartikay on 08/02/26
//

import SpriteKit
import SwiftUI

class OOPIntroScene: BaseScene {

    private var roomBg: SKSpriteNode!
    private var bgBlurNode: SKEffectNode!
    private var blurOverlay: SKShapeNode!
    private var robotOverlay: SKSpriteNode!
    private var dialogBox: DialogBox!
    private var closetHighlight: SKNode!

    private var dialogIndex = 0
    private var isShowingCloset = false

    private let dialogs = [
        "Object-Oriented Programming is a technique to design a program using Classes and Objects.",
        "You might be thinking... what are Classes and Objects? Let's learn as you get your clothes ready!",
    ]

    override func sceneDidSetup() {
        setupScene()
        setupDialogBox()
        showCurrentDialog()
    }

    private func setupScene() {

        bgBlurNode = SKEffectNode()
        bgBlurNode.shouldRasterize = true
        bgBlurNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 8])
        bgBlurNode.zPosition = 0

        roomBg = SKSpriteNode(imageNamed: "Room")
        roomBg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let roomScale = max(size.width / roomBg.size.width, size.height / roomBg.size.height)
        roomBg.setScale(roomScale)
        bgBlurNode.addChild(roomBg)
        gameLayer.addChild(bgBlurNode)

        blurOverlay = SKShapeNode(rectOf: CGSize(width: size.width * 2, height: size.height * 2))
        blurOverlay.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        blurOverlay.strokeColor = .clear
        blurOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        blurOverlay.zPosition = 1
        blurOverlay.alpha = 0
        gameLayer.addChild(blurOverlay)
        blurOverlay.run(SKAction.fadeIn(withDuration: 0.5))

        robotOverlay = SKSpriteNode(imageNamed: "roboexplain")
        robotOverlay.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        robotOverlay.zPosition = 5
        let robotScale = (size.height * 0.85) / robotOverlay.size.height
        robotOverlay.setScale(robotScale)
        robotOverlay.alpha = 0
        gameLayer.addChild(robotOverlay)
        robotOverlay.run(SKAction.fadeIn(withDuration: 0.5))

        let glowContainer = SKEffectNode()
        glowContainer.shouldRasterize = true
        glowContainer.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 30])
        glowContainer.position = CGPoint(x: size.width * 0.46, y: size.height * 0.82)
        glowContainer.zPosition = 3
        glowContainer.alpha = 0
        glowContainer.name = "closet"

        let innerGlow = SKShapeNode(rectOf: CGSize(width: 340, height: 380), cornerRadius: 12)
        innerGlow.fillColor = SKColor.white
        innerGlow.strokeColor = .clear
        glowContainer.addChild(innerGlow)

        gameLayer.addChild(glowContainer)
        closetHighlight = glowContainer
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

    private func showCurrentDialog() {
        guard dialogIndex < dialogs.count else {
            removeOverlayAndShowCloset()
            return
        }
        dialogBox.showDialog(name: "Robot", text: dialogs[dialogIndex])
    }

    private func advanceDialog() {
        dialogIndex += 1
        showCurrentDialog()
    }

    private func removeOverlayAndShowCloset() {
        isShowingCloset = true

        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        robotOverlay.run(fadeOut)
        dialogBox.hideDialog()
        blurOverlay.run(fadeOut)

        bgBlurNode.filter = nil

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let pulseUp = SKAction.fadeAlpha(to: 0.6, duration: 0.8)
        let pulseDown = SKAction.fadeAlpha(to: 0.2, duration: 0.8)
        let pulse = SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown]))

        closetHighlight.run(SKAction.sequence([fadeIn, pulse]))

        let hintLabel = SKLabelNode(text: "Tap the closet!")
        hintLabel.fontSize = 28
        hintLabel.fontName = "AvenirNext-Bold"
        hintLabel.fontColor = .yellow
        hintLabel.position = CGPoint(x: size.width / 2, y: 100)
        hintLabel.zPosition = 20
        hintLabel.name = "closetHint"
        gameLayer.addChild(hintLabel)
    }

    private func enterCloset() {
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.1),
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
        ])
        closetHighlight.run(SKAction.repeat(flash, count: 3)) { [weak self] in
            self?.navigateTo(.closet)
        }
    }

    override func handleTouch(at location: CGPoint, touch: UITouch) {
        if isShowingCloset {
            let tappedNodes = nodes(at: location)
            for node in tappedNodes {
                if node.name == "closet" {
                    enterCloset()
                    return
                }
            }
        } else {
            dialogBox.handleTap()
        }
    }
}

struct OOPIntroScene_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(scene: OOPIntroScene(size: CGSize(width: 1920, height: 1080)))
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
