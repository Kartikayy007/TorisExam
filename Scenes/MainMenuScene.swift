//
//  MainMenuViewScene.swift
//  TorisExam
//
//  Created by kartikay on 24/02/26.
//

import SpriteKit
import SwiftUI

class MainMenuScene: BaseScene {

    override func sceneDidSetup() {
        backgroundColor = .black

        let roomBg = SKSpriteNode(imageNamed: "Room")
        let scale = max(size.width / roomBg.size.width, size.height / roomBg.size.height)
        roomBg.setScale(scale)
        roomBg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        roomBg.zPosition = 0
        gameLayer.addChild(roomBg)

        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor(white: 0, alpha: 0.3)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 1
        gameLayer.addChild(overlay)
    }
}

struct MainMenuScene_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(scene: MainMenuScene(size: CGSize(width: 1024, height: 768)))
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
