//
//  ContentView.swift
//  Donut
//
//  Created by kartikay on 23/01/26.
//

import SpriteKit
import SwiftUI

struct ContentView: View {
    var scene: SKScene {
        let scene = BedroomScene(size: CGSize(width: 1920, height: 1080))
        scene.scaleMode = .aspectFill
        return scene
    }

    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
