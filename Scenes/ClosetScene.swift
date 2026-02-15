//
//  ClosetScene.swift
//  Toris Exam
//
//  Created by kartikay on 08/02/26
//

import SpriteKit
import SwiftUI

class ClosetScene: BaseScene {

    private var codePanel: SKShapeNode!
    private var codeLabel: SKLabelNode!
    private var codeCropNode: SKCropNode!
    private var codeContentNode: SKNode!
    private var dialogBox: DialogBox!
    private var roboExplain: SKSpriteNode!
    private var isScrollingCodePanel = false
    private var lastScrollY: CGFloat = 0
    private var codePanelWidth: CGFloat = 0
    private var codePanelHeight: CGFloat = 0

    private var tori: SKSpriteNode!
    private var pantsOnTori: SKSpriteNode?

    private var pantHitboxes: [SKShapeNode] = []
    private var shirtHitboxes: [SKShapeNode] = []
    private var toriDropZone: SKShapeNode!

    private var draggedPant: SKSpriteNode?
    private var draggedPantIndex: Int?
    private var draggedShirt: SKSpriteNode?
    private var draggedShirtIndex: Int?
    private var dragStartPos: CGPoint?

    private var selectedPantIndex: Int? = nil
    private var selectedShirtIndex: Int? = nil

    private let pantAssets = ["mediumPant", "largepant", "smallPant"]
    private let toriWearingAssets = [
        "toriWearingPantSmall", "ToriWearingPantLarge", "ToriWearingPantmed",
    ]
    private let pantLabels = ["Medium", "Large", "Small"]
    private let pantScaleMultipliers: [CGFloat] = [0.45, 0.90, 0.40]

    private let shirtAssets = ["redtshirtsmall", "bluetshirtmed", "Yellowtshirtlarge"]
    private let shirtLabels = ["Small", "Medium", "Large"]

    private var currentStep = 0
    private var introComplete = false
    private var outfitComplete = false

    override func sceneDidSetup() {
        setupScene()
        setupDialogBox()
        showIntro()
    }

    private func setupScene() {
        backgroundColor = SKColor(red: 0.835, green: 0.773, blue: 0.647, alpha: 1.0)

        tori = SKSpriteNode(imageNamed: "ToriStanding")
        let toriScale = (size.height * 0.6) / tori.size.height
        tori.setScale(toriScale)

        tori.position = CGPoint(x: size.width * 0.45, y: size.height * 0.52)
        tori.zPosition = 2
        gameLayer.addChild(tori)

        let dropW = tori.size.width * toriScale * 0.4
        let dropH = tori.size.height * toriScale * 1.5
        toriDropZone = SKShapeNode(rectOf: CGSize(width: dropW, height: dropH), cornerRadius: 8)
        toriDropZone.fillColor = .clear
        toriDropZone.strokeColor = .clear

        let visualOffset = -tori.size.width * toriScale * 0.35

        toriDropZone.position = CGPoint(
            x: tori.position.x + visualOffset * 2.0,
            y: tori.position.y - tori.size.height * toriScale * 0.1
        )
        toriDropZone.zPosition = 3
        toriDropZone.name = "dropZone"
        gameLayer.addChild(toriDropZone)

        let closet = SKSpriteNode(imageNamed: "Closet")
        let closetScale = (size.height * 0.8) / closet.size.height
        closet.setScale(closetScale)
        closet.position = CGPoint(x: size.width * 0.40, y: size.height * 0.55)
        closet.zPosition = 1
        gameLayer.addChild(closet)

        let closetCenterX = size.width * 0.39
        let scaledClosetH = closet.size.height * closetScale
        let scaledClosetW = closet.size.width * closetScale
        let pantSpacing = scaledClosetW * 0.15
        let pantY = closet.position.y - scaledClosetH * 0.18
        let btnSize = CGSize(width: scaledClosetW * 0.24, height: scaledClosetH * 0.5)

        for i in 0..<3 {
            let btn = SKShapeNode(rectOf: btnSize, cornerRadius: 8)
            btn.fillColor = .clear
            btn.strokeColor = .clear

            btn.position = CGPoint(
                x: closetCenterX + CGFloat(i - 1) * pantSpacing,
                y: pantY
            )
            btn.zPosition = 10
            btn.name = "pant_\(i)"
            gameLayer.addChild(btn)
            pantHitboxes.append(btn)
        }

        let shirtY = closet.position.y + scaledClosetH * 0.28
        let shirtBtnSize = CGSize(width: scaledClosetW * 0.15, height: scaledClosetH * 0.3)

        for i in 0..<3 {
            let btn = SKShapeNode(rectOf: shirtBtnSize, cornerRadius: 8)
            btn.fillColor = .clear
            btn.strokeColor = .clear
            btn.position = CGPoint(
                x: closetCenterX + CGFloat(i - 1) * pantSpacing,
                y: shirtY
            )
            btn.zPosition = 10
            btn.name = "shirt_\(i)"
            gameLayer.addChild(btn)
            shirtHitboxes.append(btn)
        }

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
        codeLabel.fontSize = min(22, panelWidth * 0.05)
        codeLabel.fontName = "Menlo-Regular"
        codeLabel.fontColor = SKColor(red: 0.7, green: 0.9, blue: 0.7, alpha: 1.0)
        codeLabel.numberOfLines = 0
        codeLabel.preferredMaxLayoutWidth = panelWidth - 50
        codeLabel.horizontalAlignmentMode = .left
        codeLabel.verticalAlignmentMode = .top
        codeLabel.position = CGPoint(x: -panelWidth / 2 + 20, y: panelHeight / 2 - 30)
        codeContentNode.addChild(codeLabel)

        updateCodeDisplay()
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

        dialogBox.onDialogComplete = { [weak self] in
            self?.advanceStep()
        }
    }

