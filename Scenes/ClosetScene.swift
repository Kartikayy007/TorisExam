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
    private var dialogBox: DialogBox!

    private var tori: SKSpriteNode!
    private var pantsOnTori: SKSpriteNode?

    private var pantHitboxes: [SKShapeNode] = []
    private var toriDropZone: SKShapeNode!

    
    private var draggedPant: SKSpriteNode?
    private var draggedPantIndex: Int?
    private var dragStartPos: CGPoint?

    private var selectedPantIndex: Int? = nil

    private let pantAssets = ["smallPant", "largepant", "mediumPant"]
    private let toriWearingAssets = [
        "toriWearingPantSmall", "ToriWearingPantLarge", "ToriWearingPantmed",
    ]
    private let pantLabels = ["Small", "Large", "Medium"]
    private let pantScaleMultipliers: [CGFloat] = [0.45, 0.90, 0.40]

    private var currentStep = 0

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
        setupDialogBox()
        showIntro()
    }

    private func setupScene() {
        backgroundColor = SKColor(red: 0.15, green: 0.12, blue: 0.2, alpha: 1.0)

        tori = SKSpriteNode(imageNamed: "ToriStanding")
        let toriScale = (size.height * 0.6) / tori.size.height
        tori.setScale(toriScale)
        
        
        tori.position = CGPoint(x: size.width * 0.35, y: size.height * 0.52)
        tori.zPosition = 2
        gameLayer.addChild(tori)

        let dropW = tori.size.width * toriScale * 0.8
        let dropH = tori.size.height * toriScale * 0.35
        toriDropZone = SKShapeNode(rectOf: CGSize(width: dropW, height: dropH), cornerRadius: 8)
        toriDropZone.fillColor = SKColor.green.withAlphaComponent(0.15)
        toriDropZone.strokeColor = SKColor.green.withAlphaComponent(0.6)
        toriDropZone.lineWidth = 2

        
        
        let visualOffset = -tori.size.width * toriScale * 0.35

        toriDropZone.position = CGPoint(
            x: tori.position.x + visualOffset,
            y: tori.position.y - tori.size.height * toriScale * 0.2
        )
        toriDropZone.zPosition = 3
        toriDropZone.name = "dropZone"
        gameLayer.addChild(toriDropZone)

        let closet = SKSpriteNode(imageNamed: "Closet")
        let closetScale = (size.height * 0.7) / closet.size.height
        closet.setScale(closetScale)
        closet.position = CGPoint(x: size.width * 0.40, y: size.height * 0.55)
        closet.zPosition = 1
        gameLayer.addChild(closet)

        
        let closetCenterX = size.width * 0.39
        let scaledClosetH = closet.size.height * closetScale
        let scaledClosetW = closet.size.width * closetScale
        let pantSpacing = scaledClosetW * 0.15
        let pantY = closet.position.y - scaledClosetH * 0.18
        let btnSize = CGSize(width: scaledClosetW * 0.14, height: scaledClosetH * 0.5)

        let debugColors: [SKColor] = [.cyan, .yellow, .magenta]

        for i in 0..<3 {
            let btn = SKShapeNode(rectOf: btnSize, cornerRadius: 8)
            
            
            
            
            btn.position = CGPoint(
                x: closetCenterX + CGFloat(i - 1) * pantSpacing,
                y: pantY
            )
            btn.zPosition = 10
            btn.name = "pant_\(i)"
            gameLayer.addChild(btn)
            pantHitboxes.append(btn)

            
            let label = SKLabelNode(text: pantLabels[i])
            label.fontSize = 14
            label.fontName = "AvenirNext-Bold"
            label.fontColor = debugColors[i]
            label.verticalAlignmentMode = .center
            btn.addChild(label)
        }

        
        let panelWidth = size.width * 0.35
        let panelHeight = size.height * 0.75

        codePanel = SKShapeNode(
            rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 16)
        codePanel.fillColor = SKColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 0.95)
        codePanel.strokeColor = SKColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 0.8)
        codePanel.lineWidth = 2
        codePanel.position = CGPoint(x: size.width * 0.78, y: size.height * 0.55)
        codePanel.zPosition = 5
        gameLayer.addChild(codePanel)

        codeLabel = SKLabelNode()
        codeLabel.fontSize = min(28, panelWidth * 0.06)
        codeLabel.fontName = "Menlo-Regular"
        codeLabel.fontColor = SKColor(red: 0.7, green: 0.9, blue: 0.7, alpha: 1.0)
        codeLabel.numberOfLines = 0
        codeLabel.preferredMaxLayoutWidth = panelWidth - 40
        codeLabel.horizontalAlignmentMode = .left
        codeLabel.verticalAlignmentMode = .top
        codeLabel.position = CGPoint(x: -panelWidth / 2 + 20, y: panelHeight / 2 - 30)
        codePanel.addChild(codeLabel)

        updateCodeDisplay()
    }

    private func setupDialogBox() {
        dialogBox = DialogBox()
        dialogBox.position = CGPoint(x: size.width / 2, y: 80)
        dialogBox.zPosition = 100
        gameLayer.addChild(dialogBox)

        dialogBox.onDialogComplete = { [weak self] in
            self?.advanceStep()
        }
    }

    private func updateCodeDisplay() {
        var code = """
            class Clothing {
                var color: String
                var size: String
            }

            class Pants: Clothing {
                var fit: String
            }
            """

        if let idx = selectedPantIndex {
            code += "\n\nlet myPants = Pants()"
            code += "\nmyPants.fit = \"\(pantLabels[idx])\""
        }

        codeLabel.text = code
    }

    private func showIntro() {
        dialogBox.showDialog(
            name: "Tori",
            text:
                "This is my closet! Drag a pair of pants onto me to try them on. Pants INHERIT from Clothing!"
        )
    }

    private func advanceStep() {
        currentStep += 1
        switch currentStep {
        case 1:
            dialogBox.showDialog(
                name: "Robot",
                text: "Drag one of the pants from the closet onto Tori!"
            )
        default:
            dialogBox.hideDialog()
        }
    }

    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isGamePaused { return }

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
        }

        
        dialogBox.handleTap()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let pant = draggedPant else { return }
        let location = touch.location(in: self)
        pant.position = location

        
        if toriDropZone.frame.contains(location) {
            toriDropZone.fillColor = SKColor.green.withAlphaComponent(0.35)
            toriDropZone.strokeColor = SKColor.green
            toriDropZone.lineWidth = 3
        } else {
            toriDropZone.fillColor = SKColor.green.withAlphaComponent(0.15)
            toriDropZone.strokeColor = SKColor.green.withAlphaComponent(0.6)
            toriDropZone.lineWidth = 2
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let pant = draggedPant, let idx = draggedPantIndex else {
            return
        }
        let location = touch.location(in: self)

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

        
        toriDropZone.fillColor = SKColor.green.withAlphaComponent(0.15)
        toriDropZone.strokeColor = SKColor.green.withAlphaComponent(0.6)
        toriDropZone.lineWidth = 2

        draggedPant = nil
        draggedPantIndex = nil
        dragStartPos = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggedPant?.removeFromParent()
        draggedPant = nil
        draggedPantIndex = nil
        dragStartPos = nil
    }

    private func equipPant(index: Int) {
        
        pantsOnTori?.removeFromParent()
        pantsOnTori = nil

        selectedPantIndex = index

        
        tori.texture = SKTexture(imageNamed: toriWearingAssets[index])

        updateCodeDisplay()

        dialogBox.showDialog(
            name: "Robot",
            text:
                "Tori is wearing \(pantLabels[index]) pants! Pants inherits color & size from Clothing, plus adds its own 'fit' property."
        )
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
