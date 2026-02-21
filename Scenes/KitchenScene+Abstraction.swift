//
//  KitchenScene+Abstraction.swift
//  TorisExam
//
//  Created by Kartikay on 19/02/26.
//

import SpriteKit

extension KitchenScene {

    func startAbstractionPhase() {
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

            let dict = NSMutableDictionary()
            dict["originalPos"] = NSValue(cgPoint: positions[i])
            btn.userData = dict

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

    func absorbStep() {
        absorbedCount += 1
        updateCodeDisplay()

        if absorbedCount >= stepMethods.count {
            autoPlaying = true
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
                                self?.autoPlaying = false
                                self?.navigateTo(.thankYou)
                            }
                        }
                    },
                ]))
        }
    }
}
