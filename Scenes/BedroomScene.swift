//
//  BedroomScene.swift
//  Tori's Exam
//
//  Created by kartikay on 24/01/26.
//

import SpriteKit
import SwiftUI

class BedroomScene: BaseScene {

    private var dialogBox: DialogBox!

    private var boy: SKSpriteNode!
    private var robot: SKSpriteNode!
    private var room: SKSpriteNode!

    private var dialogues: [(name: String, text: String)] = []
    private var currentDialogIndex = 0
    private var isPostAlarm: Bool = false

    init(size: CGSize, isPostAlarm: Bool = false) {
        self.isPostAlarm = isPostAlarm
        super.init(size: size)
    }

    required init(size: CGSize) {
        self.isPostAlarm = false
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sceneDidSetup() {
        setupScene()
        setupDialogBox()

        if isPostAlarm {
            startPostAlarmSequence()
        } else {
            startInitialSequence()
        }
    }

    private func setupScene() {
        backgroundColor = .black

        room = SKSpriteNode(imageNamed: "Room")
        room.position = CGPoint(x: size.width / 2, y: size.height / 2)
        room.zPosition = 0
        let scaleX = size.width / room.size.width
        let scaleY = size.height / room.size.height
        room.setScale(max(scaleX, scaleY))
        gameLayer.addChild(room)

        boy = SKSpriteNode(imageNamed: "Sleeping")
        boy.zPosition = 1
        boy.position = CGPoint(x: size.width * 0.35, y: size.height * 0.54)
        let boyScale = (size.width * 0.37) / boy.size.width
        boy.setScale(boyScale)
        gameLayer.addChild(boy)

        robot = SKSpriteNode(imageNamed: "RoboSleep")
        robot.zPosition = 1
        robot.position = CGPoint(x: size.width * 0.68, y: size.height * 0.55)
        let roboScale = (size.width * 0.4) / robot.size.width
        robot.setScale(roboScale)
        gameLayer.addChild(robot)
    }

    private func setupDialogBox() {
        dialogBox = DialogBox()
        dialogBox.position = CGPoint(x: size.width / 2, y: 120)
        dialogBox.zPosition = 100
        gameLayer.addChild(dialogBox)

        dialogBox.onDialogComplete = { [weak self] in
            self?.advanceStory()
        }
    }

    private func startInitialSequence() {
        dialogues = [
            ("", "Zzz... Zzz... snoring peacefully")
        ]
        currentDialogIndex = 0
        showCurrentDialogue()
        spawnZzz()
    }

    private func startPostAlarmSequence() {
        boy.texture = SKTexture(imageNamed: "scared")
        robot.texture = SKTexture(imageNamed: "RoboScared")

        dialogues = [
            ("Tori", "AHHHH!!!"),
            ("Tori", "Ugh... What!!! im late..."),
            ("Tori", "I have a exam too of Object oriented programing OOPS"),
        ]
        currentDialogIndex = 0
        showCurrentDialogue()
    }

    private func showCurrentDialogue() {
        guard currentDialogIndex < dialogues.count else {
            dialogBox.hideDialog()
            return
        }
        let dialogue = dialogues[currentDialogIndex]
        dialogBox.onDialogComplete = { [weak self] in
            self?.advanceStory()
        }
        dialogBox.showDialog(name: dialogue.name, text: dialogue.text)
    }

    private func advanceStory() {
        currentDialogIndex += 1

        if !isPostAlarm {
            // Fix: advance to clock after the single "snoring peacefully" dialogue is tapped
            if currentDialogIndex >= dialogues.count {
                transitionToClock()
            } else {
                showCurrentDialogue()
            }
        } else {
            if currentDialogIndex == 1 {
                boy.texture = SKTexture(imageNamed: "Sitting")
                boy.position = CGPoint(x: size.width * 0.35, y: size.height * 0.5)
                let sittingScale = (size.width * 0.34) / boy.size.width
                boy.setScale(sittingScale)
                showCurrentDialogue()
            } else if currentDialogIndex == 2 {
                showCurrentDialogue()
            } else if currentDialogIndex == 3 {
                transitionToRobotIntro()
            } else {
                showCurrentDialogue()
            }
        }
    }

    private func spawnZzz() {
        guard !isPostAlarm else { return }

        let zLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        zLabel.text = "Z"
        zLabel.fontSize = CGFloat.random(in: 20...40)
        zLabel.fontColor = .white
        zLabel.alpha = 0

        // Start near boy's head
        let headX = size.width * 0.38
        let headY = size.height * 0.54
        zLabel.position = CGPoint(
            x: headX + CGFloat.random(in: -20...20),
            y: headY + CGFloat.random(in: 0...20)
        )
        zLabel.zPosition = 10
        gameLayer.addChild(zLabel)

        // Float up and fade
        let floatUp = SKAction.moveBy(x: CGFloat.random(in: 20...50), y: 150, duration: 2.0)
        let fadeSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.5),
        ])

        let group = SKAction.group([floatUp, fadeSequence])
        zLabel.run(SKAction.sequence([group, SKAction.removeFromParent()]))

        run(
            SKAction.sequence([
                SKAction.wait(forDuration: Double.random(in: 0.8...1.5)),
                SKAction.run { [weak self] in self?.spawnZzz() },
            ]))
    }

    private func transitionToClock() {
        navigateTo(.clock)
    }

    private func transitionToRobotIntro() {
        navigateTo(.robotIntro)
    }

    override func handleTouch(at location: CGPoint, touch: UITouch) {
        dialogBox.handleTap()
    }

    override func restartScene() {
        guard let view = self.view else { return }
        let newScene = BedroomScene(size: self.size, isPostAlarm: self.isPostAlarm)
        newScene.scaleMode = self.scaleMode
        view.presentScene(newScene)
    }
}

struct BedroomScene_SittingPreview: PreviewProvider {
    static var previews: some View {
        SpriteView(
            scene: {
                let scene = BedroomScene(size: CGSize(width: 1920, height: 1080), isPostAlarm: true)
                scene.scaleMode = .aspectFill
                return scene
            }()
        )
        .previewInterfaceOrientation(.landscapeLeft)
        .ignoresSafeArea()
    }
}
