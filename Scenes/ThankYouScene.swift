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

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
        setupDialogBox()
        showDialog()
    }

    private func setupScene() {
        backgroundColor = SKColor(red: 0.835, green: 0.773, blue: 0.647, alpha: 1.0)

        thankYouImage = SKSpriteNode(imageNamed: "thankyou")
        thankYouImage.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        thankYouImage.zPosition = 1
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
