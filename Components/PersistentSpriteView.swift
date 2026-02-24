//
//  PersistentSpriteView.swift
//  TorisExam
//
//  Created by kartikay on 16/02/26.
//

import SpriteKit
import SwiftUI

struct PersistentSpriteView: UIViewRepresentable {
    let scene: SKScene

    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        skView.preferredFramesPerSecond = 60
        skView.presentScene(scene)
        return skView
    }

    func updateUIView(_ skView: SKView, context: Context) {

        if skView.scene !== scene {
            skView.presentScene(scene)
        }

    }
}
