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

        let items = ["🥪", "🍎", "🧃"]
        let centerX = size.width * 0.62

        for i in 0..<3 {
            let item = SKLabelNode(text: items[i])
            item.fontSize = 80
            item.position = CGPoint(x: centerX - 180 + CGFloat(i) * 180, y: size.height * 0.65)
            item.zPosition = 10
            item.alpha = i == 0 ? 1.0 : 0.3
            item.name = "prepItem_\(i)"
            gameLayer.addChild(item)
            prepItems.append(item)
        }

        prepareButton = SKShapeNode(rectOf: CGSize(width: 280, height: 70), cornerRadius: 16)
        prepareButton.fillColor = SKColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 1)
        prepareButton.strokeColor = .white
        prepareButton.lineWidth = 3
        prepareButton.position = CGPoint(x: centerX, y: size.height * 0.42)
        prepareButton.zPosition = 10
        prepareButton.name = "prepareButton"
        gameLayer.addChild(prepareButton)

        let btnLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        btnLabel.text = ".prepare()"
        btnLabel.fontSize = 28
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
            let scissors = SKLabelNode(text: "✂️")
            scissors.fontSize = 50
            scissors.position = CGPoint(x: item.position.x + 80, y: item.position.y)
            scissors.zPosition = 20
            gameLayer.addChild(scissors)
            scissors.run(
                SKAction.sequence([
                    SKAction.move(to: item.position, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent(),
                ]))
            item.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.3),
                    SKAction.scaleX(to: 1.3, duration: 0.1),
                    SKAction.scaleX(to: 1.0, duration: 0.1),
                ]))

        case 1:
            let drops = SKLabelNode(text: "💧")
            drops.fontSize = 40
            drops.position = CGPoint(x: item.position.x, y: item.position.y + 60)
            drops.zPosition = 20
            gameLayer.addChild(drops)
            drops.run(
                SKAction.sequence([
                    SKAction.move(to: item.position, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent(),
                ]))
            item.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.2),
                    SKAction.scale(to: 1.3, duration: 0.15),
                    SKAction.scale(to: 1.0, duration: 0.15),
                ]))

        default:
            item.run(
                SKAction.repeat(
                    SKAction.sequence([
                        SKAction.moveBy(x: -10, y: 0, duration: 0.05),
                        SKAction.moveBy(x: 20, y: 0, duration: 0.05),
                        SKAction.moveBy(x: -10, y: 0, duration: 0.05),
                    ]), count: 4))
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
                                "One method, three different results! The sandwich got cut, the apple got washed, the juice got shaken. That's POLYMORPHISM! One more to go!"
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
