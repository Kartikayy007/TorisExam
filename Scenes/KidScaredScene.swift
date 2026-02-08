//
//  KidScaredScene.swift
//  Tori's Exam
//
//  Created by kartikay on 25/01/26.
//

import SpriteKit
import SwiftUI

class KidScaredScene: BaseScene {

    private var boy: SKSpriteNode!
    private var dialogBox: DialogBox!

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
        setupDialogBox()
        showDialog()
    }

    private func setupScene() {
        backgroundColor = .black

        boy = SKSpriteNode(imageNamed: "Sitting")
        boy.position = CGPoint(x: size.width / 2, y: size.height / 2)
        boy.zPosition = 0
        let scaleX = size.width / boy.size.width
        let scaleY = size.height / boy.size.height
        boy.setScale(max(scaleX, scaleY))
        gameLayer.addChild(boy)

        addScribbles()
    }

    private func addScribbles() {
        let centerX = size.width / 2
        let centerY = size.height / 2

        let headPos = CGPoint(x: centerX, y: size.height * 0.9)
        createScribble(at: headPos, radius: 45)

        for i in 0..<12 {
            let angle = CGFloat(i) * (CGFloat.pi * 2 / 12)
            let offset = CGFloat.random(in: -0.5...0.5)
            let finalAngle = angle + offset
            let distance = CGFloat.random(in: 250...500)

            let rX = centerX + cos(finalAngle) * distance
            let rY = centerY + sin(finalAngle) * distance
            let rSize = CGFloat.random(in: 20...50)
            createScribble(at: CGPoint(x: rX, y: rY), radius: rSize)
        }
    }

    private func createScribble(at position: CGPoint, radius: CGFloat) {
        let scribble = SKShapeNode()
        scribble.strokeColor = .white
        scribble.lineWidth = 2
        scribble.position = position
        scribble.zPosition = 10
        gameLayer.addChild(scribble)

        let path1 = createJaggedPath(radius: radius, jitter: 10)
        let path2 = createJaggedPath(radius: radius + 5, jitter: 15)
        let path3 = createJaggedPath(radius: radius - 2, jitter: 8)

        let frames = [path1, path2, path3]
        var frameIndex = 0

        let animateAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run {
                    scribble.path = frames[frameIndex]
                    frameIndex = (frameIndex + 1) % frames.count
                },
                SKAction.wait(forDuration: Double.random(in: 0.08...0.15)),
            ]))

        scribble.run(animateAction)
    }

    private func createJaggedPath(radius: CGFloat, jitter: CGFloat) -> CGPath {
        let path = UIBezierPath()
        let center = CGPoint.zero
        let points = 20
        for i in 0...points {
            let angle = (CGFloat(i) / CGFloat(points)) * .pi * 2
            let loopJitter = CGFloat.random(in: -jitter...jitter)
            let r = radius + loopJitter
            let x = center.x + cos(angle) * r
            let y = center.y + sin(angle) * r
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        return path.cgPath
    }

    private func setupDialogBox() {
        dialogBox = DialogBox()
        dialogBox.position = CGPoint(x: size.width / 2, y: 120)
        dialogBox.zPosition = 100
        gameLayer.addChild(dialogBox)

        dialogBox.onDialogComplete = { [weak self] in
            self?.transitionToRobotIdea()
        }
    }

    private func showDialog() {
        dialogBox.showDialog(name: "", text: "What am I going to do!!")
    }

    private func transitionToRobotIdea() {
        let nextScene = RobotIdeaScene(size: self.size)
        nextScene.scaleMode = .aspectFill
        self.view?.presentScene(nextScene, transition: .fade(withDuration: 0.5))
    }

    override func handleTouch(at location: CGPoint, touch: UITouch) {
        dialogBox.handleTap()
    }
}

struct KidScaredScene_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView(scene: KidScaredScene(size: CGSize(width: 1024, height: 726)))
            .ignoresSafeArea()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
