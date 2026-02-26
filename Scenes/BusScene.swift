//
//  BusScene.swift
//  TorisExam
//
//  Created by kartikay on 26/02/26.
//

import SpriteKit
import SwiftUI

class BusScene: BaseScene {
    private var busSceneImg: SKSpriteNode!

    override func sceneDidSetup() {
        backgroundColor = SKColor(red: 0.53, green: 0.81, blue: 0.92, alpha: 1.0)

        let moveSpeed: CGFloat = 400.0

        let heightScale = size.height

        let bgTexture = SKTexture(imageNamed: "busbg")
        let bgTextureHeight = max(1.0, bgTexture.size().height)
        let bgScale = heightScale / bgTextureHeight
        let bgScaledWidth = bgTexture.size().width * bgScale
        let spacing = bgScaledWidth - 1

        let moveAction = SKAction.moveBy(
            x: -spacing, y: 0, duration: TimeInterval(spacing / moveSpeed))
        let resetAction = SKAction.moveBy(x: spacing, y: 0, duration: 0)
        let loopAction = SKAction.repeatForever(SKAction.sequence([moveAction, resetAction]))

        for i in 0..<3 {
            let busBg = SKSpriteNode(texture: bgTexture)
            busBg.anchorPoint = CGPoint(x: 0, y: 0.5)
            busBg.setScale(bgScale)
            busBg.position = CGPoint(x: CGFloat(i) * spacing, y: size.height / 2)
            busBg.zPosition = 1
            gameLayer.addChild(busBg)
            busBg.run(loopAction)
        }

        busSceneImg = SKSpriteNode(imageNamed: "busscene")
        busSceneImg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let busScaleX = size.width / busSceneImg.size.width
        let busScaleY = size.height / busSceneImg.size.height
        busSceneImg.setScale(min(busScaleX, busScaleY))
        busSceneImg.zPosition = 5
        gameLayer.addChild(busSceneImg)

        let moveUp = SKAction.moveBy(x: 0, y: 4, duration: 0.08)
        let moveDown = SKAction.moveBy(x: 0, y: -4, duration: 0.08)
        let vibrate = SKAction.repeatForever(SKAction.sequence([moveUp, moveDown]))
        busSceneImg.run(vibrate)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            NotificationCenter.default.post(name: Notification.Name("StoryCompleted"), object: nil)
        }
    }
}

struct BusScene_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(scene: BusScene(size: CGSize(width: 1920, height: 1080)))
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
