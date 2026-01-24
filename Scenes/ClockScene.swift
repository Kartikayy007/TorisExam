//
//  ClockScene.swift
//  Donut
//
//  Created by kartikay on 24/01/26.
//

import SpriteKit
import SwiftUI

class ClockScene: SKScene {

    private var clockWall: SKSpriteNode!
    private var clock: SKSpriteNode!
    private var dialogBox: DialogBox!

    override func didMove(to view: SKView) {
        setupScene()
        setupDialogBox()
        startAlarm()
    }

    private func setupScene() {
        backgroundColor = .black

        
        clockWall = SKSpriteNode(imageNamed: "ClockWall")
        clockWall.position = CGPoint(x: size.width / 2, y: size.height / 2)
        clockWall.zPosition = 0
        let scaleX = size.width / clockWall.size.width
        let scaleY = size.height / clockWall.size.height
        clockWall.setScale(max(scaleX, scaleY))
        addChild(clockWall)

        
        clock = SKSpriteNode(imageNamed: "Clock")
        clock.position = CGPoint(x: size.width / 2, y: size.height / 2)
        clock.zPosition = 1
        let clockScale = (size.width * 0.65) / clock.size.width
        clock.setScale(clockScale)
        addChild(clock)
    }

    private func setupDialogBox() {
        dialogBox = DialogBox()
        dialogBox.position = CGPoint(x: size.width / 2, y: 120)
        dialogBox.zPosition = 100
        addChild(dialogBox)

        dialogBox.onDialogComplete = { [weak self] in
            self?.returnToBedroom()
        }
    }

    private func startAlarm() {
        
        dialogBox.showDialog(name: "", text: "*RING RING RING!* 🔔")

        
        let rotateLeft = SKAction.rotate(byAngle: 0.15, duration: 0.05)
        let rotateRight = SKAction.rotate(byAngle: -0.3, duration: 0.1)
        let rotateBack = SKAction.rotate(byAngle: 0.15, duration: 0.05)
        let shake = SKAction.sequence([rotateLeft, rotateRight, rotateBack])

        let zoomIn = SKAction.scale(by: 1.1, duration: 0.1)
        let zoomOut = SKAction.scale(by: 0.909, duration: 0.1)
        let pulse = SKAction.sequence([zoomIn, zoomOut])

        let combined = SKAction.group([shake, pulse])
        clock.run(SKAction.repeatForever(combined))
    }

    private func returnToBedroom() {
        clock.removeAllActions()
        let bedroomScene = BedroomScene(size: self.size, isPostAlarm: true)
        bedroomScene.scaleMode = .aspectFill
        self.view?.presentScene(bedroomScene, transition: .fade(withDuration: 0.5))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dialogBox.handleTap()
    }
}

struct ClockScene_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(
            scene: {
                let scene = ClockScene(size: CGSize(width: 1920, height: 1080))
                scene.scaleMode = .aspectFill
                return scene
            }()
        )
        .previewInterfaceOrientation(.landscapeLeft)
        .ignoresSafeArea()
    }
}
