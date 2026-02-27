//
//  MyApp.swift
//  TorisExam
//
//  Created by kartikay on 23/01/26.
//

import SwiftUI

@main
struct MyApp: App {
    init() {
        let _ = AudioManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
