//
//  BaseScene.swift
//  TorisExam
//
//  Created by kartikay on 07/02/26.
//

import SpriteKit

class BaseScene: SKScene {

    required override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var gameLayer: SKEffectNode!
    var isGamePaused = false
    private var hasSetup = false
    var onPillarDefDismiss: (() -> Void)?

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        guard !hasSetup else { return }
        hasSetup = true
        setupBaseLayers()
        sceneDidSetup()
    }

    func sceneDidSetup() {

    }

    private func setupBaseLayers() {
        gameLayer = SKEffectNode()
        gameLayer.shouldEnableEffects = false
        gameLayer.zPosition = 0
        addChild(gameLayer)
    }

    func pause() {
        guard !isGamePaused else { return }
        isGamePaused = true
        gameLayer.isPaused = true
        gameLayer.speed = 0

        self.isPaused = true

        let blur = CIFilter(name: "CIGaussianBlur")
        blur?.setValue(10.0, forKey: "inputRadius")
        gameLayer.filter = blur
        gameLayer.shouldEnableEffects = true
    }

    func resume() {
        guard isGamePaused else { return }
        isGamePaused = false
        gameLayer.isPaused = false
        gameLayer.speed = 1
        self.isPaused = false
        gameLayer.filter = nil
        gameLayer.shouldEnableEffects = false
    }

    func restartScene() {
        guard let view = self.view else { return }
        let newScene = type(of: self).init(size: self.size)
        newScene.scaleMode = self.scaleMode
        view.presentScene(newScene)
    }

    func navigateTo(_ sceneType: SceneType) {
        SceneNavigator.shared.navigateTo(sceneType, from: self.view)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if isGamePaused {
            return
        }

        if let overlay = gameLayer.childNode(withName: "pillar_def_overlay") {
            overlay.run(
                SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.removeFromParent(),
                ]))
            onPillarDefDismiss?()
            onPillarDefDismiss = nil
            return
        }

        handleTouch(at: location, touch: touch)
    }

    func handleTouch(at location: CGPoint, touch: UITouch) {

    }

    func showPillarDefinition(title: String, description: String, onDismiss: @escaping () -> Void) {
        self.onPillarDefDismiss = onDismiss

        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor(white: 0.1, alpha: 0.95)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 500
        overlay.name = "pillar_def_overlay"
        overlay.alpha = 0
        gameLayer.addChild(overlay)

        let titleLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        titleLabel.text = title
        titleLabel.fontSize = 60
        titleLabel.fontColor = SKColor(red: 0.9, green: 0.8, blue: 0.4, alpha: 1.0)
        titleLabel.position = CGPoint(x: 0, y: 80)
        overlay.addChild(titleLabel)

        let descLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        descLabel.text = description
        descLabel.fontSize = 28
        descLabel.fontColor = .white
        descLabel.numberOfLines = 0
        descLabel.preferredMaxLayoutWidth = size.width * 0.7
        descLabel.horizontalAlignmentMode = .center
        descLabel.position = CGPoint(x: 0, y: -20)
        overlay.addChild(descLabel)

        let tapLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        tapLabel.text = "Tap to Continue"
        tapLabel.fontSize = 20
        tapLabel.fontColor = .gray
        tapLabel.position = CGPoint(x: 0, y: -150)
        overlay.addChild(tapLabel)

        tapLabel.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.4, duration: 0.8),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.8),
                ])))

        overlay.run(SKAction.fadeIn(withDuration: 0.4))
    }
}
