//
//  KitchenScene.swift
//  Toris Exam
//
//  Created by kartikay on 13/02/26.
//

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

    
    private enum PopupState { case none, painting }
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

        
        debugDrawAreas()

        setupCodePanel()
        setupDialogBox()
        updateCodeDisplay()

        
        let savedIngredients = CheckpointManager.shared.savedKitchenIngredients()
        if !savedIngredients.isEmpty {
            
            startEncapsulationPhase()
            restoreSavedIngredients(savedIngredients)
        } else {
            showIntro()
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
        
        codePanel.position = CGPoint(x: size.width * 0.68, y: size.height * 0.55)
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

    private func debugDrawAreas() {
        
        let p = SKShapeNode(rectOf: CGSize(width: size.width, height: 10), cornerRadius: 0)
        p.strokeColor = .red
        p.lineWidth = 5
        p.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        p.zPosition = 200
        gameLayer.addChild(p)

        
        let s = SKShapeNode(rectOf: CGSize(width: 150, height: 150), cornerRadius: 0)
        s.strokeColor = .green
        s.lineWidth = 5
        s.position = CGPoint(x: size.width * 0.20, y: size.height * 0.43)
        s.zPosition = 200
        gameLayer.addChild(s)

        let label = SKLabelNode(text: "BREAD")
        label.fontSize = 20
        label.position = CGPoint(x: 0, y: 80)
        s.addChild(label)

        
        let startX = size.width * 0.35
        let tableY = size.height * 0.43
        for i in 0..<3 {
            let zone = SKShapeNode(rectOf: CGSize(width: 100, height: 100))
            zone.strokeColor = .yellow
            zone.lineWidth = 4
            zone.position = CGPoint(x: startX + CGFloat(i) * 120, y: tableY)
            zone.zPosition = 200
            gameLayer.addChild(zone)

            let lbl = SKLabelNode(text: "ING_\(i)")
            lbl.fontSize = 15
            lbl.position = CGPoint(x: 0, y: 60)
            zone.addChild(lbl)
        }
    }

    

    private func updateCodeDisplay() {
        var code = ""
        switch currentPhase {
        case .intro:
            code = "
            code += "
            code += "
            code += "
            code += "

        case .encapsulation:
            code = "class Sandwich {\n"
            code += "  

            for item in ingredientsAdded {
                code += "  private var \(item): Ingredient 🔒\n"
            }

            if ingredientsAdded.count < 3 {
                code += "  
            }

            code += "  func eat() {\n"
            code += "    
            code += "  }\n"
            code += "}"

            if sandwichDone {
                code += "\n\nlet lunch = Sandwich()\n"
                code += "
            }

        case .inheritance:
            if currentRecipeIndex == 0 {
                code = "class BasicPasta {\n"
                code += "  func boilWater() { }\n"
                code += "  func addPasta()  { }\n"
                code += "  func drain()     { }\n"
                code += "  func serve()     { }\n"
                code += "}\n"
            } else if currentRecipeIndex == 1 {
                code = "class MacAndCheese: BasicPasta {\n"
                code += "  
                code += "  
                code += "  
                code += "  
                code += "  func addCheese() { } 
                code += "}\n"
            } else {
                code = "class SpicyPasta: MacAndCheese {\n"
                code += "  
                code += "  
                code += "  func addVeggies() { } 
                code += "  func addSpice()   { } 
                code += "}\n"
            }

        case .polymorphism:
            code = "
            code += "
            if currentPrepItem >= 1 {
                code += "sandwich.prepare()\n"
                code += "  
            }
            if currentPrepItem >= 2 {
                code += "apple.prepare()\n"
                code += "  
            }
            if currentPrepItem >= 3 {
                code += "juice.prepare()\n"
                code += "  
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
                code += "
                code += "packLunch() 
            }

        case .done:
            code = "
            code += "
            code += "
            code += "
            code += "
            code += "
        }
        codeLabel.text = code
        codeContentNode.position.y = 0
    }

    

    private func showIntro() {
        roboExplain.run(SKAction.fadeIn(withDuration: 0.3))
        dialogBox.showDialog(
            name: "Robot",
            text: "Welcome to the Kitchen! Let's pack Tori's lunch and learn the 4 PILLARS of OOP!"
        )
        dialogBox.onDialogComplete = { [weak self] in
            self?.dialogBox.showDialog(
                name: "Robot",
                text: "First up — let's make a sandwich! This will teach us ENCAPSULATION!"
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

        
        let centerX = size.width * 0.20
        let centerY = size.height * 0.43
        sandwichZone = CGPoint(x: centerX, y: centerY)

        
        let plateLabel = SKLabelNode(fontNamed: "Menlo")
        plateLabel.text = "Sandwich Builder"
        plateLabel.fontSize = 14
        plateLabel.fontColor = .darkGray
        plateLabel.position = CGPoint(x: centerX, y: centerY - 120)
        plateLabel.zPosition = 10
        plateLabel.name = "plateLabel"
        gameLayer.addChild(plateLabel)

        dialogBox.showDialog(
            name: "Robot",
            text:
                "Encapsulation! Each ingredient is PRIVATE. Tap one to trace its outline and reveal it!"
        )

        
        let bread = SKSpriteNode(imageNamed: "bread")
        bread.setScale(0.35)
        bread.position = CGPoint(x: centerX, y: centerY - 30)
        bread.zPosition = 15
        bread.name = "platform_bread"
        bread.color = .gray
        bread.colorBlendFactor = 1.0
        bread.alpha = 0.4
        gameLayer.addChild(bread)
        platformIngredients["bread"] = bread
        bread.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.6, duration: 1.0),
                    SKAction.fadeAlpha(to: 0.4, duration: 1.0),
                ])))

        
        let ingredients = ["cheese", "tomato", "spinach"]
        let positions = [
            CGPoint(x: centerX - 120, y: centerY + 50),
            CGPoint(x: centerX, y: centerY + 70),
            CGPoint(x: centerX + 120, y: centerY + 50),
        ]

        for i in 0..<ingredients.count {
            let item = ingredients[i]
            let sprite = SKSpriteNode(imageNamed: item)
            sprite.setScale(0.3)
            sprite.position = positions[i]
            sprite.zPosition = 16 + CGFloat(i)
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

    
    private func restoreSavedIngredients(_ saved: [String]) {
        for item in saved {
            guard !ingredientsAdded.contains(item) else { continue }
            ingredientsAdded.append(item)

            
            if let platformSprite = platformIngredients[item] {
                platformSprite.removeAllActions()
                platformSprite.alpha = 1.0
                platformSprite.colorBlendFactor = 0.0

                let check = SKLabelNode(text: "✅")
                check.fontSize = 30
                check.position = CGPoint(x: 0, y: -30)
                check.verticalAlignmentMode = .center
                check.zPosition = 5
                platformSprite.addChild(check)
            }
        }
        updateCodeDisplay()

        
        if ingredientsAdded.count >= 4 {
            run(SKAction.wait(forDuration: 0.5)) { [weak self] in
                self?.completeSandwich()
            }
        }
    }

    

    private func showTracingPopup(for item: String) {
        guard !ingredientsAdded.contains(item) else { return }
        currentPopupItem = item
        popupState = .painting
        paintedCells.removeAll()
        paintThreshold = (item == "spinach") ? 180 : 100
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

    private func addIngredientToSandwich(_ item: String) {
        if ingredientsAdded.contains(item) { return }
        ingredientsAdded.append(item)

        
        CheckpointManager.shared.saveKitchenIngredients(ingredientsAdded)

        
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

            
            let check = SKLabelNode(text: "✅")
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
                            "Great! The ingredients are now ENCAPSULATED inside the Sandwich. You can't touch them individually anymore!"
                    )
                    self.dialogBox.onDialogComplete = { [weak self] in
                        self?.startInheritancePhase()
                    }
                },
            ]))
    }

    

    private func startInheritancePhase() {
        currentPhase = .inheritance
        currentRecipeIndex = 0
        startRecipe(index: 0)
    }

    private func startRecipe(index: Int) {
        currentRecipeIndex = index
        completedStepCount = 0
        updateCodeDisplay()

        
        recipeContainer?.removeFromParent()
        recipeContainer = SKNode()
        recipeContainer.position = CGPoint(x: size.width * 0.35, y: size.height * 0.5)
        gameLayer.addChild(recipeContainer)

        let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.fontSize = 28
        titleLabel.fontColor = .darkGray
        titleLabel.position = CGPoint(x: 0, y: 220)
        recipeContainer.addChild(titleLabel)

        var steps: [String] = []
        var methodNames: [String] = []

        if index == 0 {
            titleLabel.text = "Round 1: Basic Pasta (Parent)"
            steps = ["💧", "🍝", "🚰", "🍲"]
            methodNames = ["boilWater()", "addPasta()", "drain()", "serve()"]
            dialogBox.showDialog(
                name: "Robot",
                text: "Let's make Basic Pasta! Tap each step in order: Boil, Add, Drain, Serve.")
        } else if index == 1 {
            titleLabel.text = "Round 2: Mac & Cheese (Child)"
            steps = ["💧", "🍝", "🚰", "🍲", "🧀"]
            methodNames = ["boilWater()", "addPasta()", "drain()", "serve()", "addCheese()"]
            dialogBox.showDialog(
                name: "Robot",
                text:
                    "Mac & Cheese INHERITS from Basic Pasta! Watch the base steps happen automatically..."
            )
        } else {
            titleLabel.text = "Round 3: Spicy Primavera (Grandchild)"
            steps = ["💧", "🍝", "🚰", "🍲", "🧀", "🥦", "🌶️"]
            methodNames = [
                "boilWater()", "addPasta()", "drain()", "serve()", "addCheese()", "addVeggies()",
                "addSpice()",
            ]
            dialogBox.showDialog(
                name: "Robot",
                text: "Spicy Pasta inherits everything from Mac & Cheese! Watch the magic!")
        }

        self.pastaRecipeSteps = methodNames

        
        for i in 0..<steps.count {
            let btn = SKShapeNode(rectOf: CGSize(width: 80, height: 80), cornerRadius: 10)
            btn.position = CGPoint(x: -200 + CGFloat(i) * 100, y: 100)
            btn.fillColor = .lightGray
            btn.strokeColor = .white
            btn.lineWidth = 2
            btn.name = "recipeStep_\(i)"
            recipeContainer.addChild(btn)

            let lbl = SKLabelNode(text: steps[i])
            lbl.fontSize = 40
            lbl.verticalAlignmentMode = .center
            lbl.name = "icon_\(i)"
            btn.addChild(lbl)

            let method = SKLabelNode(fontNamed: "Menlo")
            method.text = methodNames[i]
            method.fontSize = 12
            method.fontColor = .black
            method.position = CGPoint(x: 0, y: -55)
            btn.addChild(method)

            
            if (index == 1 && i < 4) || (index == 2 && i < 5) {
                btn.alpha = 0.5
                let done = SKLabelNode(text: "✅")
                done.fontSize = 30
                done.position = CGPoint(x: 25, y: 25)
                done.zPosition = 5
                done.alpha = 0
                done.name = "check_\(i)"
                btn.addChild(done)
            }
        }

        if index > 0 {
            autoPlayInheritedSteps(recipeIndex: index)
        }
    }

    private func autoPlayInheritedSteps(recipeIndex: Int) {
        autoPlaying = true
        let inheritedCount = (recipeIndex == 1) ? 4 : 5

        for i in 0..<inheritedCount {
            run(
                SKAction.sequence([
                    SKAction.wait(forDuration: Double(i) * 0.8 + 1.0),
                    SKAction.run { [weak self] in
                        self?.markStepDone(i, isAuto: true)
                    },
                ]))
        }

        run(
            SKAction.sequence([
                SKAction.wait(forDuration: Double(inheritedCount) * 0.8 + 1.2),
                SKAction.run { [weak self] in
                    self?.autoPlaying = false
                    self?.dialogBox.showDialog(
                        name: "Robot",
                        text: "Inherited steps done! Now YOU add the NEW ingredients!")
                },
            ]))
    }

    private func handleRecipeTap(nodeName: String) {
        guard !autoPlaying else { return }
        guard let index = Int(nodeName.replacingOccurrences(of: "recipeStep_", with: "")) else {
            return
        }

        
        if index == completedStepCount {
            markStepDone(index, isAuto: false)
        } else if index > completedStepCount {
            
            if let btn = recipeContainer.childNode(withName: "recipeStep_\(index)") {
                btn.run(
                    SKAction.sequence([
                        SKAction.moveBy(x: -5, y: 0, duration: 0.05),
                        SKAction.moveBy(x: 10, y: 0, duration: 0.05),
                        SKAction.moveBy(x: -5, y: 0, duration: 0.05),
                    ]))
            }
        }
    }

    private func markStepDone(_ index: Int, isAuto: Bool) {
        guard let btn = recipeContainer.childNode(withName: "recipeStep_\(index)") as? SKShapeNode
        else { return }

        completedStepCount += 1

        
        btn.fillColor = .green
        btn.run(SKAction.scale(to: 1.2, duration: 0.1))
        btn.run(SKAction.scale(to: 1.0, duration: 0.1))

        
        if let check = btn.childNode(withName: "check_\(index)") {
            check.run(SKAction.fadeIn(withDuration: 0.2))
        }

        
        if completedStepCount >= pastaRecipeSteps.count {
            finishRecipe()
        }
    }

    private func finishRecipe() {
        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run { [weak self] in
                    self?.showConfetti()
                    if self?.currentRecipeIndex == 0 {
                        self?.dialogBox.showDialog(
                            name: "Robot",
                            text: "Basic Pasta done! Now let's try Mac & Cheese (Child Class).")
                        self?.dialogBox.onDialogComplete = {
                            self?.startRecipe(index: 1)
                        }
                    } else if self?.currentRecipeIndex == 1 {
                        self?.dialogBox.showDialog(
                            name: "Robot",
                            text: "Mac & Cheese done! Now Spicy Primavera (Grandchild Class)!")
                        self?.dialogBox.onDialogComplete = {
                            self?.startRecipe(index: 2)
                        }
                    } else {
                        self?.dialogBox.showDialog(
                            name: "Robot",
                            text:
                                "You mastered INHERITANCE! You reused code instead of rewriting it! Next: POLYMORPHISM."
                        )
                        self?.dialogBox.onDialogComplete = {
                            self?.recipeContainer.removeFromParent()
                            self?.startPolymorphismPhase()
                        }
                    }
                },
            ]))
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
                "POLYMORPHISM: same method, different behavior! Tap .prepare() — watch how each item prepares differently!"
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
                                "Same .prepare() method — sandwich got cut, apple got washed, juice got shaken! That's POLYMORPHISM! Last one: ABSTRACTION!"
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
                "ABSTRACTION: hide complexity behind one simple call! Drag each step INTO packLunch() to combine them!"
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
                                "All steps hidden inside packLunch()! One call does everything — that's ABSTRACTION! Tori's lunch is packed! 🎉"
                        )
                        self?.dialogBox.onDialogComplete = { [weak self] in
                            self?.dialogBox.showDialog(
                                name: "Tori",
                                text: "My lunch is ready! Time for school! 🏫"
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

        
        if popupOverlay == nil {
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
            let tappedNodes = nodes(at: location)
            for node in tappedNodes {
                if let name = node.name, name.starts(with: "recipeStep_") {
                    handleRecipeTap(nodeName: name)
                    return
                }
                if let pName = node.parent?.name, pName.starts(with: "recipeStep_") {
                    handleRecipeTap(nodeName: pName)
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

        
        if let btn = draggedStepButton {
            btn.position = location
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPainting = false
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
    }

    override func handleTouch(at location: CGPoint, touch: UITouch) {
    }
}

struct KitchenScene_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(scene: KitchenScene(size: CGSize(width: 1920, height: 1080)))
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