    private func updateCodeDisplay() {
        var code = ""

        code += "class Clothing {\n"
        code += "  var color: String\n"
        code += "  var size: String\n"
        code += "\n"
        code += "  func tryOn() {\n"
        code += "    print(\"Trying on!\")\n"
        code += "  }\n"
        code += "}"

        if let idx = selectedPantIndex {
            let pantColors = ["Blue", "Blue", "Light Blue"]
            code += "\n\nlet myPants = Clothing()\n"
            code += "myPants.color = \"\(pantColors[idx])\"\n"
            code += "myPants.size = \"\(pantLabels[idx])\"\n"
            code += "myPants.tryOn()"
        }

        if let idx = selectedShirtIndex {
            let shirtColors = ["Red", "Blue", "Yellow"]
            code += "\n\nlet myShirt = Clothing()\n"
            code += "myShirt.color = \"\(shirtColors[idx])\"\n"
            code += "myShirt.size = \"\(shirtLabels[idx])\"\n"
            code += "myShirt.tryOn()"
        }

        if selectedPantIndex == 1 && selectedShirtIndex == 2 {
            code += "\n\n// Tori is ready!"
        }

        codeLabel.text = code
        codeContentNode.position.y = 0
    }

    private func showIntro() {
        roboExplain.run(SKAction.fadeIn(withDuration: 0.3))
        dialogBox.showDialog(
            name: "Robot",
            text:
                "Before we start, let me teach you something! A CLASS is like a blueprint — it describes what something IS."
        )
    }

