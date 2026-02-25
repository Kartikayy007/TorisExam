//
//  BusScene.swift
//  TorisExam
//
//  Created by kartikay on 26/02/26.
//

import SpriteKit
import SwiftUI

class BusScene: BaseScene {
    private var busBg1: SKSpriteNode!
    private var busBg2: SKSpriteNode!
    private var busSceneImg: SKSpriteNode!

    override func sceneDidSetup() {
        backgroundColor = SKColor(red: 0.53, green: 0.81, blue: 0.92, alpha: 1.0)

        let moveSpeed: CGFloat = 200.0

        let heightScale = size.height

        
        busBg1 = SKSpriteNode(imageNamed: "busbg")
        busBg1.anchorPoint = CGPoint(x: 0, y: 0.5)
        let bgScale = heightScale / busBg1.size.height
        busBg1.setScale(bgScale)
        busBg1.position = CGPoint(x: 0, y: size.height / 2)
        busBg1.zPosition = 1
        gameLayer.addChild(busBg1)

        
        busBg2 = SKSpriteNode(imageNamed: "busbg")
        busBg2.anchorPoint = CGPoint(x: 0, y: 0.5)
        busBg2.setScale(bgScale)
        
        let bgScaledWidth = busBg1.size.width * bgScale
        busBg2.position = CGPoint(x: bgScaledWidth - 2, y: size.height / 2)
        busBg2.zPosition = 1
        gameLayer.addChild(busBg2)

        
        busSceneImg = SKSpriteNode(imageNamed: "busscene")
        busSceneImg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let busScaleX = size.width / busSceneImg.size.width
        let busScaleY = size.height / busSceneImg.size.height
        busSceneImg.setScale(max(busScaleX, busScaleY))
        busSceneImg.zPosition = 5
        gameLayer.addChild(busSceneImg)

        
        let moveAction = SKAction.moveBy(
            x: -bgScaledWidth, y: 0, duration: TimeInterval(bgScaledWidth / moveSpeed))
        let resetAction = SKAction.moveBy(x: bgScaledWidth, y: 0, duration: 0)
        let loopAction = SKAction.repeatForever(SKAction.sequence([moveAction, resetAction]))

        busBg1.run(loopAction)
        busBg2.run(loopAction)

        
        let moveUp = SKAction.moveBy(x: 0, y: 4, duration: 0.08)
        let moveDown = SKAction.moveBy(x: 0, y: -4, duration: 0.08)
        let vibrate = SKAction.repeatForever(SKAction.sequence([moveUp, moveDown]))
        busSceneImg.run(vibrate)

    }
}

struct BusScene_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(scene: BusScene(size: CGSize(width: 1920, height: 1080)))
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
