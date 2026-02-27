//
//  ThankYouScene.swift
//  Toris Exam
//
//  Created by kartikay on 08/02/26.
//

import SpriteKit
import SwiftUI

class ThankYouScene: BaseScene {

    private var thankYouImage: SKSpriteNode!
    private var dialogBox: DialogBox!

    override func sceneDidSetup() {
        setupScene()
        setupDialogBox()
        showDialog()
    }

    private func setupScene() {
        let bgBlurNode = SKEffectNode()
        bgBlurNode.shouldRasterize = true
        bgBlurNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 8])
        bgBlurNode.zPosition = 0

        let roomBg = SKSpriteNode(imageNamed: "Room")
        roomBg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let roomScale = max(size.width / roomBg.size.width, size.height / roomBg.size.height)
        roomBg.setScale(roomScale)
        bgBlurNode.addChild(roomBg)
        gameLayer.addChild(bgBlurNode)

        let blurOverlay = SKShapeNode(
            rectOf: CGSize(width: size.width * 2, height: size.height * 2))
        blurOverlay.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        blurOverlay.strokeColor = .clear
        blurOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        blurOverlay.zPosition = 1
        gameLayer.addChild(blurOverlay)

        thankYouImage = SKSpriteNode(imageNamed: "thankyou")
        thankYouImage.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        thankYouImage.zPosition = 5
        let imageScale = (size.height * 1.5) / thankYouImage.size.height
        thankYouImage.setScale(imageScale)
        gameLayer.addChild(thankYouImage)
    }

    private func setupDialogBox() {
        dialogBox = DialogBox()
        dialogBox.position = CGPoint(x: size.width / 2, y: 120)
        dialogBox.zPosition = 100
        gameLayer.addChild(dialogBox)

        dialogBox.onDialogComplete = { [weak self] in
            self?.transitionToNextScene()
        }
    }

    private func showDialog() {
        dialogBox.onDialogComplete = { [weak self] in
            self?.transitionToNextScene()
        }
        dialogBox.showDialog(
            name: "Tori",
            text: "Thank you Robo! Please help me learn OOPs while I get my clothes ready!")
    }

    private func transitionToNextScene() {
        navigateTo(.oopIntro)
    }

    override func handleTouch(at location: CGPoint, touch: UITouch) {
        dialogBox.handleTap()
    }
}

struct ThankYouScene_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(scene: ThankYouScene(size: CGSize(width: 1920, height: 1080)))
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
