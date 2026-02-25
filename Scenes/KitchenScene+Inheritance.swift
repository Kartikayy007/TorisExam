//
//  KitchenScene+Inheritance.swift
//  TorisExam
//
//  Created by Kartikay on 19/02/26.
//

import CoreMotion
import SpriteKit
import SwiftUI

extension KitchenScene {

    func startInheritancePhase() {
        showPillarDefinition(
            title: "Inheritance",
            description:
                "A child class automatically receives all properties and methods from its parent class, saving you from repeating code."
        ) { [weak self] in
            self?.setupInheritancePhase()
        }
    }

    private func setupInheritancePhase() {
        currentPhase = .inheritance
        currentRecipeIndex = 0
        cookingStep = 0
        inheritanceDone = false

        for (_, sprite) in platformIngredients {
            sprite.removeFromParent()
        }
        platformIngredients.removeAll()

        gameLayer.enumerateChildNodes(withName: "//platform_*") { node, _ in
            node.removeFromParent()
        }

        gameLayer.childNode(withName: "fullSandwich")?.removeFromParent()
        gameLayer.childNode(withName: "plateLabel")?.removeFromParent()
        gameLayer.childNode(withName: "sandwichZone")?.removeFromParent()
        gameLayer.childNode(withName: "breadBottom")?.removeFromParent()
        gameLayer.childNode(withName: "breadTop")?.removeFromParent()

        for btn in ingredientButtons { btn.removeFromParent() }
        ingredientButtons.removeAll()
        for s in solidIngredients { s.removeFromParent() }
        solidIngredients.removeAll()

        clearPhaseNodes()
        startCookingRound(index: 0)
    }

    func startCookingRound(index: Int) {
        currentRecipeIndex = index
        cookingStep = 0
        updateCodeDisplay()
        dialogBox.onDialogComplete = nil

        cookingContainer?.removeFromParent()
        cookingContainer = SKNode()
        cookingContainer.name = "cookingContainer"
        gameLayer.addChild(cookingContainer)

        let centerX = size.width * 0.4
        let centerY = size.height * 0.50

        let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.fontSize = 22
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: centerX, y: size.height * 0.85)
        titleLabel.zPosition = 15
        cookingContainer.addChild(titleLabel)

        potSprite = SKSpriteNode(imageNamed: "normalwater")
        let potScale = (size.height * 0.5) / potSprite.size.height
        potSprite.setScale(potScale)
        potSprite.position = CGPoint(x: centerX, y: centerY)
        potSprite.zPosition = 10
        potSprite.name = "potSprite"
        cookingContainer.addChild(potSprite)

        if index == 1 {
            potSprite.isHidden = true
        }

