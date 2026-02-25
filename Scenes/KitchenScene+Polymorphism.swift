//
//  KitchenScene+Polymorphism.swift
//  TorisExam
//
//  Created by Kartikay on 19/02/26.
//

import SpriteKit

extension KitchenScene {

    func startPolymorphismPhase() {
        showPillarDefinition(
            title: "Polymorphism",
            description:
                "Different classes can have a method with the exact same name, but each performs its own unique behavior when called."
        ) { [weak self] in
            self?.setupPolymorphismPhase()
        }
    }

    private func setupPolymorphismPhase() {
        currentPhase = .polymorphism
        currentPrepItem = 0
        updateCodeDisplay()

        let items = ["rawtomato", "rawegg", "orange"]
        let centerX = size.width * 0.30
        let spacing: CGFloat = size.width * 0.12

        for i in 0..<3 {
            let itemName = items[i]
            let sprite = SKSpriteNode(imageNamed: itemName)

            let spriteHeight: CGFloat = sprite.texture != nil ? sprite.size.height : 100

            let pScale = (size.height * 0.17) / max(spriteHeight, 1)
            sprite.setScale(pScale)
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)

            sprite.position = CGPoint(
                x: centerX - spacing + CGFloat(i) * spacing, y: size.height * 0.445)
            sprite.zPosition = 10
            sprite.alpha = i == 0 ? 1.0 : 0.3
            sprite.name = "prepItem_\(i)"
            gameLayer.addChild(sprite)
            prepItems.append(sprite)
        }

        prepareButton = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 14)
        prepareButton.fillColor = SKColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 1)
        prepareButton.strokeColor = .white
        prepareButton.lineWidth = 3
        prepareButton.position = CGPoint(x: centerX, y: size.height * 0.36)
        prepareButton.zPosition = 10
        prepareButton.name = "prepareButton"
        gameLayer.addChild(prepareButton)

        let pulseUp = SKAction.scale(to: 1.05, duration: 0.8)
        pulseUp.timingMode = .easeInEaseOut
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.8)
        pulseDown.timingMode = .easeInEaseOut
        prepareButton.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))

        let btnLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        btnLabel.text = ".prepare()"
        btnLabel.fontSize = 20
        btnLabel.fontColor = .white
        btnLabel.verticalAlignmentMode = .center
        prepareButton.addChild(btnLabel)

        dialogBox.showDialog(
            name: "Robot",
            text:
                "Same method name, different behavior — that's POLYMORPHISM! Tap .prepare() and watch each lunch item do something different."
        )
    }

    func prepareCurrentItem() {
        guard currentPrepItem < prepItems.count else { return }

        let item = prepItems[currentPrepItem]

        prepareButton.run(
            SKAction.sequence([
                SKAction.run { [weak self] in
                    self?.prepareButton.name = ""
                    self?.prepareButton.fillColor = SKColor(
                        red: 1.0, green: 0.6, blue: 0.2, alpha: 1)
                },
                SKAction.wait(forDuration: 0.2),
                SKAction.run { [weak self] in
                    self?.prepareButton.fillColor = SKColor(
                        red: 0.8, green: 0.4, blue: 0.1, alpha: 1)
                },
            ]))

        switch currentPrepItem {
        case 0:
            let cutLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
            cutLabel.text = "Slice!"
            cutLabel.fontSize = 28
            cutLabel.fontColor = .systemRed
            cutLabel.position = CGPoint(
                x: item.position.x, y: item.position.y + item.frame.height + 20)
            cutLabel.zPosition = 20
            gameLayer.addChild(cutLabel)

            cutLabel.run(
                SKAction.sequence([
                    SKAction.moveBy(x: -40, y: -40, duration: 0.2),
                    SKAction.moveBy(x: 20, y: 20, duration: 0.1),
                    SKAction.moveBy(x: -40, y: -40, duration: 0.1),
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent(),
                ]))

            item.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.4),
                    SKAction.run {
                        if let sprite = item as? SKSpriteNode {
                            sprite.texture = SKTexture(imageNamed: "tomato")
                        }
                    },
                ]))

        case 1:
            let crackLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
            crackLabel.text = "Crack!"
            crackLabel.fontSize = 28
            crackLabel.fontColor = .orange
            crackLabel.position = CGPoint(
                x: item.position.x, y: item.position.y + item.frame.height + 20)
            crackLabel.zPosition = 20
            gameLayer.addChild(crackLabel)

            crackLabel.run(
                SKAction.sequence([
                    SKAction.moveBy(x: 0, y: 15, duration: 0.2),
                    SKAction.moveBy(x: 0, y: 5, duration: 0.1),
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent(),
                ]))

            item.run(
                SKAction.sequence([
                    SKAction.moveBy(x: 0, y: 40, duration: 0.15),
                    SKAction.moveBy(x: 0, y: -40, duration: 0.15),
                    SKAction.run {
                        if let sprite = item as? SKSpriteNode {
                            sprite.texture = SKTexture(imageNamed: "crackedegg")
                        }
                    },
                    SKAction.scale(to: item.xScale * 1.2, duration: 0.1),
                    SKAction.scale(to: item.xScale * 1.0, duration: 0.1),
                ]))

        default:
            let peelLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
            peelLabel.text = "Peel!"
            peelLabel.fontSize = 28
            peelLabel.fontColor = .systemYellow
            peelLabel.position = CGPoint(
                x: item.position.x, y: item.position.y + item.frame.height + 20)
            peelLabel.zPosition = 20
            gameLayer.addChild(peelLabel)

            peelLabel.run(
                SKAction.sequence([
                    SKAction.moveBy(x: 0, y: 15, duration: 0.2),
                    SKAction.moveBy(x: 0, y: 5, duration: 0.1),
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent(),
                ]))

            item.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.4),
                    SKAction.run {
                        if let sprite = item as? SKSpriteNode {
                            sprite.texture = SKTexture(imageNamed: "peeledorange")
                        }
                    },
                    SKAction.scale(to: item.xScale * 1.1, duration: 0.1),
                    SKAction.scale(to: item.xScale * 1.0, duration: 0.1),
                ]))
        }

        currentPrepItem += 1
        updateCodeDisplay()

        if currentPrepItem < prepItems.count {
            prepItems[currentPrepItem].run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))

            run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 1.2),
                    SKAction.run { [weak self] in
                        self?.prepareCurrentItem()
                    },
                ]))
        }

        if currentPrepItem >= 3 {
            run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.8),
                    SKAction.run { [weak self] in
                        self?.showConfetti()
                        self?.dialogBox.showDialog(
                            name: "Robot",
                            text:
                                "One method, three different results! The tomato got sliced, the egg got cracked, and the orange got peeled. That's POLYMORPHISM!"
                        )
                        self?.dialogBox.onDialogComplete = { [weak self] in
                            self?.dialogBox.showDialog(
                                name: "Robot",
                                text: "One more to go. Next up: ABSTRACTION!"
                            )
                            self?.dialogBox.onDialogComplete = { [weak self] in
                                self?.clearPhaseNodes()
                                self?.startAbstractionPhase()
                            }
                        }
                    },
                ]))
        }
    }
}