    private func advanceStep() {
        currentStep += 1
        switch currentStep {
        case 1:
            dialogBox.showDialog(
                name: "Robot",
                text:
                    "For example, 'Clothing' is a class. It's the idea of clothing — not any specific shirt or pants, just the concept!"
            )
        case 2:
            dialogBox.showDialog(
                name: "Robot",
                text:
                    "A class has PROPERTIES — these are the details. Clothing has 'color' and 'size'. Properties describe what an object HAS."
            )
        case 3:
            dialogBox.showDialog(
                name: "Robot",
                text:
                    "An OBJECT is a real thing made from a class. 'Clothing' is the blueprint, but Tori's blue pants? That's an object!"
            )
        case 4:
            dialogBox.showDialog(
                name: "Robot",
                text:
                    "Classes also have METHODS — these are actions! Our Clothing class has a tryOn() method. Methods describe what an object CAN DO."
            )
        case 5:
            dialogBox.showDialog(
                name: "Robot",
                text:
                    "So to recap: CLASS = blueprint, OBJECT = real thing, PROPERTIES = what it has, METHODS = what it can do!"
            )
        case 6:
            introComplete = true
            roboExplain.run(SKAction.fadeOut(withDuration: 0.3))
            glowHitboxes(pantHitboxes)
            dialogBox.showDialog(
                name: "Robot",
                text:
                    "Let's try it! Drag a pair of PANTS from the closet onto Tori. Find the right size!"
            )
        default:
            dialogBox.hideDialog()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isGamePaused { return }

        let panelLocation = touch.location(in: codePanel)
        if abs(panelLocation.x) < codePanelWidth / 2 && abs(panelLocation.y) < codePanelHeight / 2 {
            isScrollingCodePanel = true
            lastScrollY = location.y
            return
        }

        guard introComplete && !outfitComplete else {
            dialogBox.handleTap()
            return
        }

        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if let name = node.name, name.starts(with: "pant_"),
                let idx = Int(String(name.last!))
            {
                let pant = SKSpriteNode(imageNamed: pantAssets[idx])
                let pantScale = (size.height * 0.25) / pant.size.height
                pant.setScale(pantScale)
                pant.position = location
                pant.zPosition = 50
                pant.alpha = 0.85
                pant.name = "dragging"
                addChild(pant)

                draggedPant = pant
                draggedPantIndex = idx
                dragStartPos = location
                return
            }

            if let name = node.name, name.starts(with: "shirt_"),
                let idx = Int(String(name.last!))
            {

                guard selectedPantIndex == 1 else {
                    dialogBox.showDialog(
                        name: "Robot",
                        text: "First, find the right PANTS for Tori! Try dragging a pair onto her."
                    )
                    return
                }

                let shirt = SKSpriteNode(imageNamed: shirtAssets[idx])
                let shirtScale = (size.height * 0.20) / shirt.size.height
                shirt.setScale(shirtScale)
                shirt.position = location
                shirt.zPosition = 50
                shirt.alpha = 0.85
                shirt.name = "draggingShirt"
                addChild(shirt)

                draggedShirt = shirt
                draggedShirtIndex = idx
                dragStartPos = location
                return
            }
        }

        dialogBox.handleTap()
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

        if let pant = draggedPant {
            pant.position = location
        }
        if let shirt = draggedShirt {
            shirt.position = location
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isScrollingCodePanel {
            isScrollingCodePanel = false
            return
        }

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let pant = draggedPant, let idx = draggedPantIndex {
            if toriDropZone.frame.contains(location) {
                pant.removeFromParent()
                equipPant(index: idx)
            } else {
                pant.run(
                    SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.2),
                        SKAction.removeFromParent(),
                    ]))
            }
            draggedPant = nil
            draggedPantIndex = nil
            dragStartPos = nil
            return
        }

        if let shirt = draggedShirt, let idx = draggedShirtIndex {
            if toriDropZone.frame.contains(location) {
                shirt.removeFromParent()
                equipShirt(index: idx)
            } else {
                shirt.run(
                    SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.2),
                        SKAction.removeFromParent(),
                    ]))
            }
            draggedShirt = nil
            draggedShirtIndex = nil
            dragStartPos = nil
            return
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggedPant?.removeFromParent()
        draggedPant = nil
        draggedPantIndex = nil
        draggedShirt?.removeFromParent()
        draggedShirt = nil
        draggedShirtIndex = nil
        dragStartPos = nil
    }

    private func equipPant(index: Int) {

        pantsOnTori?.removeFromParent()
        pantsOnTori = nil

        selectedPantIndex = index

        tori.texture = SKTexture(imageNamed: toriWearingAssets[index])

        updateCodeDisplay()

        if index == 1 {

            showConfetti()
            glowHitboxes(shirtHitboxes)
            dialogBox.showDialog(
                name: "Robot",
                text: "The Large pants fit perfectly! Now drag a SHIRT onto Tori!"
            )
        } else {
            dialogBox.showDialog(
                name: "Tori",
                text: "These \(pantLabels[index]) pants don't fit right... Try another size!"
            )
        }
    }

    private func glowHitboxes(_ hitboxes: [SKShapeNode]) {
        for box in hitboxes {
            let glowContainer = SKEffectNode()
            glowContainer.shouldRasterize = true
            glowContainer.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 15])
            glowContainer.position = .zero
            glowContainer.zPosition = 1
            glowContainer.alpha = 0

            let innerGlow = SKShapeNode(rectOf: box.frame.size, cornerRadius: 12)
            innerGlow.fillColor = SKColor.white
            innerGlow.strokeColor = .clear
            glowContainer.addChild(innerGlow)

            box.addChild(glowContainer)

            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: 0.5),
                SKAction.fadeAlpha(to: 0.2, duration: 0.5),
            ])
            glowContainer.run(
                SKAction.sequence([
                    SKAction.repeat(pulse, count: 3),
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.removeFromParent(),
                ]))
        }
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
                x: CGFloat.random(in: -80...80),
                y: -size.height * 1.1,
                duration: dur)
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

    private func equipShirt(index: Int) {
        switch index {
        case 0:
            dialogBox.showDialog(
                name: "Tori",
                text: "This red shirt is too small for me!"
            )
        case 1:
            dialogBox.showDialog(
                name: "Tori",
                text: "This blue shirt is too short for me!"
            )
        case 2:
            if selectedPantIndex == 1 {
                selectedShirtIndex = index
                outfitComplete = true
                tori.texture = SKTexture(imageNamed: "toriClothsReady")
                updateCodeDisplay()
                showConfetti()
                dialogBox.showDialog(
                    name: "Robot",
                    text:
                        "Perfect fit! See how we created OBJECTS from the Clothing CLASS, set their PROPERTIES, and called the tryOn() METHOD?"
                )
                dialogBox.onDialogComplete = { [weak self] in
                    self?.showPackLunchDialog()
                }
            } else {
                dialogBox.showDialog(
                    name: "Tori",
                    text: "I need to put on the right pants first!"
                )
            }
        default:
            break
        }
    }

    private func showPackLunchDialog() {
        dialogBox.showDialog(
            name: "Tori",
            text: "I'm dressed! Now let's pack my lunch for school!"
        )
        dialogBox.onDialogComplete = { [weak self] in
            self?.goToNextScene()
        }
    }

    private func goToNextScene() {
        navigateTo(.kitchen)
    }

    override func handleTouch(at location: CGPoint, touch: UITouch) {

    }
}

struct ClosetScene_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(scene: ClosetScene(size: CGSize(width: 1920, height: 1080)))
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
