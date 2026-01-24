//
//  RobotIntroScene.swift
//  Donut
//
//  Created by kartikay on 24/01/26.
//

import SpriteKit

class RobotIntroScene: SKScene {

    private var robotDone: SKSpriteNode!

    override func didMove(to view: SKView) {
        setupScene()
    }

    private func setupScene() {
        backgroundColor = .black

        robotDone = SKSpriteNode(imageNamed: "RobotDone")
        robotDone.position = CGPoint(x: size.width / 2, y: size.height / 2)
        robotDone.zPosition = 0
        let scaleX = size.width / robotDone.size.width
        let scaleY = size.height / robotDone.size.height
        robotDone.setScale(max(scaleX, scaleY))
        robotDone.alpha = 0
        addChild(robotDone)

        robotDone.run(SKAction.fadeIn(withDuration: 1.0))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
}
