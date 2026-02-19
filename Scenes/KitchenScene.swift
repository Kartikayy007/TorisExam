//
//  KitchenScene.swift
//  Toris Exam
//
//  Created by kartikay on 13/02/26.
//

import CoreMotion
import SpriteKit
import SwiftUI

class KitchenScene: BaseScene {

    enum Phase: Int {
        case intro = 0
        case encapsulation = 1
        case inheritance = 2
        case polymorphism = 3
        case abstraction = 4
        case done = 5
    }

    private var currentPhase: Phase = .intro
    private var currentStep = 0
    var previewBoilingPopup = false
    var previewPastaCooking = false

    private var dialogBox: DialogBox!
    private var roboExplain: SKSpriteNode!
    private var codePanel: SKShapeNode!
    private var codeLabel: SKLabelNode!
    private var codeCropNode: SKCropNode!
    private var codeContentNode: SKNode!
    private var codePanelWidth: CGFloat = 0
    private var codePanelHeight: CGFloat = 0

    private var isScrollingCodePanel = false
    private var lastScrollY: CGFloat = 0

    private var breadBottom: SKSpriteNode!
    private var breadTop: SKSpriteNode!
    private var ingredientSlots: [SKSpriteNode] = []
    private var sandwichIngredients: [String] = []
    private var sandwichZone: CGPoint = .zero
    private var sandwichDone = false
    private var placedIngredientCount = 0

    private enum PopupState { case none, painting, boiling }
    private var popupState: PopupState = .none

    private var popupOverlay: SKShapeNode?
    private var currentPopupItem: String?
    private var colorCropNode: SKCropNode?
    private var paintMaskNode: SKNode?
    private var paintStrokeCount: Int = 0
    private var paintThreshold: Int = 180
    private var isPainting: Bool = false
    private var lastPaintPoint: CGPoint? = nil
    private var paintedCells: Set<String> = []
    private var progressBar: SKShapeNode?
    private var progressFill: SKShapeNode?

    private var gaugeKnob: SKShapeNode?
    private var gaugeTrack: SKShapeNode?
    private var boilingProgress: CGFloat = 0.0
    private var normalWaterSprite: SKSpriteNode?
    private var boilingWaterSprite: SKSpriteNode?
    private var boilingOverlay: SKShapeNode?
    private var isDraggingGauge = false

    private var rawPastaSprite: SKSpriteNode?
    private var isDraggingPasta = false
    private let motionManager = CMMotionManager()
    private var isWaitingForTilt = false

    private var platformIngredients: [String: SKSpriteNode] = [:]

    private var ingredientsAdded: [String] = []
    private var ingredientButtons: [SKSpriteNode] = []
    private var solidIngredients: [SKSpriteNode] = []

    private var pastaRecipeSteps: [String] = []
    private var currentRecipeIndex = 0
    private var completedStepCount = 0
    private var recipeContainer: SKNode!
    private var autoPlaying = false

    private var prepareButton: SKShapeNode!
    private var prepItems: [SKLabelNode] = []
    private var currentPrepItem = 0

    private var stepButtons: [SKNode] = []
    private var packLunchButton: SKShapeNode!
    private var draggedStepButton: SKNode?
    private var absorbedCount = 0
    private let stepMethods = [
        "cutSandwich()", "washApple()", "shakeJuice()", "closeLid()", "addIcePack()", "zipBag()",
    ]

    override func sceneDidSetup() {

        let bg = SKSpriteNode(imageNamed: "kitchenbg")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        bg.size = size
        gameLayer.addChild(bg)

        let platform = SKSpriteNode(imageNamed: "kitchenplatform")

        platform.position = CGPoint(x: size.width * 0.45, y: size.height * 0.3)
        platform.zPosition = -5
        platform.setScale(0.85)
        platform.zRotation = CGFloat.pi / 2
        gameLayer.addChild(platform)

        setupCodePanel()
        setupDialogBox()
        updateCodeDisplay()

        showIntro()

        if previewBoilingPopup {
            dialogBox.isHidden = true
            roboExplain.isHidden = true
            currentPhase = .inheritance
            cookingStep = 0
            cookingContainer = SKNode()
            cookingContainer.name = "cookingContainer"
            gameLayer.addChild(cookingContainer)
            potSprite = SKSpriteNode(imageNamed: "normalwater")
            potSprite.name = "potSprite"
            showBoilingPopup()
        }

        if previewPastaCooking {
            roboExplain.run(SKAction.fadeOut(withDuration: 0.1))
            startInheritancePhase()
        }
    }

