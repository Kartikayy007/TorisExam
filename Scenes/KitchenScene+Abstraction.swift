//
//  KitchenScene+Abstraction.swift
//  TorisExam
//
//  Created by Kartikay on 19/02/26.
//

import SpriteKit
import UIKit

extension KitchenScene {

    func startAbstractionPhase() {
        showPillarDefinition(
            title: "Abstraction",
            description:
                "Hiding complex, multi-step code behind one simple, easy-to-use function name."
        ) { [weak self] in
            self?.setupAbstractionPhase()
        }
    }

    private func setupAbstractionPhase() {
        currentPhase = .abstraction
        absorbedCount = 0
        absorbedMethods.removeAll()
        stepButtons.removeAll()
        updateCodeDisplay()

        let centerX = size.width * 0.35
        let centerY = size.height * 0.45

        packLunchButton = SKShapeNode(rectOf: CGSize(width: 280, height: 80), cornerRadius: 20)
        packLunchButton.fillColor = SKColor(white: 0.4, alpha: 1.0)
        packLunchButton.strokeColor = .white
        packLunchButton.lineWidth = 3
        packLunchButton.position = CGPoint(x: centerX - 60, y: centerY)
        packLunchButton.zPosition = 10
        packLunchButton.name = "packLunchBtn"
        gameLayer.addChild(packLunchButton)

        packLunchButton.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.scale(to: 1.08, duration: 0.8),
                    SKAction.scale(to: 1.0, duration: 0.8),
                ])))

        let bigLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        bigLabel.text = "packLunch()"
        bigLabel.fontSize = 32
        bigLabel.fontColor = .white
        bigLabel.verticalAlignmentMode = .center
        packLunchButton.addChild(bigLabel)

        let gridYStart = centerY + 100
        let gridXStart = centerX - 180
        let xSpacing: CGFloat = 240
        let ySpacing: CGFloat = 70

        let positions: [CGPoint] = [
            CGPoint(x: gridXStart, y: gridYStart + ySpacing * 2),
            CGPoint(x: gridXStart + xSpacing, y: gridYStart + ySpacing * 2),
            CGPoint(x: gridXStart, y: gridYStart + ySpacing),
            CGPoint(x: gridXStart + xSpacing, y: gridYStart + ySpacing),
            CGPoint(x: gridXStart, y: gridYStart),
            CGPoint(x: gridXStart + xSpacing, y: gridYStart),
        ]

        for i in 0..<stepMethods.count {
            let btn = SKShapeNode(rectOf: CGSize(width: 230, height: 50), cornerRadius: 10)
            btn.fillColor = SKColor(red: 0.5, green: 0.3, blue: 0.3, alpha: 0.9)
            btn.strokeColor = .white
            btn.lineWidth = 2
            btn.position = positions[i]
            btn.zPosition = 15
            btn.name = "stepBtn_\(i)"

            let dict = NSMutableDictionary()
            dict["originalPos"] = NSValue(cgPoint: positions[i])
            btn.userData = dict

            gameLayer.addChild(btn)

            let label = SKLabelNode(fontNamed: "Menlo-Bold")
            label.text = stepMethods[i]
            label.fontSize = 24
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            btn.addChild(label)

            stepButtons.append(btn)
        }

        dialogBox.showDialog(
            name: "Robot",
            text:
                "Last pillar — ABSTRACTION! We can hide all these steps behind one simple function. Drag each step into packLunch() to combine them!"
        )

        let handCursor: SKNode
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold)
        if let uiImage = UIImage(systemName: "hand.point.up.left.fill", withConfiguration: config)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        {
            let texture = SKTexture(image: uiImage)
            handCursor = SKSpriteNode(texture: texture)
        } else {
            let label = SKLabelNode(text: "👆")
            label.fontSize = 50
            handCursor = label
        }
        handCursor.position = positions[3]
        handCursor.zPosition = 100
        gameLayer.addChild(handCursor)

        let dragToPack = SKAction.move(to: packLunchButton.position, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let resetPos = SKAction.run { handCursor.position = positions[3] }
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        handCursor.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    fadeIn, SKAction.wait(forDuration: 0.2), dragToPack, fadeOut, resetPos,
                    SKAction.wait(forDuration: 0.5),
                ])))
        handCursor.name = "handCursor"
    }

    func absorbStep(methodName: String) {
        gameLayer.childNode(withName: "handCursor")?.removeFromParent()
        absorbedCount += 1
        absorbedMethods.append(methodName)
        updateCodeDisplay()

        if let miniConfetti = SKEmitterNode(fileNamed: "Confetti") {
            miniConfetti.position = packLunchButton.position
            miniConfetti.particlePositionRange = CGVector(dx: 240, dy: 60)
            miniConfetti.numParticlesToEmit = 15
            miniConfetti.particleBirthRate = 200
            miniConfetti.zPosition = 100
            gameLayer.addChild(miniConfetti)
            run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 2.0),
                    SKAction.run { miniConfetti.removeFromParent() },
                ]))
        }

        let progress = CGFloat(absorbedCount) / CGFloat(stepMethods.count)
        let r = 0.4 + (0.2 - 0.4) * progress
        let g = 0.4 + (0.7 - 0.4) * progress
        let b = 0.4 + (0.3 - 0.4) * progress
        packLunchButton.fillColor = SKColor(red: r, green: g, blue: b, alpha: 1.0)

        if absorbedCount >= stepMethods.count {
            packLunchButton.name = "packLunchFinalAction"

            let pulseUp = SKAction.scale(to: 1.05, duration: 0.6)
            let pulseDown = SKAction.scale(to: 1.0, duration: 0.6)
            packLunchButton.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))

            dialogBox.showDialog(
                name: "Robot",
                text:
                    "All the steps are now hidden inside packLunch()! One simple call does everything. Click on the packLunch() button"
            )
            dialogBox.onDialogComplete = { [weak self] in
                self?.dialogBox.showDialog(
                    name: "Robot",
                    text: "Tap the packLunch() function to execute it and pack the lunchbox!"
                )
                self?.dialogBox.onDialogComplete = nil
            }
        }
    }

    func triggerFinalPackingAnimation() {
        guard let btn = gameLayer.childNode(withName: "packLunchFinalAction") else { return }
        let targetPos = btn.position
        btn.removeFromParent()

        autoPlaying = true
        dialogBox.hideDialog()

        let lunchbox = SKSpriteNode(imageNamed: "lunchbox")
        lunchbox.setScale(0.1)
        lunchbox.position = targetPos
        lunchbox.zPosition = 5
        lunchbox.name = "lunchboxMock"
        gameLayer.addChild(lunchbox)

        lunchbox.run(
            SKAction.sequence([
                SKAction.scale(to: 0.35, duration: 0.3),
                SKAction.scale(to: 0.3, duration: 0.2),
                SKAction.run { [weak self] in
                    self?.dropFoodItems(into: lunchbox, lunchboxScale: 0.3)
                },
            ]))
    }

    private func dropFoodItems(into lunchbox: SKSpriteNode, lunchboxScale: CGFloat) {
        let items = ["sandwich", "macchessepasta", "peeledorange"]
        var delay: TimeInterval = 0.0

        let dropHeight = size.height * 0.8
        let finalY = lunchbox.position.y  // Drop exactly to its center

        for (i, itemName) in items.enumerated() {
            let food = SKSpriteNode(imageNamed: itemName)
            let foodScale = (size.height * 0.15) / max(food.size.height, 1)
            food.setScale(0.0)

            let dropX = lunchbox.position.x + CGFloat((i - 1) * 80)
            food.position = CGPoint(x: dropX, y: dropHeight)
            food.zPosition = lunchbox.zPosition - 1
            gameLayer.addChild(food)

            let wait = SKAction.wait(forDuration: delay)
            let appear = SKAction.scale(to: foodScale, duration: 0.2)

            let drop = SKAction.move(to: CGPoint(x: dropX, y: finalY), duration: 0.4)
            drop.timingMode = .easeIn

            let shrink = SKAction.scale(to: 0.0, duration: 0.2)

            let group = SKAction.group([
                drop,
                SKAction.sequence([SKAction.wait(forDuration: 0.3), shrink]),
            ])

            food.run(SKAction.sequence([wait, appear, group, SKAction.removeFromParent()]))

            delay += 0.3
        }

        run(SKAction.wait(forDuration: delay + 0.6)) { [weak self] in
            self?.finishAbstractionGame()
        }
    }

    private func finishAbstractionGame() {
        self.autoPlaying = false
        showConfetti()
        currentPhase = .done
        updateCodeDisplay()

        dialogBox.showDialog(
            name: "Robot",
            text: "All the steps are now hidden inside packLunch()! That's ABSTRACTION!"
        )
        dialogBox.onDialogComplete = { [weak self] in
            guard let self = self else { return }
            self.clearPhaseNodes()

            let robo = SKSpriteNode(imageNamed: "roboidea")
            robo.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            robo.zPosition = 10
            let scale =
                min(self.size.width / robo.size.width, self.size.height / robo.size.height) * 0.8
            robo.setScale(max(scale, 1.0))
            self.gameLayer.addChild(robo)

            self.dialogBox.showDialog(
                name: "Robot",
                text: "You are ready for school, let's go!"
            )
            self.dialogBox.onDialogComplete = {
                self.autoPlaying = false
                NotificationCenter.default.post(
                    name: Notification.Name("TriggerStartExam"), object: nil)
            }
        }
    }
}
