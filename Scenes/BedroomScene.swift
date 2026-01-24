//
//  BedroomScene.swift
//  Donut
//
//  Created by kartikay on 24/01/26.
//

import SpriteKit
import SwiftUI

class BedroomScene: SKScene {

    
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
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
        addChild(room)

        
        boy = SKSpriteNode(imageNamed: "Sleeping")
        boy.zPosition = 1
        boy.position = CGPoint(x: size.width * 0.35, y: size.height * 0.54)
        let boyScale = (size.width * 0.37) / boy.size.width
        boy.setScale(boyScale)
        addChild(boy)

        
        robot = SKSpriteNode(imageNamed: "RoboSleep")
        robot.zPosition = 1
        robot.position = CGPoint(x: size.width * 0.68, y: size.height * 0.55)
        let roboScale = (size.width * 0.4) / robot.size.width
        robot.setScale(roboScale)
        addChild(robot)
    }

    private func setupDialogBox() {
        dialogBox = DialogBox()
        dialogBox.position = CGPoint(x: size.width / 2, y: 120)
        dialogBox.zPosition = 100
        addChild(dialogBox)

        dialogBox.onDialogComplete = { [weak self] in
            self?.advanceStory()
        }
    }

    private func startInitialSequence() {
        dialogues = [
            ("", "Zzz... Zzz... *snoring peacefully*"),
            ("", "*RING RING RING!* 🔔"),
        ]
        currentDialogIndex = 0
        showCurrentDialogue()
    }

    private func startPostAlarmSequence() {
        boy.texture = SKTexture(imageNamed: "scared")
        robot.texture = SKTexture(imageNamed: "RoboScared")

        dialogues = [
            ("", "AHHHH!!!"),
            ("", "Ugh... five more minutes..."),
            ("", "..."),
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
        dialogBox.showDialog(name: dialogue.name, text: dialogue.text)
    }

    private func advanceStory() {
        currentDialogIndex += 1

        if !isPostAlarm {
            if currentDialogIndex == 2 {
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

    private func transitionToClock() {
        let clockScene = ClockScene(size: self.size)
        clockScene.scaleMode = .aspectFill
        self.view?.presentScene(clockScene, transition: .fade(withDuration: 0.5))
    }

    private func transitionToRobotIntro() {
        let robotScene = RobotIntroScene(size: self.size)
        robotScene.scaleMode = .aspectFill
        self.view?.presentScene(robotScene, transition: .fade(withDuration: 1.0))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dialogBox.handleTap()
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
