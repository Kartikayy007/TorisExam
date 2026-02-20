// 
//  KitchenScene+Encapsulation.swift
//  TorisExam
//
//  Created by Kartikay on 19/02/26.
//

import SpriteKit

extension KitchenScene {

    func startEncapsulationPhase() {
        currentPhase = .encapsulation
        ingredientsAdded.removeAll()
        ingredientButtons.removeAll()
        solidIngredients.removeAll()
        popupState = .none
        platformIngredients.removeAll()

        let lineY = size.height * 0.43
        let startX = size.width * 0.18
        let spacing = size.width * 0.08
        sandwichZone = CGPoint(x: size.width * 0.25, y: lineY)

        let plateLabel = SKLabelNode(fontNamed: "Menlo")
        plateLabel.fontSize = 14
        plateLabel.fontColor = .darkGray
        plateLabel.position = CGPoint(x: size.width * 0.25, y: lineY - 120)
        plateLabel.zPosition = 10
        plateLabel.name = "plateLabel"
        gameLayer.addChild(plateLabel)

        dialogBox.showDialog(
            name: "Robot",
            text:
                "Let's prep the sandwich ingredients! Tap each one and paint it to get it ready."
        )

        let allItems = ["bread", "cheese", "tomato", "spinach"]
        for i in 0..<allItems.count {
            let item = allItems[i]
            let sprite = SKSpriteNode(imageNamed: item)
            sprite.setScale(0.3)
            sprite.position = CGPoint(x: startX + CGFloat(i) * spacing, y: lineY)
            sprite.zPosition = 25 + CGFloat(i)
            sprite.name = "platform_\(item)"
            sprite.color = .gray
            sprite.colorBlendFactor = 1.0
            sprite.alpha = 0.4
            gameLayer.addChild(sprite)
            platformIngredients[item] = sprite

            sprite.run(
                SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.6, duration: 1.0),
                        SKAction.fadeAlpha(to: 0.4, duration: 1.0),
                    ])))
        }

        updateCodeDisplay()
    }

    func showTracingPopup(for item: String) {
        guard !ingredientsAdded.contains(item) else { return }
        currentPopupItem = item
        popupState = .painting
        paintedCells.removeAll()
        if item == "bread" {
            paintThreshold = 220
        } else if item == "spinach" {
            paintThreshold = 180
        } else {
            paintThreshold = 100
        }
        isPainting = false

        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor(white: 0, alpha: 0.85)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 1000
        overlay.name = "popupOverlay"
        gameLayer.addChild(overlay)
        popupOverlay = overlay

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = "Color \(item.capitalized) to Reveal!"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: size.height * 0.35)
        overlay.addChild(title)

        let spriteScale: CGFloat = 1.8

        let graySprite = SKSpriteNode(imageNamed: item)
        graySprite.setScale(spriteScale)
        graySprite.position = .zero
        graySprite.zPosition = 1001
        graySprite.color = .gray
        graySprite.colorBlendFactor = 1.0
        graySprite.alpha = 0.8
        overlay.addChild(graySprite)

        let cropNode = SKCropNode()
        cropNode.position = .zero
        cropNode.zPosition = 1002
        overlay.addChild(cropNode)
        colorCropNode = cropNode

        let coloredSprite = SKSpriteNode(imageNamed: item)
        coloredSprite.setScale(spriteScale)
        coloredSprite.position = .zero
        cropNode.addChild(coloredSprite)

        let mask = SKNode()
        cropNode.maskNode = mask
        paintMaskNode = mask

        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 12
        let barBg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 6)
        barBg.fillColor = SKColor(white: 0.3, alpha: 0.8)
        barBg.strokeColor = SKColor(white: 0.5, alpha: 0.5)
        barBg.lineWidth = 1
        barBg.position = CGPoint(x: 0, y: -size.height * 0.35)
        barBg.zPosition = 1005
        overlay.addChild(barBg)
        progressBar = barBg

        let fill = SKShapeNode(rectOf: CGSize(width: 1, height: barHeight - 4), cornerRadius: 4)
        fill.fillColor = SKColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 1)
        fill.strokeColor = .clear
        fill.position = CGPoint(x: -barWidth / 2, y: 0)
        fill.xScale = 0.01
        fill.zPosition = 1006
        barBg.addChild(fill)
        progressFill = fill

        let hint = SKLabelNode(fontNamed: "Menlo-Italic")
        hint.text = "Paint with your finger to reveal the color!"
        hint.fontSize = 16
        hint.fontColor = .gray
        hint.position = CGPoint(x: 0, y: -size.height * 0.4)
        overlay.addChild(hint)

        addCloseButton(to: overlay)
    }

    func addCloseButton(to overlay: SKNode) {
        let closeBtn = SKShapeNode(circleOfRadius: 30)
        closeBtn.fillColor = .red
        closeBtn.position = CGPoint(x: size.width * 0.4, y: size.height * 0.4)
        closeBtn.name = "popupClose"
        closeBtn.zPosition = 1005
        overlay.addChild(closeBtn)
        let xLbl = SKLabelNode(text: "X")
        xLbl.verticalAlignmentMode = .center
        closeBtn.addChild(xLbl)
    }

    func paintAt(_ location: CGPoint) {
        guard let overlay = popupOverlay, let mask = paintMaskNode else { return }
        let localPoint = overlay.convert(location, from: self)

        let brushSize: CGFloat = 90

        if let last = lastPaintPoint {
            let dist = hypot(localPoint.x - last.x, localPoint.y - last.y)
            if dist < 15 { return }
        }
        lastPaintPoint = localPoint

        let circle = SKShapeNode(circleOfRadius: brushSize)
        circle.fillColor = .white
        circle.strokeColor = .clear
        circle.position = localPoint
        mask.addChild(circle)

        let cellSize: CGFloat = 30
        let cellX = Int(floor(localPoint.x / cellSize))
        let cellY = Int(floor(localPoint.y / cellSize))
        let cellKey = "\(cellX),\(cellY)"
        guard !paintedCells.contains(cellKey) else { return }
        paintedCells.insert(cellKey)
        paintStrokeCount += 1

        if paintStrokeCount % 5 == 0 {
            spawnPaintSplatter(at: localPoint, in: overlay)
        }

        let progress = min(CGFloat(paintStrokeCount) / CGFloat(paintThreshold), 1.0)
        if let fill = progressFill {
            let barWidth: CGFloat = 200
            fill.xScale = max(progress * barWidth, 1)
            fill.position.x = -barWidth / 2 + (progress * barWidth) / 2

            fill.fillColor = SKColor(
                red: 0.2 * (1 - progress),
                green: 0.7 + 0.3 * progress,
                blue: 0.3 * (1 - progress),
                alpha: 1
            )
        }

        if paintStrokeCount >= paintThreshold {
            paintingComplete()
        }
    }

    func spawnPaintSplatter(at point: CGPoint, in parent: SKNode) {
        for _ in 0..<3 {
            let splat = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...8))
            splat.fillColor = SKColor(
                red: CGFloat.random(in: 0.4...1.0),
                green: CGFloat.random(in: 0.4...1.0),
                blue: CGFloat.random(in: 0.4...1.0),
                alpha: 0.8
            )
            splat.strokeColor = .clear
            splat.position = CGPoint(
                x: point.x + CGFloat.random(in: -20...20),
                y: point.y + CGFloat.random(in: -20...20)
            )
            splat.zPosition = 1010
            parent.addChild(splat)

            splat.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeOut(withDuration: 0.4),
                        SKAction.scale(to: 0.1, duration: 0.4),
                        SKAction.moveBy(
                            x: CGFloat.random(in: -15...15),
                            y: CGFloat.random(in: -15...15),
                            duration: 0.4
                        ),
                    ]),
                    SKAction.removeFromParent(),
                ]))
        }
    }

    func paintingComplete() {
        isPainting = false
        popupState = .none

        colorCropNode?.run(
            SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.15),
            ]))

        run(SKAction.wait(forDuration: 0.8)) { [weak self] in
            self?.closePopup(success: true)
        }
    }

    func closePopup(success: Bool) {
        let item = currentPopupItem

        popupOverlay?.removeAllChildren()
        popupOverlay?.removeFromParent()
        popupOverlay = nil
        colorCropNode = nil
        paintMaskNode = nil
        currentPopupItem = nil
        popupState = .none
        paintedCells.removeAll()
        paintStrokeCount = 0
        isPainting = false
        lastPaintPoint = nil
        progressBar = nil
        progressFill = nil

        if success, let i = item {
            addIngredientToSandwich(i)
        }
    }

    func closeBoilingPopup() {
        boilingOverlay?.removeAllChildren()
        boilingOverlay?.removeFromParent()
        boilingOverlay = nil
        gaugeKnob = nil
        gaugeTrack = nil
        normalWaterSprite = nil
        boilingWaterSprite = nil
        boilingProgress = 0.0
        popupState = .none
        isDraggingGauge = false
        cookingContainer?.isHidden = false
    }

    func addIngredientToSandwich(_ item: String) {
        if ingredientsAdded.contains(item) { return }
        ingredientsAdded.append(item)

        if let platformSprite = platformIngredients[item] {
            platformSprite.removeAllActions()
            platformSprite.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeAlpha(to: 1.0, duration: 0.4),
                        SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.4),
                        SKAction.scale(to: 0.35, duration: 0.2),
                    ]),
                    SKAction.scale(to: 0.3, duration: 0.1),
                ]))

            let check = SKLabelNode(text: "")
            check.fontSize = 30
            check.position = CGPoint(x: 0, y: -30)
            check.verticalAlignmentMode = .center
            check.zPosition = 5
            check.setScale(0)
            platformSprite.addChild(check)
            check.run(SKAction.scale(to: 1.0, duration: 0.2))
        }

        updateCodeDisplay()

        if ingredientsAdded.count >= 4 {
            run(SKAction.wait(forDuration: 1.0)) { [weak self] in
                self?.completeSandwich()
            }
        }
    }

    func completeSandwich() {
        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run { [weak self] in
                    guard let self = self else { return }

                    ["bread", "cheese", "tomato", "spinach"].forEach {
                        self.gameLayer.childNode(withName: "platform_\($0)")?.removeFromParent()
                    }
                    self.platformIngredients.removeAll()

                    let fullSandwich = SKSpriteNode(imageNamed: "sandwich")
                    fullSandwich.position = self.sandwichZone
                    fullSandwich.setScale(0)
                    fullSandwich.zPosition = 30
                    fullSandwich.name = "fullSandwich"
                    self.gameLayer.addChild(fullSandwich)

                    fullSandwich.run(
                        SKAction.sequence([
                            SKAction.scale(to: 0.5, duration: 0.3),
                            SKAction.scale(to: 0.4, duration: 0.15),
                        ]))

                    self.sandwichDone = true
                    self.updateCodeDisplay()
                    self.showConfetti()

                    self.gameLayer.childNode(withName: "plateLabel")?.removeFromParent()

                    self.dialogBox.showDialog(
                        name: "Robot",
                        text:
                            "The bread wraps around all the ingredients \u{2014} they're now hidden inside! That's ENCAPSULATION: data bundled together and protected from the outside."
                    )
                    self.dialogBox.onDialogComplete = { [weak self] in
                        self?.gameLayer.childNode(withName: "fullSandwich")?.run(
                            SKAction.sequence([
                                SKAction.wait(forDuration: 0.3),
                                SKAction.fadeOut(withDuration: 0.5),
                                SKAction.removeFromParent(),
                            ]))
                        self?.dialogBox.showDialog(
                            name: "Robot",
                            text:
                                "Time for the 2nd pillar \u{2014} INHERITANCE! It means creating new classes based on existing ones. A child class can reuse all the methods of its parent, without rewriting them."
                        )
                        self?.dialogBox.onDialogComplete = { [weak self] in
                            self?.dialogBox.showDialog(
                                name: "Robot",
                                text:
                                    "Let's see it in action! We'll cook pasta. First, a basic recipe \u{2014} then a fancier one that INHERITS all the base steps."
                            )
                            self?.dialogBox.onDialogComplete = { [weak self] in
                                self?.startInheritancePhase()
                            }
                        }
                    }
                },
            ]))
    }
}