        if index == 0 {
            setupProgressBar(stepNames: ["boil()", "addPasta()", "drain()", "serve()"])
            dialogBox.showDialog(
                name: "Robot",
                text:
                    "Let's cook Basic Pasta \u{2014} the parent recipe! This class has 4 steps. Tap the pot to start each one."
            )
        } else {
            setupProgressBar(stepNames: [
                "boil()", "addPasta()", "drain()", "serve()", "addCheese()",
            ])
            updateProgressBar(completedSteps: 0)
            dialogBox.onDialogComplete = { [weak self] in
                self?.dialogBox.hideDialog()
                self?.showInheritButton()
            }
            dialogBox.showDialog(
                name: "Robot",
                text:
                    "Mac & Cheese needs boiled pasta. Do we do all 4 steps again? No! Let's INHERIT them to save time."
            )
        }
    }

    func showBoilingPopup() {
        popupState = .boiling
        boilingProgress = 0.0
        isDraggingGauge = false
        cookingContainer?.isHidden = true

        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor(white: 0, alpha: 0.85)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 1000
        overlay.name = "boilingOverlay"
        gameLayer.addChild(overlay)
        boilingOverlay = overlay

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = "Boil the Water!"
        title.fontSize = 32
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: size.height * 0.35)
        overlay.addChild(title)

        let waterScale: CGFloat = 0.8
        let waterX: CGFloat = 170

        normalWaterSprite = SKSpriteNode(imageNamed: "normalwater")
        normalWaterSprite?.setScale(waterScale)
        normalWaterSprite?.position = CGPoint(x: waterX, y: 0)
        normalWaterSprite?.zPosition = 100
        overlay.addChild(normalWaterSprite!)

        boilingWaterSprite = SKSpriteNode(imageNamed: "boilingwater")
        boilingWaterSprite?.setScale(waterScale)
        boilingWaterSprite?.position = CGPoint(x: waterX, y: 0)
        boilingWaterSprite?.zPosition = 1002
        boilingWaterSprite?.alpha = 0
        overlay.addChild(boilingWaterSprite!)

        let gaugeWidth: CGFloat = 280
        let gaugeHeight: CGFloat = 24
        let gaugeX: CGFloat = 190
        let gaugeY: CGFloat = 0

        let trackContainer = SKNode()
        trackContainer.position = CGPoint(x: gaugeX, y: gaugeY)
        overlay.addChild(trackContainer)

        let trackBg = SKShapeNode(
            rectOf: CGSize(width: gaugeWidth, height: gaugeHeight), cornerRadius: 12)
        trackBg.fillColor = SKColor(white: 0.2, alpha: 1)
        trackBg.strokeColor = SKColor(white: 0.4, alpha: 1)
        trackBg.lineWidth = 2
        trackBg.zPosition = 1003
        trackContainer.addChild(trackBg)

        for i in 0...10 {
            let segmentWidth = gaugeWidth / 11
            let segment = SKShapeNode(
                rectOf: CGSize(width: segmentWidth - 2, height: gaugeHeight - 6), cornerRadius: 4)
            let t = CGFloat(i) / 10.0
            segment.fillColor = SKColor(
                red: t,
                green: 0.3 * (1 - t) + 0.5 * t,
                blue: 1.0 * (1 - t),
                alpha: 0.8
            )
            segment.strokeColor = .clear
            segment.position = CGPoint(
                x: -gaugeWidth / 2 + segmentWidth / 2 + CGFloat(i) * segmentWidth, y: 0)
            segment.zPosition = 1004
            trackContainer.addChild(segment)
        }

        gaugeTrack = trackBg
        trackBg.name = "gaugeTrack"

        let knob = SKShapeNode(circleOfRadius: 22)
        knob.fillColor = .white
        knob.strokeColor = SKColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 1)
        knob.lineWidth = 4
        knob.position = CGPoint(x: gaugeX - gaugeWidth / 2, y: gaugeY)
        knob.zPosition = 1010
        knob.name = "gaugeKnob"
        overlay.addChild(knob)
        gaugeKnob = knob

        let knobLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        knobLabel.fontSize = 20
        knobLabel.verticalAlignmentMode = .center
        knobLabel.horizontalAlignmentMode = .center
        knobLabel.zPosition = 1011
        knob.addChild(knobLabel)

        let tempLabel = SKLabelNode(fontNamed: "Menlo")
        tempLabel.text = "0°C"
        tempLabel.fontSize = 24
        tempLabel.fontColor = .cyan
        tempLabel.position = CGPoint(x: gaugeX, y: gaugeY - 60)
        tempLabel.zPosition = 1005
        tempLabel.name = "tempLabel"
        overlay.addChild(tempLabel)

        let hint = SKLabelNode(fontNamed: "Menlo-Italic")
        hint.text = "Drag the slider to heat the water!"
        hint.fontSize = 16
        hint.fontColor = .gray
        hint.position = CGPoint(x: gaugeX, y: gaugeY - 100)
        overlay.addChild(hint)
    }

    func updateBoilingProgress(_ progress: CGFloat) {
        if boilingProgress >= 1.0 { return }

        guard let knob = gaugeKnob,
            let boiling = boilingWaterSprite,
            let overlay = boilingOverlay
        else { return }

        boilingProgress = progress

        let gaugeWidth: CGFloat = 280
        let gaugeX: CGFloat = 180
        let startX = gaugeX - gaugeWidth / 2
        knob.position.x = startX + progress * gaugeWidth

        boiling.alpha = progress

        if let tempLabel = overlay.childNode(withName: "tempLabel") as? SKLabelNode {
            let temp = Int(progress * 100)
            tempLabel.text = "\(temp)°C"
            if progress < 0.3 {
                tempLabel.fontColor = .cyan
            } else if progress < 0.7 {
                tempLabel.fontColor = .yellow
            } else {
                tempLabel.fontColor = .orange
            }
        }

        if progress >= 1.0 {
            isDraggingGauge = false
            run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.5),
                    SKAction.run { [weak self] in
                        self?.completeBoiling()
                    },
                ]))
        }
    }

    func completeBoiling() {
        guard popupState == .boiling else { return }
        popupState = .none
        isDraggingGauge = false
        cookingContainer?.isHidden = false

        boilingOverlay?.run(
            SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent(),
            ]))

        boilingOverlay = nil
        gaugeKnob = nil
        gaugeTrack = nil
        normalWaterSprite = nil
        boilingWaterSprite = nil
        boilingProgress = 0.0

        let boiling = SKSpriteNode(imageNamed: "boilingwater")
        let bScale = (size.height * 0.55) / boiling.size.height
        boiling.setScale(bScale)
        boiling.position = potSprite.position
        boiling.zPosition = 10
        boiling.alpha = 0
        boiling.name = "potSprite"
        cookingContainer.addChild(boiling)

        potSprite.run(SKAction.fadeOut(withDuration: 0.3)) { [weak self] in
            self?.potSprite.removeFromParent()
            self?.potSprite = boiling
        }
        boiling.run(SKAction.fadeIn(withDuration: 0.3))

        if let stepLabel = cookingContainer.childNode(withName: "stepLabel") as? SKLabelNode {
            stepLabel.text =
                currentRecipeIndex == 0
                ? "boilWater() — Tap to add pasta" : "boilWater() (inherited)"
        }

        cookingStep = 1
        completedStepCount = 1
        if currentRecipeIndex == 0 {
            pastaRecipeSteps = ["boilWater()"]
        }
        updateCodeDisplay()
        dialogBox.onDialogComplete = nil

        updateProgressBar(completedSteps: 1)

        advanceCookingStep()
    }

    func showInheritButton() {
        let centerX = size.width * 0.35
        let inheritBtn = SKShapeNode(rectOf: CGSize(width: 350, height: 74), cornerRadius: 20)
        inheritBtn.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1)
        inheritBtn.strokeColor = .white
        inheritBtn.lineWidth = 4
        inheritBtn.position = CGPoint(x: centerX - 60, y: size.height * 0.45)
        inheritBtn.zPosition = 25
        inheritBtn.name = "inheritButton"
        inheritBtn.alpha = 0
        cookingContainer.addChild(inheritBtn)

        let shadow = SKShapeNode(rectOf: CGSize(width: 350, height: 74), cornerRadius: 20)
        shadow.fillColor = SKColor(white: 0, alpha: 0.2)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -6)
        shadow.zPosition = -1
        inheritBtn.addChild(shadow)

        let btnLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        btnLabel.text = "Inherit BasicPasta()"
        btnLabel.fontSize = 24
        btnLabel.fontColor = .white
        btnLabel.verticalAlignmentMode = .center
        inheritBtn.addChild(btnLabel)

        inheritBtn.run(
            SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.4),
                SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.scale(to: 1.05, duration: 0.5),
                        SKAction.scale(to: 1.0, duration: 0.5),
                    ])),
            ]))
    }

    func handleInheritTap() {
        guard let btn = cookingContainer.childNode(withName: "inheritButton") else { return }
        btn.removeFromParent()

        dialogBox.onDialogComplete = nil
        autoPlaying = true

        showConfetti()

        updateProgressBar(completedSteps: 4)

        let centerX = size.width * 0.35
        let pastaX = centerX - 120

        let boiledPasta = SKSpriteNode(imageNamed: "boiledpasta")
        let bpScale = (size.height * 0.40) / boiledPasta.size.height
        boiledPasta.setScale(bpScale)
        boiledPasta.position = CGPoint(x: centerX - 160, y: size.height * 0.50)
        boiledPasta.zPosition = 10
        boiledPasta.alpha = 0
        boiledPasta.name = "potSprite"
        cookingContainer.addChild(boiledPasta)

        potSprite.removeFromParent()
        potSprite = boiledPasta
        boiledPasta.run(SKAction.fadeIn(withDuration: 0.5))

        if let stepLabel = cookingContainer.childNode(withName: "stepLabel") as? SKLabelNode {
            stepLabel.text = "Inherited methods executed instantly!"
        }

        cookingStep = 4
        completedStepCount = 4
        pastaRecipeSteps = ["boilWater()", "addPasta()", "drain()", "serve()"]
        updateCodeDisplay()

        dialogBox.showDialog(
            name: "Robot",
            text:
                "Boom! 4 steps done instantly. That's inheritance! Now add what makes it special: the CHEESE."
        )

        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 3.5),
                SKAction.run { [weak self] in
                    self?.dialogBox.hideDialog()
                    self?.showCheeseStep()
                    self?.autoPlaying = false
                },
            ]))
    }

    func showCheeseStep() {
        guard let container = cookingContainer else { return }
        let centerX = size.width * 0.40
        let pastaX = centerX - 120

        let cheese = SKSpriteNode(imageNamed: "cheese")
        let cheeseScale = (size.height * 0.15) / cheese.size.height
        cheese.setScale(cheeseScale)
        cheese.position = CGPoint(x: centerX + 20, y: size.height * 0.50)
        cheese.zPosition = 15
        cheese.name = "cheeseItem"
        container.addChild(cheese)

        cheese.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.scale(to: cheeseScale * 1.15, duration: 0.5),
                    SKAction.scale(to: cheeseScale, duration: 0.5),
                ])))

        // let arrowLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        // arrowLabel.text = "NEW!"
        // arrowLabel.fontSize = 14
        // arrowLabel.fontColor = SKColor(red: 1, green: 0.8, blue: 0.2, alpha: 1)
        // arrowLabel.position = CGPoint(
        //     x: centerX + 60, y: size.height * 0.50 - cheese.size.height * cheeseScale * 0.7)
        // arrowLabel.zPosition = 15
        // arrowLabel.name = "cheeseLabel"
        // container.addChild(arrowLabel)

        if let stepLabel = container.childNode(withName: "stepLabel") as? SKLabelNode {
            stepLabel.text = "Drag the cheese onto the pasta!"
        }

        dialogBox.showDialog(
            name: "Robot",
            text:
                "Drag the cheese onto the pasta!"
        )
        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 2.5),
                SKAction.run { [weak self] in
                    self?.dialogBox.hideDialog()
                },
            ]))
    }

    func handleCookingTap() {
        guard !autoPlaying else { return }

        if currentRecipeIndex == 0 {
            if cookingStep == 0 {
                showBoilingPopup()
            }
        }
    }

    func pastaDroppedInPot() {
        guard let pasta = rawPastaSprite else { return }
        isDraggingPasta = false

        pasta.removeAllActions()
        pasta.run(
            SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: potSprite.position, duration: 0.3),
                    SKAction.scale(to: 0.05, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.3),
                ]),
                SKAction.removeFromParent(),
            ]))
        rawPastaSprite = nil

        if let dropZone = cookingContainer?.childNode(withName: "visible_drop_zone") {
            dropZone.run(
                SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.removeFromParent(),
                ]))
        }

        potSprite.run(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.3),
                SKAction.moveBy(x: -3, y: 0, duration: 0.05),
                SKAction.moveBy(x: 6, y: 0, duration: 0.05),
                SKAction.moveBy(x: -3, y: 0, duration: 0.05),
            ]))

        if let stepLabel = cookingContainer.childNode(withName: "stepLabel") as? SKLabelNode {
            stepLabel.text = "Pasta is cooking..."
        }

        cookingStep = 2
        completedStepCount = 2
        if currentRecipeIndex == 0 {
            pastaRecipeSteps = ["boilWater()", "addPasta()"]
        }
        updateCodeDisplay()
        updateProgressBar(completedSteps: cookingStep)

        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 1.5),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    print(
                        "🍝 [DEBUG] Swapping boiling water to normal water, cookingStep=\(self.cookingStep)"
                    )
                    let normalWater = SKSpriteNode(imageNamed: "normalwater")
                    let nScale = (self.size.height * 0.55) / normalWater.size.height
                    normalWater.setScale(nScale)
                    normalWater.position = self.potSprite.position
                    normalWater.zPosition = 10
                    normalWater.alpha = 0
                    normalWater.name = "potSprite"
                    self.cookingContainer.addChild(normalWater)

                    self.potSprite.run(SKAction.fadeOut(withDuration: 0.3)) { [weak self] in
                        self?.potSprite.removeFromParent()
                        self?.potSprite = normalWater
                    }
                    normalWater.run(SKAction.fadeIn(withDuration: 0.3))

                    print(
                        "🍝 [DEBUG] Calling advanceCookingStep for drain, cookingStep=\(self.cookingStep)"
                    )
                    self.advanceCookingStep()
                },
            ]))
    }

    func startTiltDetection() {
        isWaitingForTilt = true
        guard motionManager.isDeviceMotionAvailable else {
            let drainBtn = SKShapeNode(rectOf: CGSize(width: 260, height: 60), cornerRadius: 14)
            drainBtn.fillColor = SKColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1)
            drainBtn.strokeColor = .white
            drainBtn.lineWidth = 3
            drainBtn.position = CGPoint(x: size.width * 0.30, y: size.height * 0.25)
            drainBtn.zPosition = 25
            drainBtn.name = "drainButton"
            cookingContainer.addChild(drainBtn)

            let btnLabel = SKLabelNode(fontNamed: "Menlo-Bold")
            btnLabel.text = "Tap to Strain"
            btnLabel.fontSize = 22
            btnLabel.fontColor = .white
            btnLabel.verticalAlignmentMode = .center
            drainBtn.addChild(btnLabel)

            drainBtn.run(
                SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.scale(to: 1.05, duration: 0.5),
                        SKAction.scale(to: 1.0, duration: 0.5),
                    ])))
            return
        }

        var initialRoll: Double? = nil

        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run { [weak self] in
                    guard let self = self, self.isWaitingForTilt else { return }
                    self.motionManager.deviceMotionUpdateInterval = 0.1
                    self.motionManager.startDeviceMotionUpdates(to: .main) {
                        [weak self] motion, _ in
                        guard let self = self, self.isWaitingForTilt, let motion = motion else {
                            return
                        }
                        let pitch = motion.attitude.pitch

                        if initialRoll == nil {
                            initialRoll = pitch
                            return
                        }

                        let pitchDelta = pitch - (initialRoll ?? pitch)

                        if abs(pitchDelta) > 0.30 {
                            self.completeDrain()
                        }
                    }
                },
            ]))
    }

    func handleDrainButtonTap() {
        guard isWaitingForTilt else { return }
        cookingContainer.childNode(withName: "drainButton")?.removeFromParent()
        completeDrain()
    }

    func completeDrain() {
        guard isWaitingForTilt else { return }
        isWaitingForTilt = false
        motionManager.stopDeviceMotionUpdates()
        cookingContainer.childNode(withName: "drainButton")?.removeFromParent()
        print("🍝 [DEBUG] completeDrain running, cookingStep=\(cookingStep)")

        let centerX = size.width * 0.30
        let strain = SKSpriteNode(imageNamed: "pastaStrain")
        let sScale = (size.height * 0.45) / strain.size.height
        strain.setScale(sScale)
        strain.position = CGPoint(x: centerX - 20, y: size.height * 0.50)
        strain.zPosition = 10
        strain.alpha = 0
        strain.name = "potSprite"
        cookingContainer.addChild(strain)

        potSprite.run(SKAction.fadeOut(withDuration: 0.5)) { [weak self] in
            self?.potSprite.removeFromParent()
            self?.potSprite = strain
        }
        strain.run(SKAction.fadeIn(withDuration: 0.5))

        if let stepLabel = cookingContainer.childNode(withName: "stepLabel") as? SKLabelNode {
            stepLabel.text = "drain() — Pasta strained!"
        }

        cookingStep = 3
        completedStepCount = 3
        if currentRecipeIndex == 0 {
            pastaRecipeSteps = ["boilWater()", "addPasta()", "drain()"]
        }
        updateCodeDisplay()
        updateProgressBar(completedSteps: cookingStep)

        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    let boiledPasta = SKSpriteNode(imageNamed: "boiledpasta")
                    let bpScale = (self.size.height * 0.45) / boiledPasta.size.height
                    boiledPasta.setScale(bpScale)
                    boiledPasta.position = CGPoint(x: centerX, y: self.size.height * 0.50)
                    boiledPasta.zPosition = 10
                    boiledPasta.alpha = 0
                    boiledPasta.name = "potSprite"
                    self.cookingContainer.addChild(boiledPasta)

                    self.potSprite.run(SKAction.fadeOut(withDuration: 0.5)) { [weak self] in
                        self?.potSprite.removeFromParent()
                        self?.potSprite = boiledPasta
                    }
                    boiledPasta.run(SKAction.fadeIn(withDuration: 0.5))

                    if let stepLabel = self.cookingContainer.childNode(withName: "stepLabel")
                        as? SKLabelNode
                    {
                        stepLabel.text = "serve() — Boiled pasta ready!"
                    }

                    self.cookingStep = 4
                    self.completedStepCount = 4
                    self.pastaRecipeSteps = ["boilWater()", "addPasta()", "drain()", "serve()"]
                    self.updateCodeDisplay()
                    self.updateProgressBar(completedSteps: self.cookingStep)

                    self.run(
                        SKAction.sequence([
                            SKAction.wait(forDuration: 1.5),
                            SKAction.run { [weak self] in
                                self?.finishRound1()
                            },
                        ]))
                },
            ]))
    }

    func handleCheeseTap() {
        guard currentRecipeIndex == 1, !autoPlaying else { return }
        isDraggingCheese = true
    }

    func cheeseDroppedOnPasta() {
        guard currentRecipeIndex == 1 else { return }
        isDraggingCheese = false

        if let cheese = cookingContainer.childNode(withName: "cheeseItem") as? SKSpriteNode {
            cheese.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.move(to: potSprite.position, duration: 0.3),
                        SKAction.scale(to: 0.05, duration: 0.3),
                        SKAction.fadeOut(withDuration: 0.3),
                    ]),
                    SKAction.removeFromParent(),
                ]))
        }
        cookingContainer.childNode(withName: "cheeseLabel")?.removeFromParent()

        autoPlaying = true
        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    let macCheese = SKSpriteNode(imageNamed: "macchessepasta")
                    let resultScale = (self.size.height * 0.30) / macCheese.size.height
                    macCheese.setScale(resultScale)
                    macCheese.position = CGPoint(
                        x: self.size.width * 0.40 - 160, y: self.size.height * 0.50)
                    macCheese.zPosition = 10
                    macCheese.alpha = 0
                    self.cookingContainer.addChild(macCheese)

                    self.potSprite.run(SKAction.fadeOut(withDuration: 0.5))
                    macCheese.run(SKAction.fadeIn(withDuration: 0.5))

                    self.updateProgressBar(completedSteps: 5)

                    if let stepLabel = self.cookingContainer.childNode(withName: "stepLabel")
                        as? SKLabelNode
                    {
                        stepLabel.text = "addCheese() \u{2014} Mac & Cheese ready!"
                    }

                    self.cookingStep = 5
                    self.completedStepCount = 5
                    self.pastaRecipeSteps = [
                        "boilWater()", "addPasta()", "drain()", "serve()", "addCheese()",
                    ]
                    self.updateCodeDisplay()

                    self.run(
                        SKAction.sequence([
                            SKAction.wait(forDuration: 1.5),
                            SKAction.run { [weak self] in
                                self?.autoPlaying = false
                                self?.finishCookingPhase()
                            },
                        ]))
                },
            ]))
    }

    func advanceCookingStep() {
        let centerX = size.width * 0.40

        switch cookingStep {
        case 0:
            let boiling = SKSpriteNode(imageNamed: "boilingwater")
            let bScale = (size.height * 0.45) / boiling.size.height
            boiling.setScale(bScale)
            boiling.position = CGPoint(x: potSprite.position.x - 40, y: potSprite.position.y)
            boiling.zPosition = 10
            boiling.alpha = 0
            boiling.name = "potSprite"
            cookingContainer.addChild(boiling)

            potSprite.run(SKAction.fadeOut(withDuration: 0.3)) { [weak self] in
                self?.potSprite.removeFromParent()
                self?.potSprite = boiling
            }
            boiling.run(SKAction.fadeIn(withDuration: 0.3))

            if let stepLabel = cookingContainer.childNode(withName: "stepLabel") as? SKLabelNode {
                stepLabel.text =
                    currentRecipeIndex == 0
                    ? "boilWater() \u{2014} Tap to add pasta" : "boilWater() (inherited)"
            }

        case 1:
            let rawPasta = SKSpriteNode(imageNamed: "rawpasta")
            let pScale = (size.height * 0.2) / rawPasta.size.height
            rawPasta.setScale(pScale)
            rawPasta.position = CGPoint(x: centerX + 20, y: size.height * 0.50)
            rawPasta.zPosition = 20
            rawPasta.name = "rawPastaSprite"
            cookingContainer.addChild(rawPasta)
            rawPastaSprite = rawPasta

            rawPasta.run(
                SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.scale(to: pScale * 1.08, duration: 0.5),
                        SKAction.scale(to: pScale, duration: 0.5),
                    ])))

            let dropZone = SKShapeNode(rectOf: CGSize(width: 220, height: 200), cornerRadius: 16)
            dropZone.strokeColor = SKColor(white: 1.0, alpha: 0.5)
            dropZone.fillColor = SKColor(white: 1.0, alpha: 0.1)
            dropZone.lineWidth = 4
            let path = CGMutablePath()
            path.addRoundedRect(
                in: CGRect(x: -110, y: -100, width: 220, height: 200), cornerWidth: 16,
                cornerHeight: 16)
            let dashedPath = path.copy(dashingWithPhase: 0, lengths: [10, 10])
            dropZone.path = dashedPath

            dropZone.position = CGPoint(x: centerX - 250, y: size.height * 0.50)
            dropZone.zPosition = 5
            dropZone.name = "visible_drop_zone"
            cookingContainer.addChild(dropZone)

            let dropLbl = SKLabelNode(fontNamed: "Menlo-Bold")
            dropLbl.text = "DROP HERE"
            dropLbl.fontSize = 20
            dropLbl.fontColor = SKColor(white: 1.0, alpha: 0.7)
            dropLbl.position = CGPoint(x: 0, y: 0)
            dropLbl.verticalAlignmentMode = .center
            dropZone.addChild(dropLbl)

            dropZone.run(
                SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.6, duration: 0.8),
                        SKAction.fadeAlpha(to: 1.0, duration: 0.8),
                    ])
                ))

            if let stepLabel = cookingContainer.childNode(withName: "stepLabel") as? SKLabelNode {
                stepLabel.text = "Drag the pasta into the pot!"
            }
            dialogBox.onDialogComplete = nil
            dialogBox.showDialog(
                name: "Robot",
                text: "addPasta() — Drag the pasta into the pot!"
            )
            run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 2.5),
                    SKAction.run { [weak self] in
                        self?.dialogBox.hideDialog()
                    },
                ]))
            return

        case 2:
            if let stepLabel = cookingContainer.childNode(withName: "stepLabel") as? SKLabelNode {
                stepLabel.text = "Tilt your device to strain!"
            }
            dialogBox.onDialogComplete = nil
            dialogBox.showDialog(
                name: "Robot",
                text: "drain() — Tilt your device to strain the pasta!"
            )
            run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 2.5),
                    SKAction.run { [weak self] in
                        self?.dialogBox.hideDialog()
                    },
                ]))
            startTiltDetection()
            return

        case 3:
            let served = SKSpriteNode(imageNamed: "macchessepasta")
            let svScale = (size.height * 0.30) / served.size.height
            served.setScale(svScale)
            served.position = CGPoint(x: centerX - 160, y: size.height * 0.50)
            served.zPosition = 10
            served.alpha = 0
            served.name = "potSprite"
            cookingContainer.addChild(served)

            potSprite.run(SKAction.fadeOut(withDuration: 0.3)) { [weak self] in
                self?.potSprite.removeFromParent()
                self?.potSprite = served
            }
            served.run(SKAction.fadeIn(withDuration: 0.3))

            if let stepLabel = cookingContainer.childNode(withName: "stepLabel") as? SKLabelNode {
                stepLabel.text = "serve() (inherited)"
            }

        default:
            break
        }

        cookingStep += 1
        completedStepCount = cookingStep

        if currentRecipeIndex == 0 {
            pastaRecipeSteps = Array(
                ["boilWater()", "addPasta()", "drain()", "serve()"].prefix(cookingStep))
        } else {
            pastaRecipeSteps = Array(
                ["boilWater()", "addPasta()", "drain()", "serve()", "addCheese()"].prefix(
                    cookingStep))
        }
        updateCodeDisplay()
        updateProgressBar(completedSteps: cookingStep)
    }

    func finishRound1() {
        showConfetti()
        dialogBox.showDialog(
            name: "Robot",
            text:
                "Basic Pasta done! We wrote 4 methods: boilWater, addPasta, drain, and serve."
        )
        dialogBox.onDialogComplete = { [weak self] in
            self?.dialogBox.showDialog(
                name: "Tori",
                text: "But... I don't want basic pasta! I want Mac & Cheese!"
            )
            self?.dialogBox.onDialogComplete = { [weak self] in
                self?.dialogBox.showDialog(
                    name: "Robot",
                    text:
                        "Mac & Cheese? That means we have to do all 4 steps again! ...Just kidding!"
                )
                self?.dialogBox.onDialogComplete = { [weak self] in
                    self?.dialogBox.showDialog(
                        name: "Robot",
                        text: "We can save time using INHERITANCE. Let me show you how it works."
                    )
                    self?.dialogBox.onDialogComplete = { [weak self] in
                        self?.startCookingRound(index: 1)
                    }
                }
            }
        }
    }

    func finishCookingPhase() {
        showConfetti()
        dialogBox.showDialog(
            name: "Robot",
            text:
                "That's INHERITANCE! Mac & Cheese reused all of Basic Pasta's steps without rewriting a single line."
        )
        dialogBox.onDialogComplete = { [weak self] in
            self?.dialogBox.showDialog(
                name: "Robot",
                text: "Next up: POLYMORPHISM!"
            )
            self?.dialogBox.onDialogComplete = { [weak self] in
                self?.cookingContainer?.removeFromParent()
                self?.clearPhaseNodes()
                self?.startPolymorphismPhase()
            }
        }
    }

    func debugTag(node: SKNode?, name: String, in parent: SKNode?) {
        guard showDebugOverlay, let node = node, let parent = parent else { return }
        parent.childNode(withName: "dbg_\(name)")?.removeFromParent()

        let bg = SKShapeNode(rectOf: CGSize(width: 280, height: 44), cornerRadius: 6)
        bg.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        bg.strokeColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 0.9)
        bg.lineWidth = 1.5
        bg.zPosition = 900
        bg.name = "dbg_\(name)"
        bg.position = CGPoint(x: node.position.x, y: node.position.y + 90)
        parent.addChild(bg)

        let xPct = String(format: "%.3f", node.position.x / size.width)
        let yPct = String(format: "%.3f", node.position.y / size.height)
        let sc = String(format: "%.3f", node.xScale)

        let lbl = SKLabelNode(fontNamed: "Menlo-Bold")
        lbl.fontSize = 12
        lbl.fontColor = SKColor(red: 1, green: 0.9, blue: 0.3, alpha: 1)
        lbl.verticalAlignmentMode = .center
        lbl.text = "[\(name)]  x:\(xPct) y:\(yPct) sc:\(sc)"
        lbl.zPosition = 901
        bg.addChild(lbl)
    }

    func setupProgressBar(stepNames: [String]) {
        stepProgressBar?.removeFromParent()
        stepProgressIcons.removeAll()

        let barNode = SKNode()
        let totalSteps = stepNames.count

        let maxAvailableWidth = size.width * 0.48
        let calculatedSpacing = maxAvailableWidth / CGFloat(max(1, totalSteps - 1))
        let spacing: CGFloat = min(130.0, calculatedSpacing)

        let totalWidth = CGFloat(totalSteps - 1) * spacing
        let startX = -totalWidth / 2

        let track = SKShapeNode(rectOf: CGSize(width: totalWidth, height: 10), cornerRadius: 5)
        track.fillColor = SKColor(white: 0.85, alpha: 1.0)
        track.strokeColor = .clear
        track.zPosition = 48
        track.position = CGPoint(x: 0, y: 0)
        barNode.addChild(track)

        let trackFill = SKSpriteNode(
            color: SKColor.systemGreen, size: CGSize(width: totalWidth, height: 10))
        trackFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        trackFill.position = CGPoint(x: startX, y: 0)
        trackFill.zPosition = 49
        trackFill.xScale = 0.001
        trackFill.name = "trackFill"
        barNode.addChild(trackFill)

        for i in 0..<totalSteps {
            let circle = SKShapeNode(circleOfRadius: 24)
            circle.fillColor = SKColor(white: 0.85, alpha: 1.0)
            circle.strokeColor = .clear
            circle.position = CGPoint(x: startX + CGFloat(i) * spacing, y: 0)
            circle.zPosition = 50
            barNode.addChild(circle)
            stepProgressIcons.append(circle)

            let numLabel = SKLabelNode(fontNamed: "Menlo-Bold")
            numLabel.text = "\(i + 1)"
            numLabel.fontSize = 22
            numLabel.fontColor = .darkGray
            numLabel.verticalAlignmentMode = .center
            numLabel.name = "numLabel"
            numLabel.zPosition = 51
            circle.addChild(numLabel)

            let stepLabel = SKLabelNode(fontNamed: "Menlo-Bold")
            stepLabel.text = stepNames[i]
            stepLabel.fontSize = 20

            let shadow = SKLabelNode(fontNamed: "Menlo-Bold")
            shadow.text = stepNames[i]
            shadow.fontSize = 20
            shadow.fontColor = .black
            shadow.alpha = 0.5
            shadow.position = CGPoint(x: 2, y: -2)
            shadow.zPosition = -1
            stepLabel.addChild(shadow)

            stepLabel.fontColor = SKColor(white: 0.9, alpha: 1.0)
            stepLabel.horizontalAlignmentMode = .center
            stepLabel.position = CGPoint(x: 0, y: -45)
            stepLabel.zPosition = 51
            stepLabel.name = "nameLabel"
            circle.addChild(stepLabel)
        }

        barNode.position = CGPoint(x: size.width * 0.32, y: size.height * 0.88)
        barNode.zPosition = 50
        cookingContainer?.addChild(barNode)
        stepProgressBar = barNode
    }

    func updateProgressBar(completedSteps: Int) {
        let activeColor = SKColor.white
        let completedColor = SKColor.systemGreen
        let inactiveColor = SKColor(white: 0.85, alpha: 1.0)
        let inactiveTextColor = SKColor(white: 0.75, alpha: 1.0)

        if let trackFill = stepProgressBar?.childNode(withName: "trackFill") {
            let totalIcons = max(1, stepProgressIcons.count - 1)
            let cappedCompleted = min(completedSteps, totalIcons)
            let safeFraction = CGFloat(cappedCompleted) / CGFloat(totalIcons)
            trackFill.run(SKAction.scaleX(to: max(safeFraction, 0.001), duration: 0.4))
        }

        for i in 0..<stepProgressIcons.count {
            let circle = stepProgressIcons[i]
            let oldColor = circle.fillColor

            if i < completedSteps {
                circle.fillColor = completedColor
                if let numLbl = circle.childNode(withName: "numLabel") as? SKLabelNode {
                    numLbl.fontColor = .white
                }
                if let nameLbl = circle.childNode(withName: "nameLabel") as? SKLabelNode {
                    nameLbl.fontColor = completedColor
                    nameLbl.alpha = 1.0
                }
            } else if i == completedSteps {
                circle.fillColor = activeColor
                if let numLbl = circle.childNode(withName: "numLabel") as? SKLabelNode {
                    numLbl.fontColor = .black
                }
                if let nameLbl = circle.childNode(withName: "nameLabel") as? SKLabelNode {
                    nameLbl.fontColor = .white
                    nameLbl.alpha = 1.0
                }
            } else {
                circle.fillColor = inactiveColor
                if let numLbl = circle.childNode(withName: "numLabel") as? SKLabelNode {
                    numLbl.fontColor = inactiveTextColor
                }
                if let nameLbl = circle.childNode(withName: "nameLabel") as? SKLabelNode {
                    nameLbl.fontColor = inactiveTextColor
                    nameLbl.alpha = 1.0
                }
            }

            if oldColor != circle.fillColor {
                circle.run(
                    SKAction.sequence([
                        SKAction.scale(to: 1.35, duration: 0.15),
                        SKAction.scale(to: 1.0, duration: 0.15),
                    ]))
            }
        }
    }
}


private class KitchenSceneInheritancePreview: KitchenScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        startInheritancePhase()
    }
}

struct KitchenSceneInheritance_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(scene: KitchenSceneInheritancePreview(size: CGSize(width: 1920, height: 1080)))
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
