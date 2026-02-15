//
//  SceneRegistry.swift
//  Toris Exam
//
//  Created by kartikay on 08/02/26.
//

import SpriteKit

enum SceneType: Int, CaseIterable {
    case bedroom = 0
    case clock = 1
    case bedroomPostAlarm = 2
    case robotIntro = 3
    case kidScared = 4
    case robotIdea = 5
    case thankYou = 6
    case oopIntro = 7
    case closet = 8
    case blueprint = 9
    case kitchen = 10

    var displayName: String {
        switch self {
        case .bedroom: return "Bedroom (Sleeping)"
        case .clock: return "Alarm Clock"
        case .bedroomPostAlarm: return "Bedroom (Awake)"
        case .robotIntro: return "Robot Introduction"
        case .kidScared: return "Kid Scared"
        case .robotIdea: return "Robot's Idea"
        case .thankYou: return "Thank You"
        case .oopIntro: return "OOP Introduction"
        case .closet: return "Closet Mini-Game"
        case .blueprint: return "Blueprint Hub"
        case .kitchen: return "Kitchen Mini-Game"
        }
    }

    var next: SceneType? {
        SceneType(rawValue: self.rawValue + 1)
    }

    var previous: SceneType? {
        SceneType(rawValue: self.rawValue - 1)
    }

    func createScene(size: CGSize) -> BaseScene {
        switch self {
        case .bedroom:
            return BedroomScene(size: size, isPostAlarm: false)
        case .clock:
            return ClockScene(size: size)
        case .bedroomPostAlarm:
            return BedroomScene(size: size, isPostAlarm: true)
        case .robotIntro:
            return RobotIntroScene(size: size)
        case .kidScared:
            return KidScaredScene(size: size)
        case .robotIdea:
            return RobotIdeaScene(size: size)
        case .thankYou:
            return ThankYouScene(size: size)
        case .oopIntro:
            return OOPIntroScene(size: size)
        case .closet:
            return ClosetScene(size: size)
        case .blueprint:
            return BlueprintScene(size: size)
        case .kitchen:
            return KitchenScene(size: size)
        }
    }

    static var first: SceneType { .bedroom }
    static var last: SceneType { .kitchen }
}

@MainActor
class SceneNavigator {
    static let shared = SceneNavigator()

    var currentSceneType: SceneType = .bedroom
    private(set) var history: [SceneType] = []

    private init() {}

    func navigateTo(_ sceneType: SceneType, from view: SKView?) {
        history.append(currentSceneType)
        currentSceneType = sceneType

        // Save checkpoint
        CheckpointManager.shared.saveScene(sceneType.rawValue)

        let newScene = sceneType.createScene(size: CGSize(width: 1920, height: 1080))
        newScene.scaleMode = .aspectFill
        view?.presentScene(newScene, transition: .fade(withDuration: 0.5))
    }

    func goToNext(from view: SKView?) {
        guard let next = currentSceneType.next else { return }
        navigateTo(next, from: view)
    }

    func reset() {
        currentSceneType = .bedroom
        history = []
    }
}
