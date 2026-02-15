//
//  BaseScene.swift
//  Tori's Exam
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
        handleTouch(at: location, touch: touch)
    }

    func handleTouch(at location: CGPoint, touch: UITouch) {

    }
}
