//
//  CheckpointManager.swift
//  Tori's Exam
//
//  Created by kartikay on 15/02/26.
//


import Foundation

@MainActor
class CheckpointManager {
    static let shared = CheckpointManager()

    private let defaults = UserDefaults.standard
    private let sceneKey = "checkpoint_scene"
    private let ingredientsKey = "checkpoint_kitchen_ingredients"

    private init() {}

    

    
    func saveScene(_ sceneType: Int) {
        defaults.set(sceneType, forKey: sceneKey)
    }

    
    func saveKitchenIngredients(_ ingredients: [String]) {
        defaults.set(ingredients, forKey: ingredientsKey)
    }

    

    
    func savedSceneRawValue() -> Int? {
        defaults.object(forKey: sceneKey) as? Int
    }

    
    func savedKitchenIngredients() -> [String] {
        defaults.stringArray(forKey: ingredientsKey) ?? []
    }

    

    func clearAll() {
        defaults.removeObject(forKey: sceneKey)
        defaults.removeObject(forKey: ingredientsKey)
    }
}
