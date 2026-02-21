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

    var currentPhase: Phase = .intro
    var currentStep = 0
    var previewBoilingPopup = false
    var previewPastaCooking = false
    var previewInheritancePhase = false
    var previewMacAndCheese = false
    var previewPastaLayout = false
    var showDebugOverlay = false

    var dialogBox: DialogBox!
    var roboExplain: SKSpriteNode!
    var codePanel: SKShapeNode!
    var codeLabel: SKLabelNode!
    var codeCropNode: SKCropNode!
    var codeContentNode: SKNode!
    var codePanelWidth: CGFloat = 0
    var codePanelHeight: CGFloat = 0

    var isScrollingCodePanel = false
    var lastScrollY: CGFloat = 0

    var breadBottom: SKSpriteNode!
    var breadTop: SKSpriteNode!
    var ingredientSlots: [SKSpriteNode] = []
    var sandwichIngredients: [String] = []
    var sandwichZone: CGPoint = .zero
    var sandwichDone = false
    var placedIngredientCount = 0
    var platformIngredients: [String: SKSpriteNode] = [:]
    var ingredientsAdded: [String] = []
    var ingredientButtons: [SKSpriteNode] = []
    var solidIngredients: [SKSpriteNode] = []

    enum PopupState { case none, painting, boiling }
    var popupState: PopupState = .none

    var popupOverlay: SKShapeNode?
    var currentPopupItem: String?
    var colorCropNode: SKCropNode?
    var paintMaskNode: SKNode?
    var paintStrokeCount: Int = 0
    var paintThreshold: Int = 180
    var isPainting: Bool = false
    var lastPaintPoint: CGPoint? = nil
    var paintedCells: Set<String> = []
    var progressBar: SKShapeNode?
    var progressFill: SKShapeNode?

    var gaugeKnob: SKShapeNode?
    var gaugeTrack: SKShapeNode?
    var boilingProgress: CGFloat = 0.0
    var normalWaterSprite: SKSpriteNode?
    var boilingWaterSprite: SKSpriteNode?
    var boilingOverlay: SKShapeNode?
    var isDraggingGauge = false
    var stepProgressBar: SKNode?
    var stepProgressIcons: [SKShapeNode] = []
    var rawPastaSprite: SKSpriteNode?
    var isDraggingPasta = false
    lazy var motionManager = CMMotionManager()
    var isWaitingForTilt = false
    var cookingContainer: SKNode!
    var potSprite: SKSpriteNode!
    var cookingStep = 0
    var inheritanceDone = false
    var pastaRecipeSteps: [String] = []
    var currentRecipeIndex = 0
    var completedStepCount = 0
    var recipeContainer: SKNode!
    var autoPlaying = false
    var isDraggingCheese = false

    var prepareButton: SKShapeNode!
    var prepItems: [SKLabelNode] = []
    var currentPrepItem = 0

    var stepButtons: [SKNode] = []
    var packLunchButton: SKShapeNode!
    var draggedStepButton: SKNode?
    var absorbedCount = 0
    let stepMethods = [
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

        if !previewPastaLayout {
            showIntro()
        }

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

        if previewInheritancePhase {
            dialogBox.isHidden = true
            roboExplain.isHidden = true
            currentPhase = .inheritance
            startInheritancePhase()
        }

        if previewMacAndCheese {
            dialogBox.isHidden = true
            roboExplain.isHidden = true
            currentPhase = .inheritance
            currentRecipeIndex = 1
            cookingContainer = SKNode()
            cookingContainer.name = "cookingContainer"
            gameLayer.addChild(cookingContainer)
            potSprite = SKSpriteNode(imageNamed: "normalwater")
            potSprite.name = "potSprite"
            potSprite.position = CGPoint(x: size.width * 0.30, y: size.height * 0.50)
            cookingContainer.addChild(potSprite)
            startCookingRound(index: 1)
        }

        if previewPastaLayout {
            dialogBox.isHidden = true
            roboExplain.isHidden = true
            dialogBox.onDialogComplete = nil
            currentPhase = .inheritance
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

    func updateCodeDisplay() {
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

    func clearPhaseNodes() {
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

    func showConfetti() {
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

        if isGamePaused || autoPlaying { return }

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
                    if ingredientsAdded.count < 4,
                        !ingredientsAdded.contains(item),
                        ["bread", "cheese", "tomato", "spinach"].contains(item)
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
                if node.name == "inheritButton" || node.parent?.name == "inheritButton" {
                    handleInheritTap()
                    return
                }
                if node.name == "drainButton" || node.parent?.name == "drainButton" {
                    handleDrainButtonTap()
                    return
                }
                if node.name == "potSprite" || node.parent?.name == "potSprite" {
                    handleCookingTap()
                    return
                }
                if node.name == "cheeseItem" {
                    isDraggingCheese = true
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

        if isDraggingCheese, let cheese = cookingContainer?.childNode(withName: "cheeseItem") {
            cheese.removeAllActions()
            cheese.position = cookingContainer.convert(location, from: self)
            return
        }

        if let btn = draggedStepButton {
            btn.position = location
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPainting = false
        isDraggingGauge = false

        if isDraggingCheese {
            isDraggingCheese = false
            if let cheese = cookingContainer?.childNode(withName: "cheeseItem") {
                let cheesePos = cookingContainer.convert(cheese.position, to: self)
                let distance = hypot(
                    cheesePos.x - (potSprite.position.x - 40),
                    cheesePos.y - potSprite.position.y)
                if distance < potSprite.size.width * potSprite.xScale * 0.7 {
                    cheeseDroppedOnPasta()
                } else {
                    // Snap back
                    let centerX = size.width * 0.40
                    let pastaX = centerX - 120
                    cheese.run(
                        SKAction.move(
                            to: CGPoint(x: pastaX + 260, y: size.height * 0.50),
                            duration: 0.3))
                }
            }
            return
        }

        if isDraggingPasta, let pasta = rawPastaSprite {
            isDraggingPasta = false
            let distance = hypot(
                pasta.position.x - (potSprite.position.x - 40),
                pasta.position.y - potSprite.position.y)
            if distance < potSprite.size.width * potSprite.xScale * 0.7 {  // Increased hitbox drop radius slightly
                pastaDroppedInPot()
            } else {
                let centerX = size.width * 0.40
                let unscaledHeight = pasta.size.height / pasta.yScale
                let pScale = (size.height * 0.2) / unscaledHeight
                pasta.run(
                    SKAction.move(
                        to: CGPoint(x: centerX + 120, y: size.height * 0.50), duration: 0.3))
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
                btn.name = "absorbed"
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
            } else {
                if let dict = btn.userData,
                    let origX = dict["origX"] as? CGFloat,
                    let origY = dict["origY"] as? CGFloat
                {
                    btn.run(SKAction.move(to: CGPoint(x: origX, y: origY), duration: 0.3))
                }
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

// MARK: - Previews

struct KitchenScene_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(scene: KitchenScene(size: CGSize(width: 1920, height: 1080)))
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDisplayName("Full Kitchen Scene")
    }
}

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

struct InheritancePhase_Previews: PreviewProvider {
    static var previews: some View {
        let scene = KitchenScene(size: CGSize(width: 1920, height: 1080))
        scene.previewInheritancePhase = true
        return SpriteView(scene: scene)
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDisplayName("Inheritance Phase")
    }
}

struct MacAndCheese_Previews: PreviewProvider {
    static var previews: some View {
        let scene = KitchenScene(size: CGSize(width: 1920, height: 1080))
        scene.previewMacAndCheese = true
        return SpriteView(scene: scene)
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDisplayName("Mac & Cheese Round")
    }
}

struct PastaLayout_Previews: PreviewProvider {
    static var previews: some View {
        let scene = KitchenScene(size: CGSize(width: 1920, height: 1080))
        scene.previewPastaLayout = true
        return SpriteView(scene: scene)
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDisplayName("🍝 Pasta Layout Tool")
    }
}
