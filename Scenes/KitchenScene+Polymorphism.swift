//
//  KitchenScene+Polymorphism.swift
//  TorisExam
//
//  Created by Kartikay on 19/02/26.
//

import SpriteKit

extension KitchenScene {

    func startPolymorphismPhase() {
        currentPhase = .polymorphism
        currentPrepItem = 0
        updateCodeDisplay()

        let items = ["rawtomato", "rawegg", "orange"]
        let centerX = size.width * 0.35
        let spacing: CGFloat = size.width * 0.12

        for i in 0..<3 {
            let itemName = items[i]
            let sprite = SKSpriteNode(imageNamed: itemName)

            let spriteHeight: CGFloat = sprite.texture != nil ? sprite.size.height : 100

            let pScale = (size.height * 0.22) / max(spriteHeight, 1)
            sprite.setScale(pScale)

            sprite.position = CGPoint(
                x: centerX - spacing + CGFloat(i) * spacing, y: size.height * 0.58)
            sprite.zPosition = 10
            sprite.alpha = i == 0 ? 1.0 : 0.3
            sprite.name = "prepItem_\(i)"
            gameLayer.addChild(sprite)
            prepItems.append(sprite)
        }

        prepareButton = SKShapeNode(rectOf: CGSize(width: 250, height: 60), cornerRadius: 14)
        prepareButton.fillColor = SKColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 1)
        prepareButton.strokeColor = .white
        prepareButton.lineWidth = 3
        prepareButton.position = CGPoint(x: centerX, y: size.height * 0.42)
        prepareButton.zPosition = 10
        prepareButton.name = "prepareButton"
        gameLayer.addChild(prepareButton)

        let btnLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        btnLabel.text = ".prepare()"
        btnLabel.fontSize = 24
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
            let knife = SKLabelNode(text: "🔪")
            knife.fontSize = 50
            knife.position = CGPoint(x: item.position.x + 40, y: item.position.y + 40)
            knife.zPosition = 20
            gameLayer.addChild(knife)

            knife.run(
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
                        let hands = SKLabelNode(text: "�")
            hands.fontSize = 50
            hands.position = CGPoint(x: item.position.x, y: item.position.y)
            hands.zPosition = 20
            gameLayer.addChild(hands)

            hands.run(
                SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.2),
                    SKAction.scale(to: 1.0, duration: 0.2),
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
                                "One method, three different results! The tomato got sliced, the egg got cracked, and the orange got peeled. That's POLYMORPHISM! One more to go!"
                        )
                        self?.dialogBox.onDialogComplete = { [weak self] in
                            self?.clearPhaseNodes()
                            self?.startAbstractionPhase()
                        }
                    },
                ]))
        }
    }
}