    private func setupCodePanel() {
        let panelWidth = size.width * 0.35
        let panelHeight = size.height * 0.65
        codePanelWidth = panelWidth
        codePanelHeight = panelHeight

        codePanel = SKShapeNode(
            rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 16)
        codePanel.fillColor = SKColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 0.95)
        codePanel.strokeColor = SKColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 0.8)
        codePanel.lineWidth = 2

        codePanel.position = CGPoint(x: size.width * 0.68, y: size.height * 0.6)
        codePanel.zPosition = 5
        gameLayer.addChild(codePanel)

        codeCropNode = SKCropNode()
        let maskNode = SKShapeNode(rectOf: CGSize(width: panelWidth - 20, height: panelHeight - 40))
        maskNode.fillColor = .white
        codeCropNode.maskNode = maskNode
        codePanel.addChild(codeCropNode)

        codeContentNode = SKNode()
        codeCropNode.addChild(codeContentNode)

        codeLabel = SKLabelNode()
        codeLabel.fontName = "Menlo-Regular"
        codeLabel.fontSize = min(22, panelWidth * 0.05)
        codeLabel.fontColor = SKColor(red: 0.6, green: 1.0, blue: 0.6, alpha: 1)
        codeLabel.numberOfLines = 0
        codeLabel.preferredMaxLayoutWidth = panelWidth - 40
        codeLabel.verticalAlignmentMode = .top
        codeLabel.horizontalAlignmentMode = .left
        codeLabel.position = CGPoint(x: -(panelWidth / 2) + 20, y: (panelHeight / 2) - 30)
        codeContentNode.addChild(codeLabel)
    }

    private func setupDialogBox() {
        dialogBox = DialogBox()
        dialogBox.position = CGPoint(x: size.width / 2, y: 80)
        dialogBox.zPosition = 100
        gameLayer.addChild(dialogBox)

        roboExplain = SKSpriteNode(imageNamed: "roboexplain")
        let roboScale = (size.height * 0.25) / roboExplain.size.height
        roboExplain.setScale(roboScale)
        roboExplain.position = CGPoint(x: size.width * 0.08, y: 180)
        roboExplain.zPosition = 101
        roboExplain.alpha = 0
        gameLayer.addChild(roboExplain)
    }

    private func updateCodeDisplay() {
        var code = ""
        switch currentPhase {
        case .intro:
            code = "// The 4 Pillars of OOP\n\n"
            code += "// 1. Encapsulation\n"
            code += "// 2. Inheritance\n"
            code += "// 3. Polymorphism\n"
            code += "// 4. Abstraction"

        case .encapsulation:
            code = "class Sandwich {\n"
            code += "  // Ingredients ENCAPSULATED (Hidden)\n"

            for item in ingredientsAdded {
                code += "  private var \(item): Ingredient 🔒\n"
            }

            if ingredientsAdded.count < 3 {
                code += "  // ... add more ingredients\n"
            }

            code += "  func eat() {\n"
            code += "    // Access hidden data internally\n"
            code += "  }\n"
            code += "}"

            if sandwichDone {
                code += "\n\nlet lunch = Sandwich()\n"
                code += "// Ingredients are PRIVATE"
            }

        case .inheritance:
            if currentRecipeIndex == 0 {
                code = "class BasicPasta {\n"
                for step in pastaRecipeSteps {
                    code += "  func \(step) { }\n"
                }
                if pastaRecipeSteps.count < 4 {
                    code += "  // ... more steps to go\n"
                }
                code += "}\n"
            } else {
                code = "class BasicPasta {\n"
                code += "  func boilWater() { }\n"
                code += "  func addPasta()  { }\n"
                code += "  func drain()     { }\n"
                code += "  func serve()     { }\n"
                code += "}\n\n"
                code += "// Child inherits from Parent:\n"
                code += "class MacAndCheese: BasicPasta {\n"
                code += "  // boilWater()  inherited\n"
                code += "  // addPasta()   inherited\n"
                code += "  // drain()      inherited\n"
                code += "  // serve()      inherited\n"
                if completedStepCount >= 5 {
                    code += "  func addCheese() { } // NEW!\n"
                } else {
                    code += "  // ... add your own step!\n"
                }
                code += "}\n"
            }

        case .polymorphism:
            code = "// Same method name,\n"
            code += "// different behavior!\n\n"
            if currentPrepItem >= 1 {
                code += "sandwich.prepare()\n"
                code += "  // → cuts in half \n\n"
            }
            if currentPrepItem >= 2 {
                code += "apple.prepare()\n"
                code += "  // → washes clean \n\n"
            }
            if currentPrepItem >= 3 {
                code += "juice.prepare()\n"
                code += "  // → shakes up \n"
            }

        case .abstraction:
            code = "func packLunch() {\n"
            for i in 0..<stepMethods.count {
                if i < absorbedCount {
                    code += "  \(stepMethods[i])\n"
                }
            }
            code += "}\n\n"
            if absorbedCount >= stepMethods.count {
                code += "// One simple call!\n"
                code += "packLunch() // Done!"
            }

        case .done:
            code = "// All 4 Pillars Complete!\n\n"
            code += "// Encapsulation\n"
            code += "// Inheritance\n"
            code += "// Polymorphism\n"
            code += "// Abstraction\n\n"
            code += "// Tori's lunch is packed!"
        }
        codeLabel.text = code
        codeContentNode.position.y = 0
    }

    private func showIntro() {
        roboExplain.run(SKAction.fadeIn(withDuration: 0.3))
        dialogBox.showDialog(
            name: "Robot",
            text:
                "Welcome to the Kitchen! Let's pack Tori's lunch and learn the 4 pillars of OOP!"
        )
        dialogBox.onDialogComplete = { [weak self] in
            self?.dialogBox.showDialog(
                name: "Robot",
                text:
                    "First up: ENCAPSULATION! It means bundling data together and hiding it inside a class — so nothing outside can mess with it."
            )
            self?.dialogBox.onDialogComplete = { [weak self] in
                self?.roboExplain.run(SKAction.fadeOut(withDuration: 0.3))
                self?.startEncapsulationPhase()
            }
        }
    }

    private func startEncapsulationPhase() {
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
        //        plateLabel.text = "Sandwich Builder"
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

    private func showTracingPopup(for item: String) {
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

    private func addCloseButton(to overlay: SKNode) {
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

    private func showBoilingPopup() {
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
        let waterX: CGFloat = 0

        normalWaterSprite = SKSpriteNode(imageNamed: "normalwater")
        normalWaterSprite?.setScale(waterScale)
        normalWaterSprite?.position = CGPoint(x: waterX, y: 0)
        normalWaterSprite?.zPosition = 1001
        overlay.addChild(normalWaterSprite!)

        boilingWaterSprite = SKSpriteNode(imageNamed: "boilingwater")
        boilingWaterSprite?.setScale(waterScale)
        boilingWaterSprite?.position = CGPoint(x: waterX, y: 0)
        boilingWaterSprite?.zPosition = 1002
        boilingWaterSprite?.alpha = 0
        overlay.addChild(boilingWaterSprite!)

        let gaugeWidth: CGFloat = 280
        let gaugeHeight: CGFloat = 24
        let gaugeX: CGFloat = 180
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
        //        knobLabel.text = "🔥"
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

        addCloseButton(to: overlay)
    }

    private func updateBoilingProgress(_ progress: CGFloat) {
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

        //        if progress > 0.6 && Bool.random() {
        //            spawnSteamParticle(at: CGPoint(x: -180, y: 50), in: overlay)
        //        }

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

    //    private func spawnSteamParticle(at point: CGPoint, in parent: SKNode) {
    //        let steam = SKLabelNode(text: "💨")
    //        steam.fontSize = CGFloat.random(in: 20...35)
    //        steam.position = CGPoint(x: point.x + CGFloat.random(in: -30...30), y: point.y)
    //        steam.zPosition = 1020
    //        steam.alpha = 0.7
    //        parent.addChild(steam)
    //
    //        steam.run(
    //            SKAction.sequence([
    //                SKAction.group([
    //                    SKAction.moveBy(x: CGFloat.random(in: -20...20), y: 60, duration: 1.0),
    //                    SKAction.fadeOut(withDuration: 1.0),
    //                    SKAction.scale(to: 1.5, duration: 1.0),
    //                ]),
    //                SKAction.removeFromParent(),
    //            ]))
    //    }

    private func completeBoiling() {
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

        advanceCookingStep()
    }

    private func paintAt(_ location: CGPoint) {
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

    private func spawnPaintSplatter(at point: CGPoint, in parent: SKNode) {
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

    private func paintingComplete() {
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

    private func closePopup(success: Bool) {
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

    private func closeBoilingPopup() {
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

    private func addIngredientToSandwich(_ item: String) {
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

    private func completeSandwich() {
        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run { [weak self] in
                    guard let self = self else { return }

                    self.gameLayer.childNode(withName: "platform_bread")?.removeFromParent()
                    for (_, sprite) in self.platformIngredients {
                        sprite.removeFromParent()
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

    private var cookingContainer: SKNode!
    private var potSprite: SKSpriteNode!
    private var cookingStep = 0
    private var inheritanceDone = false

    private func startInheritancePhase() {
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

    private func startCookingRound(index: Int) {
        currentRecipeIndex = index
        cookingStep = 0
        updateCodeDisplay()
        dialogBox.onDialogComplete = nil

        cookingContainer?.removeFromParent()
        cookingContainer = SKNode()
        cookingContainer.name = "cookingContainer"
        gameLayer.addChild(cookingContainer)

        let centerX = size.width * 0.30
        let centerY = size.height * 0.50

        let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.fontSize = 22
        titleLabel.fontColor = .white
        //        if index == 0 {
        //            titleLabel.text = "Basic Pasta (Parent Class)"
        //        } else {
        //            titleLabel.text = "Mac & Cheese (Child Class)"
        //        }
        titleLabel.position = CGPoint(x: centerX, y: size.height * 0.85)
        titleLabel.zPosition = 15
        cookingContainer.addChild(titleLabel)

        potSprite = SKSpriteNode(imageNamed: "normalwater")
        let potScale = (size.height * 0.55) / potSprite.size.height
        potSprite.setScale(potScale)
        potSprite.position = CGPoint(x: centerX, y: centerY)
        potSprite.zPosition = 10
        potSprite.name = "potSprite"
        cookingContainer.addChild(potSprite)

        let stepLabel = SKLabelNode(fontNamed: "Menlo")
        stepLabel.fontSize = 16
        stepLabel.fontColor = SKColor(white: 0.9, alpha: 1)
        stepLabel.position = CGPoint(
            x: centerX, y: centerY - potSprite.size.height * potScale * 0.8)
        stepLabel.zPosition = 15
        stepLabel.name = "stepLabel"
        cookingContainer.addChild(stepLabel)

        if index == 0 {
            stepLabel.text = ""
            dialogBox.showDialog(
                name: "Robot",
                text:
                    "Let's cook Basic Pasta \u{2014} the parent recipe! This class has 4 steps. Tap the pot to start each one."
            )
        } else {
            stepLabel.text = "Inherited steps running..."
            dialogBox.showDialog(
                name: "Robot",
                text:
                    "Now Mac & Cheese \u{2014} it INHERITS from Basic Pasta! Watch: all 4 parent steps happen automatically. You only add what's new."
            )
            autoPlayCookingSteps()
        }
    }

    private func autoPlayCookingSteps() {
        autoPlaying = true

        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 1.5),
                SKAction.run { [weak self] in self?.advanceCookingStep() },
            ]))
        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 3.0),
                SKAction.run { [weak self] in self?.advanceCookingStep() },
            ]))
        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 4.5),
                SKAction.run { [weak self] in self?.advanceCookingStep() },
            ]))
        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 6.0),
                SKAction.run { [weak self] in self?.advanceCookingStep() },
            ]))
        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 7.5),
                SKAction.run { [weak self] in
                    self?.autoPlaying = false
                    self?.showCheeseStep()
                },
            ]))
    }

    private func showCheeseStep() {
        guard let container = cookingContainer else { return }
        let centerX = size.width * 0.30

        let cheese = SKSpriteNode(imageNamed: "cheese")
        let cheeseScale = (size.height * 0.15) / cheese.size.height
        cheese.setScale(cheeseScale)
        cheese.position = CGPoint(x: centerX + 180, y: size.height * 0.55)
        cheese.zPosition = 15
        cheese.name = "cheeseItem"
        container.addChild(cheese)

        cheese.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.scale(to: cheeseScale * 1.15, duration: 0.5),
                    SKAction.scale(to: cheeseScale, duration: 0.5),
                ])))

        let arrowLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        arrowLabel.text = "NEW!"
        arrowLabel.fontSize = 14
        arrowLabel.fontColor = SKColor(red: 1, green: 0.8, blue: 0.2, alpha: 1)
        arrowLabel.position = CGPoint(
            x: centerX + 180, y: size.height * 0.55 - cheese.size.height * cheeseScale * 0.7)
        arrowLabel.zPosition = 15
        arrowLabel.name = "cheeseLabel"
        container.addChild(arrowLabel)

        if let stepLabel = container.childNode(withName: "stepLabel") as? SKLabelNode {
            stepLabel.text = "Tap the cheese to add it!"
        }

        dialogBox.showDialog(
            name: "Robot",
            text:
                "All parent steps done automatically! Now tap the cheese \u{2014} that's the NEW method this child class adds."
        )
    }

    private func handleCookingTap() {
        guard !autoPlaying else { return }

        if currentRecipeIndex == 0 {
            if cookingStep == 0 {
                showBoilingPopup()
            } else if cookingStep == 1 || cookingStep == 2 {
                return
            } else {
                advanceCookingStep()
            }
        }
    }

    private func pastaDroppedInPot() {
        guard let pasta = rawPastaSprite else { return }
        isDraggingPasta = false
        print("🍝 [DEBUG] pastaDroppedInPot called, cookingStep=\(cookingStep)")

        // Animate pasta into pot
        pasta.removeAllActions()
        pasta.run(
            SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: potSprite.position, duration: 0.3),
                    SKAction.scale(to: 0.1, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.3),
                ]),
                SKAction.removeFromParent(),
            ]))
        rawPastaSprite = nil

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

    private func startTiltDetection() {
        isWaitingForTilt = true
        print(
            "🍝 [DEBUG] startTiltDetection called, deviceMotionAvailable=\(motionManager.isDeviceMotionAvailable)"
        )

        guard motionManager.isDeviceMotionAvailable else {
            print("🍝 [DEBUG] No device motion — using simulator fallback (2s)")
            run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 2.0),
                    SKAction.run { [weak self] in
                        self?.completeDrain()
                    },
                ]))
            return
        }

        var initialRoll: Double? = nil

        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run { [weak self] in
                    guard let self = self, self.isWaitingForTilt else { return }
                    print("🍝 [DEBUG] Starting device motion updates")
                    self.motionManager.deviceMotionUpdateInterval = 0.1
                    self.motionManager.startDeviceMotionUpdates(to: .main) {
                        [weak self] motion, _ in
                        guard let self = self, self.isWaitingForTilt, let motion = motion else {
                            return
                        }
                        let roll = motion.attitude.roll
                        let pitch = motion.attitude.pitch
                        print(
                            "🍝 [DEBUG] Roll=\(String(format: "%.2f", roll)) Pitch=\(String(format: "%.2f", pitch))"
                        )

                        if initialRoll == nil {
                            initialRoll = roll
                            print("🍝 [DEBUG] Initial roll: \(String(format: "%.2f", roll))")
                            return
                        }

                        let rollDelta = roll - (initialRoll ?? roll)
                        print("🍝 [DEBUG] Roll delta=\(String(format: "%.2f", rollDelta))")
                        if abs(rollDelta) > 0.5 {
                            print("🍝 [DEBUG] Tilt detected! calling completeDrain")
                            self.completeDrain()
                        }
                    }
                },
            ]))
    }

    private func completeDrain() {
        guard isWaitingForTilt else {
            print("🍝 [DEBUG] completeDrain called but isWaitingForTilt already false — skipping")
            return
        }
        isWaitingForTilt = false
        motionManager.stopDeviceMotionUpdates()
        print("🍝 [DEBUG] completeDrain running, cookingStep=\(cookingStep)")

        let strain = SKSpriteNode(imageNamed: "pastaStrain")
        let sScale = (size.height * 0.55) / strain.size.height
        strain.setScale(sScale)
        strain.position = potSprite.position
        strain.zPosition = 10
        strain.alpha = 0
        strain.name = "potSprite"
        cookingContainer.addChild(strain)

        potSprite.run(SKAction.fadeOut(withDuration: 0.3)) { [weak self] in
            self?.potSprite.removeFromParent()
            self?.potSprite = strain
        }
        strain.run(SKAction.fadeIn(withDuration: 0.3))

        if let stepLabel = cookingContainer.childNode(withName: "stepLabel") as? SKLabelNode {
            stepLabel.text = "drain() — Pasta strained!"
        }

        cookingStep = 3
        completedStepCount = 3
        if currentRecipeIndex == 0 {
            pastaRecipeSteps = ["boilWater()", "addPasta()", "drain()"]
        }
        updateCodeDisplay()

        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    let boiledPasta = SKSpriteNode(imageNamed: "rawpasta")
                    let bpScale = (self.size.height * 0.55) / boiledPasta.size.height
                    boiledPasta.setScale(bpScale)
                    boiledPasta.position = self.potSprite.position
                    boiledPasta.zPosition = 10
                    boiledPasta.alpha = 0
                    boiledPasta.name = "potSprite"
                    self.cookingContainer.addChild(boiledPasta)

                    self.potSprite.run(SKAction.fadeOut(withDuration: 0.3)) { [weak self] in
                        self?.potSprite.removeFromParent()
                        self?.potSprite = boiledPasta
                    }
                    boiledPasta.run(SKAction.fadeIn(withDuration: 0.3))

                    if let stepLabel = self.cookingContainer.childNode(withName: "stepLabel")
                        as? SKLabelNode
                    {
                        stepLabel.text = "serve() — Boiled pasta ready!"
                    }

                    self.dialogBox.showDialog(
                        name: "Robot",
                        text: "serve() — The pasta is cooked and ready! Basic Pasta is done."
                    )

                    self.cookingStep = 4
                    self.completedStepCount = 4
                    self.pastaRecipeSteps = ["boilWater()", "addPasta()", "drain()", "serve()"]
                    self.updateCodeDisplay()

                    self.run(
                        SKAction.sequence([
                            SKAction.wait(forDuration: 1.0),
                            SKAction.run { [weak self] in
                                self?.finishRound1()
                            },
                        ]))
                },
            ]))
    }

    private func handleCheeseTap() {
        guard currentRecipeIndex == 1, !autoPlaying else { return }

        cookingContainer.childNode(withName: "cheeseItem")?.removeFromParent()
        cookingContainer.childNode(withName: "cheeseLabel")?.removeFromParent()

        let macCheese = SKSpriteNode(imageNamed: "macchessepasta")
        let resultScale = (size.height * 0.35) / macCheese.size.height
        macCheese.setScale(resultScale)
        macCheese.position = potSprite.position
        macCheese.zPosition = 10
        macCheese.alpha = 0
        cookingContainer.addChild(macCheese)

        potSprite.run(SKAction.fadeOut(withDuration: 0.3))
        macCheese.run(SKAction.fadeIn(withDuration: 0.3))

        if let stepLabel = cookingContainer.childNode(withName: "stepLabel") as? SKLabelNode {
            stepLabel.text = "addCheese() \u{2014} Mac & Cheese ready!"
        }

        cookingStep = 5
        completedStepCount = 5
        pastaRecipeSteps = ["boilWater()", "addPasta()", "drain()", "serve()", "addCheese()"]
        updateCodeDisplay()

        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.run { [weak self] in
                    self?.finishCookingPhase()
                },
            ]))
    }

    private func advanceCookingStep() {
        let centerX = size.width * 0.30

        switch cookingStep {
        case 0:
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
                    ? "boilWater() \u{2014} Tap to add pasta" : "boilWater() (inherited)"
            }

        case 1:
            let rawPasta = SKSpriteNode(imageNamed: "rawpasta")
            let pScale = (size.height * 0.55) / rawPasta.size.height
            rawPasta.setScale(pScale)
            rawPasta.position = CGPoint(x: centerX + 250, y: size.height * 0.50)
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

            if let stepLabel = cookingContainer.childNode(withName: "stepLabel") as? SKLabelNode {
                stepLabel.text = "Drag the pasta into the pot!"
            }
            dialogBox.onDialogComplete = nil
            dialogBox.showDialog(
                name: "Robot",
                text: "addPasta() — Grab the raw pasta and drop it into the boiling water!"
            )
            return

        case 2:
            if let stepLabel = cookingContainer.childNode(withName: "stepLabel") as? SKLabelNode {
                stepLabel.text = "Tilt your device left to strain!"
            }
            dialogBox.onDialogComplete = nil
            dialogBox.showDialog(
                name: "Robot",
                text: "drain() — Tilt your iPad to the LEFT to strain the pasta!"
            )
            startTiltDetection()
            return

        case 3:
            let served = SKSpriteNode(imageNamed: "macchessepasta")
            let svScale = (size.height * 0.55) / served.size.height
            served.setScale(svScale)
            served.position = potSprite.position
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
    }

    private func finishRound1() {
        showConfetti()
        dialogBox.showDialog(
            name: "Robot",
            text:
                "Basic Pasta is done! We wrote 4 methods: boilWater, addPasta, drain, and serve. Now here's the power of INHERITANCE..."
        )
        dialogBox.onDialogComplete = { [weak self] in
            self?.dialogBox.showDialog(
                name: "Robot",
                text:
                    "Mac & Cheese is a CHILD of Basic Pasta. It gets all 4 steps for free \u{2014} and only needs to add addCheese(). Watch!"
            )
            self?.dialogBox.onDialogComplete = { [weak self] in
                self?.startCookingRound(index: 1)
            }
        }
    }

    private func finishCookingPhase() {
        showConfetti()
        dialogBox.showDialog(
            name: "Robot",
            text:
                "That's INHERITANCE! Mac & Cheese reused all of Basic Pasta's steps without rewriting a single line. It only added what was new."
        )
        dialogBox.onDialogComplete = { [weak self] in
            self?.dialogBox.showDialog(
                name: "Robot",
                text:
                    "In code, we write: class MacAndCheese: BasicPasta \u{2014} the colon means it inherits everything. Next up: POLYMORPHISM!"
            )
            self?.dialogBox.onDialogComplete = { [weak self] in
                self?.cookingContainer?.removeFromParent()
                self?.startPolymorphismPhase()
            }
        }
    }

    private func startPolymorphismPhase() {
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

    private func prepareCurrentItem() {
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

    private func startAbstractionPhase() {
        currentPhase = .abstraction
        absorbedCount = 0
        stepButtons.removeAll()
        updateCodeDisplay()

        let centerX = size.width * 0.62
        let centerY = size.height * 0.55

        packLunchButton = SKShapeNode(rectOf: CGSize(width: 280, height: 80), cornerRadius: 20)
        packLunchButton.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.6, alpha: 0.9)
        packLunchButton.strokeColor = .white
        packLunchButton.lineWidth = 3
        packLunchButton.position = CGPoint(x: centerX, y: centerY)
        packLunchButton.zPosition = 10
        packLunchButton.name = "packLunchBtn"
        gameLayer.addChild(packLunchButton)

        let bigLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        bigLabel.text = "packLunch()"
        bigLabel.fontSize = 24
        bigLabel.fontColor = .white
        bigLabel.verticalAlignmentMode = .center
        packLunchButton.addChild(bigLabel)

        let positions: [CGPoint] = [
            CGPoint(x: centerX - 220, y: centerY + 150),
            CGPoint(x: centerX + 200, y: centerY + 130),
            CGPoint(x: centerX - 180, y: centerY - 140),
            CGPoint(x: centerX + 230, y: centerY - 120),
            CGPoint(x: centerX - 50, y: centerY + 180),
            CGPoint(x: centerX + 80, y: centerY - 170),
        ]

        for i in 0..<stepMethods.count {
            let btn = SKShapeNode(rectOf: CGSize(width: 160, height: 40), cornerRadius: 8)
            btn.fillColor = SKColor(red: 0.5, green: 0.3, blue: 0.3, alpha: 0.9)
            btn.strokeColor = .white
            btn.lineWidth = 1
            btn.position = positions[i]
            btn.zPosition = 15
            btn.name = "stepBtn_\(i)"
            gameLayer.addChild(btn)

            let label = SKLabelNode(fontNamed: "Menlo")
            label.text = stepMethods[i]
            label.fontSize = 13
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
    }

    private func absorbStep() {
        absorbedCount += 1
        updateCodeDisplay()

        if absorbedCount >= stepMethods.count {
            packLunchButton.fillColor = SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1)

            run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.5),
                    SKAction.run { [weak self] in
                        self?.showConfetti()
                        self?.currentPhase = .done
                        self?.updateCodeDisplay()
                        self?.dialogBox.showDialog(
                            name: "Robot",
                            text:
                                "All the steps are now hidden inside packLunch()! One simple call does everything — that's ABSTRACTION! Tori's lunch is ready!"
                        )
                        self?.dialogBox.onDialogComplete = { [weak self] in
                            self?.dialogBox.showDialog(
                                name: "Tori",
                                text: "My lunch is all packed! Time for school!"
                            )
                            self?.dialogBox.onDialogComplete = {
                                self?.navigateTo(.thankYou)
                            }
                        }
                    },
                ]))
        }
    }

    private func clearPhaseNodes() {
        for child in gameLayer.children {
            if child == codePanel || child == dialogBox || child == roboExplain { continue }
            if child.zPosition >= 5 && child.zPosition <= 20 {
                child.removeFromParent()
            }
        }
        ingredientSlots.removeAll()
        prepItems.removeAll()
        stepButtons.removeAll()
    }

    private func showConfetti() {
        let colors: [SKColor] = [
            .systemRed, .systemYellow, .systemCyan,
            .systemGreen, .systemOrange, .systemPurple, .systemPink,
        ]
        for i in 0..<30 {
            let confetti = SKSpriteNode(
                color: colors[i % colors.count],
                size: CGSize(
                    width: CGFloat.random(in: 6...12),
                    height: CGFloat.random(in: 6...14)))
            confetti.position = CGPoint(
                x: CGFloat.random(in: size.width * 0.05...size.width * 0.95),
                y: size.height + 30
            )
            confetti.zPosition = 200
            confetti.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
            gameLayer.addChild(confetti)

            let delay = Double.random(in: 0...0.8)
            let dur = Double.random(in: 1.5...2.5)
            let fall = SKAction.moveBy(
                x: CGFloat.random(in: -80...80), y: -size.height * 1.1, duration: dur)
            fall.timingMode = .easeIn
            let spin = SKAction.rotate(byAngle: CGFloat.random(in: -6...6), duration: dur)
            let fade = SKAction.fadeOut(withDuration: dur * 0.3)
            let seq = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([fall, spin]),
                fade,
                SKAction.removeFromParent(),
            ])
            confetti.run(seq)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isGamePaused { return }

        if popupOverlay == nil && boilingOverlay == nil {
            let panelLocation = touch.location(in: codePanel)
            if abs(panelLocation.x) < codePanelWidth / 2
                && abs(panelLocation.y) < codePanelHeight / 2
            {
                isScrollingCodePanel = true
                lastScrollY = location.y
                return
            }
        }

        switch currentPhase {
        case .intro:
            dialogBox.handleTap()

        case .encapsulation:

            if let overlay = popupOverlay {

                let localPoint = overlay.convert(location, from: self)
                if let closeBtn = overlay.childNode(withName: "popupClose") {
                    if closeBtn.contains(localPoint) {
                        closePopup(success: false)
                        return
                    }
                }

                if popupState == .painting {
                    isPainting = true
                    lastPaintPoint = nil
                    paintAt(location)
                }
                return
            }

            let tappedNodes = nodes(at: location)
            for node in tappedNodes {
                if let name = node.name, name.starts(with: "platform_") {
                    let item = name.replacingOccurrences(of: "platform_", with: "")
                    if !ingredientsAdded.contains(item)
                        && ["bread", "cheese", "tomato", "spinach"].contains(item)
                    {
                        showTracingPopup(for: item)
                        return
                    }
                }
            }

            if dialogBox.contains(location) { dialogBox.handleTap() }

        case .inheritance:
            if popupState == .boiling, let overlay = boilingOverlay {
                let localPoint = overlay.convert(location, from: self)

                if let closeBtn = overlay.childNode(withName: "popupClose") {
                    if closeBtn.contains(localPoint) {
                        closeBoilingPopup()
                        return
                    }
                }

                let gaugeWidth: CGFloat = 280
                let gaugeX: CGFloat = 180
                let gaugeY: CGFloat = 0
                let hitAreaHeight: CGFloat = 80

                if abs(localPoint.y - gaugeY) < hitAreaHeight / 2 {
                    isDraggingGauge = true
                    let startX = gaugeX - gaugeWidth / 2
                    let progress = max(0, min(1, (localPoint.x - startX) / gaugeWidth))
                    updateBoilingProgress(progress)
                    return
                }
            }

            let tappedNodes = nodes(at: location)
            for node in tappedNodes {
                if node.name == "rawPastaSprite" {
                    isDraggingPasta = true
                    return
                }
                if node.name == "potSprite" || node.parent?.name == "potSprite" {
                    handleCookingTap()
                    return
                }
                if node.name == "cheeseItem" {
                    handleCheeseTap()
                    return
                }
            }
            dialogBox.handleTap()

        case .polymorphism:
            let tappedNodes = nodes(at: location)
            for node in tappedNodes {
                if node.name == "prepareButton" || node.parent?.name == "prepareButton" {
                    prepareCurrentItem()
                    return
                }
            }
            dialogBox.handleTap()

        case .abstraction:
            let tappedNodes = nodes(at: location)
            for node in tappedNodes {
                if let name = node.name, name.starts(with: "stepBtn_") {
                    draggedStepButton = node
                    return
                }
                if let pName = node.parent?.name, pName.starts(with: "stepBtn_") {
                    draggedStepButton = node.parent
                    return
                }
            }
            dialogBox.handleTap()

        case .done:
            dialogBox.handleTap()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isScrollingCodePanel {
            let delta = location.y - lastScrollY
            codeContentNode.position.y -= delta
            let maxScroll = max(0, codeLabel.frame.height - codePanelHeight + 60)
            codeContentNode.position.y = max(0, min(maxScroll, codeContentNode.position.y))
            lastScrollY = location.y
            return
        }

        if currentPhase == .encapsulation, popupOverlay != nil, popupState == .painting, isPainting
        {
            paintAt(location)
            return
        }

        if popupState == .boiling, isDraggingGauge, let overlay = boilingOverlay {
            let localPoint = overlay.convert(location, from: self)
            let gaugeWidth: CGFloat = 280
            let gaugeX: CGFloat = 180
            let startX = gaugeX - gaugeWidth / 2

            let progress = max(0, min(1, (localPoint.x - startX) / gaugeWidth))
            updateBoilingProgress(progress)
            return
        }

        if isDraggingPasta, let pasta = rawPastaSprite {
            pasta.removeAllActions()
            pasta.position = location
            return
        }

        if let btn = draggedStepButton {
            btn.position = location
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPainting = false
        isDraggingGauge = false

        if isDraggingPasta, let pasta = rawPastaSprite {
            isDraggingPasta = false
            // Check if pasta is near the pot
            let distance = hypot(
                pasta.position.x - potSprite.position.x,
                pasta.position.y - potSprite.position.y)
            if distance < potSprite.size.width * potSprite.xScale * 0.5 {
                pastaDroppedInPot()
            } else {
                // Snap back
                let centerX = size.width * 0.30
                let pScale = (size.height * 0.55) / pasta.size.height
                pasta.run(
                    SKAction.move(
                        to: CGPoint(x: centerX + 250, y: size.height * 0.50), duration: 0.3))
                pasta.run(
                    SKAction.repeatForever(
                        SKAction.sequence([
                            SKAction.scale(to: pScale * 1.08, duration: 0.5),
                            SKAction.scale(to: pScale, duration: 0.5),
                        ])))
            }
            return
        }
        if isScrollingCodePanel {
            isScrollingCodePanel = false
            return
        }

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let btn = draggedStepButton {
            if packLunchButton.frame.contains(location) {
                btn.run(
                    SKAction.sequence([
                        SKAction.group([
                            SKAction.move(to: packLunchButton.position, duration: 0.2),
                            SKAction.scale(to: 0.1, duration: 0.2),
                            SKAction.fadeOut(withDuration: 0.2),
                        ]),
                        SKAction.removeFromParent(),
                    ]))
                absorbStep()
            }
            draggedStepButton = nil
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

        draggedStepButton = nil
        isScrollingCodePanel = false
        isDraggingGauge = false
    }

    override func handleTouch(at location: CGPoint, touch: UITouch) {
    }
}

struct KitchenScene_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(scene: KitchenScene(size: CGSize(width: 1920, height: 1080)))
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDisplayName("Full Kitchen Scene")
    }
}

// Preview that jumps straight to the boiling popup
struct BoilingPopup_Previews: PreviewProvider {
    static var previews: some View {
        let scene = KitchenScene(size: CGSize(width: 1920, height: 1080))
        scene.previewBoilingPopup = true
        return SpriteView(scene: scene)
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDisplayName("Boiling Popup Only")
    }
}

// Preview that jumps straight to pasta cooking
struct PastaCooking_Previews: PreviewProvider {
    static var previews: some View {
        let scene = KitchenScene(size: CGSize(width: 1920, height: 1080))
        scene.previewPastaCooking = true
        return SpriteView(scene: scene)
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDisplayName("Pasta Cooking")
    }
}
