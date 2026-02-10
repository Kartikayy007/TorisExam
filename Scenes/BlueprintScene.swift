//
//  BlueprintScene.swift
//  Tori's Exam
//
//  Created by kartikay on 08/02/26.
//

import SpriteKit
import SwiftUI

class BlueprintScene: BaseScene {

    private var dialogBox: DialogBox!
    
    
    private var currentPhase: GamePhase = .hub
    private var clothesDone = false
    private var lunchDone = false
    private var bagDone = false
    
    enum GamePhase {
        case hub
        case clothes  
        case lunch    
        case bag      
        case complete
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupDialogBox()
        showHub()
    }
    
    private func clearScreen() {
        gameLayer.removeAllChildren()
        gameLayer.addChild(dialogBox)
    }
    
    
    
    private func showHub() {
        currentPhase = .hub
        clearScreen()
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        
        
        let title = SKLabelNode(text: "🧍 Tori's Blueprint")
        title.fontSize = 36
        title.fontName = "AvenirNext-Bold"
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height - 60)
        gameLayer.addChild(title)
        
        
        let codeBox = SKShapeNode(rectOf: CGSize(width: 350, height: 280), cornerRadius: 12)
        codeBox.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        codeBox.strokeColor = .green
        codeBox.position = CGPoint(x: size.width * 0.3, y: size.height * 0.5)
        gameLayer.addChild(codeBox)
        
        let clothesStatus = clothesDone ? "✅ Shirt" : "❌ nil"
        let lunchStatus = lunchDone ? "✅ Lunchbox" : "❌ nil"
        let bagStatus = bagDone ? "✅ Backpack" : "❌ nil"
        
        let codeText = """
class Human {
  var clothes: Clothing?
  var lunch: Lunch?
  var bag: Bag?
}

let tori = Human()
tori.clothes = \(clothesStatus)
tori.lunch = \(lunchStatus)
tori.bag = \(bagStatus)
"""
        
        let codeLabel = SKLabelNode(fontNamed: "Menlo")
        codeLabel.text = codeText
        codeLabel.fontSize = 16
        codeLabel.fontColor = .green
        codeLabel.numberOfLines = 0
        codeLabel.horizontalAlignmentMode = .left
        codeLabel.position = CGPoint(x: -150, y: 100)
        codeBox.addChild(codeLabel)
        
        
        createTaskButton(emoji: "👕", label: "Clothes", done: clothesDone, y: size.height * 0.65, name: "task_clothes", topic: "Inheritance")
        createTaskButton(emoji: "🍱", label: "Lunch", done: lunchDone, y: size.height * 0.45, name: "task_lunch", topic: "Encapsulation")
        createTaskButton(emoji: "🎒", label: "Bag", done: bagDone, y: size.height * 0.25, name: "task_bag", topic: "Polymorphism")
        
        
        if clothesDone && lunchDone && bagDone {
            dialogBox.showDialog(name: "Robot", text: "🎉 Tori is COMPLETE! All properties are set. You learned OOP by getting ready for school!")
        } else {
            let remaining = 3 - [clothesDone, lunchDone, bagDone].filter { $0 }.count
            dialogBox.showDialog(name: "Robot", text: "Tori needs \(remaining) more things! Tap a task to learn OOP concepts.")
        }
    }
    
    private func createTaskButton(emoji: String, label: String, done: Bool, y: CGFloat, name: String, topic: String) {
        let btn = SKShapeNode(rectOf: CGSize(width: 200, height: 80), cornerRadius: 12)
        btn.fillColor = done ? SKColor(red: 0.1, green: 0.3, blue: 0.1, alpha: 1.0) : SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        btn.strokeColor = done ? .green : .gray
        btn.position = CGPoint(x: size.width * 0.72, y: y)
        btn.name = name
        gameLayer.addChild(btn)
        
        let emojiLabel = SKLabelNode(text: emoji)
        emojiLabel.fontSize = 36
        emojiLabel.position = CGPoint(x: -50, y: -10)
        emojiLabel.name = name
        btn.addChild(emojiLabel)
        
        let textLabel = SKLabelNode(text: done ? "\(label) ✓" : label)
        textLabel.fontSize = 18
        textLabel.fontName = "AvenirNext-Medium"
        textLabel.fontColor = done ? .green : .white
        textLabel.position = CGPoint(x: 30, y: 5)
        textLabel.name = name
        btn.addChild(textLabel)
        
        let topicLabel = SKLabelNode(text: topic)
        topicLabel.fontSize = 12
        topicLabel.fontColor = .gray
        topicLabel.position = CGPoint(x: 30, y: -20)
        topicLabel.name = name
        btn.addChild(topicLabel)
    }
    
    
    
    private func showClothesGame() {
        currentPhase = .clothes
        clearScreen()
        backgroundColor = SKColor(red: 0.15, green: 0.1, blue: 0.1, alpha: 1.0)
        
        let title = SKLabelNode(text: "👕 Clothes - INHERITANCE")
        title.fontSize = 28
        title.fontName = "AvenirNext-Bold"
        title.fontColor = .yellow
        title.position = CGPoint(x: size.width / 2, y: size.height - 50)
        gameLayer.addChild(title)
        
        
        let codeBox = SKShapeNode(rectOf: CGSize(width: 400, height: 200), cornerRadius: 12)
        codeBox.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        codeBox.strokeColor = .cyan
        codeBox.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        gameLayer.addChild(codeBox)
        
        let code = """

class Clothing {
    var color: String
}


class Shirt: Clothing {
    var hasButtons: Bool
}
"""
        let codeLabel = SKLabelNode(fontNamed: "Menlo")
        codeLabel.text = code
        codeLabel.fontSize = 16
        codeLabel.fontColor = .green
        codeLabel.numberOfLines = 0
        codeLabel.horizontalAlignmentMode = .left
        codeLabel.position = CGPoint(x: -180, y: 70)
        codeBox.addChild(codeLabel)
        
        
        let parent = SKLabelNode(text: "👔 Clothing")
        parent.fontSize = 30
        parent.position = CGPoint(x: size.width * 0.3, y: size.height * 0.25)
        gameLayer.addChild(parent)
        
        let arrow = SKLabelNode(text: "⬇️ inherits")
        arrow.fontSize = 20
        arrow.position = CGPoint(x: size.width * 0.5, y: size.height * 0.25)
        gameLayer.addChild(arrow)
        
        let child = SKLabelNode(text: "👕 Shirt")
        child.fontSize = 30
        child.position = CGPoint(x: size.width * 0.7, y: size.height * 0.25)
        gameLayer.addChild(child)
        
        
        createDoneButton()
        
        dialogBox.showDialog(name: "Robot", text: "INHERITANCE: Shirt inherits from Clothing! It gets color property automatically, plus adds its own (hasButtons). Tap Done when ready!")
    }
    
    
    
    private func showLunchGame() {
        currentPhase = .lunch
        clearScreen()
        backgroundColor = SKColor(red: 0.1, green: 0.12, blue: 0.1, alpha: 1.0)
        
        let title = SKLabelNode(text: "🍱 Lunch - ENCAPSULATION")
        title.fontSize = 28
        title.fontName = "AvenirNext-Bold"
        title.fontColor = .yellow
        title.position = CGPoint(x: size.width / 2, y: size.height - 50)
        gameLayer.addChild(title)
        
        
        let codeBox = SKShapeNode(rectOf: CGSize(width: 400, height: 200), cornerRadius: 12)
        codeBox.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        codeBox.strokeColor = .cyan
        codeBox.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        gameLayer.addChild(codeBox)
        
        let code = """
class Lunchbox {
    private var food: [String]  
    
    func addFood(_ item: String) {
        food.append(item)
    }
    
    func eat() -> String {
        return food.popLast() ?? "Empty!"
    }
}
"""
        let codeLabel = SKLabelNode(fontNamed: "Menlo")
        codeLabel.text = code
        codeLabel.fontSize = 14
        codeLabel.fontColor = .green
        codeLabel.numberOfLines = 0
        codeLabel.horizontalAlignmentMode = .left
        codeLabel.position = CGPoint(x: -180, y: 80)
        codeBox.addChild(codeLabel)
        
        
        let box = SKLabelNode(text: "🍱 [🥪🍎🧃]")
        box.fontSize = 50
        box.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        gameLayer.addChild(box)
        
        let label = SKLabelNode(text: "Food is PRIVATE - protected inside!")
        label.fontSize = 18
        label.fontColor = .orange
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        gameLayer.addChild(label)
        
        createDoneButton()
        
        dialogBox.showDialog(name: "Robot", text: "ENCAPSULATION: The lunchbox HIDES your food (private). You can only access it through methods like eat()! Data is protected.")
    }
    
    
    
    private func showBagGame() {
        currentPhase = .bag
        clearScreen()
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        
        let title = SKLabelNode(text: "🎒 Bag - POLYMORPHISM")
        title.fontSize = 28
        title.fontName = "AvenirNext-Bold"
        title.fontColor = .yellow
        title.position = CGPoint(x: size.width / 2, y: size.height - 50)
        gameLayer.addChild(title)
        
        
        let codeBox = SKShapeNode(rectOf: CGSize(width: 420, height: 200), cornerRadius: 12)
        codeBox.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        codeBox.strokeColor = .cyan
        codeBox.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        gameLayer.addChild(codeBox)
        
        let code = """
protocol WritingTool {
    func write() -> String
}

class Pen: WritingTool {
    func write() -> String { "ink writing" }
}

class Pencil: WritingTool {
    func write() -> String { "graphite writing" }
}
"""
        let codeLabel = SKLabelNode(fontNamed: "Menlo")
        codeLabel.text = code
        codeLabel.fontSize = 14
        codeLabel.fontColor = .green
        codeLabel.numberOfLines = 0
        codeLabel.horizontalAlignmentMode = .left
        codeLabel.position = CGPoint(x: -190, y: 80)
        codeBox.addChild(codeLabel)
        
        
        let pen = SKLabelNode(text: "🖊️ .write()")
        pen.fontSize = 30
        pen.position = CGPoint(x: size.width * 0.3, y: size.height * 0.25)
        gameLayer.addChild(pen)
        
        let pencil = SKLabelNode(text: "✏️ .write()")
        pencil.fontSize = 30
        pencil.position = CGPoint(x: size.width * 0.7, y: size.height * 0.25)
        gameLayer.addChild(pencil)
        
        let label = SKLabelNode(text: "Same method name, different behavior!")
        label.fontSize = 18
        label.fontColor = .magenta
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        gameLayer.addChild(label)
        
        createDoneButton()
        
        dialogBox.showDialog(name: "Robot", text: "POLYMORPHISM: Pen and Pencil both have write(), but they work differently! Same interface, different implementation.")
    }
    
    private func createDoneButton() {
        let btn = SKLabelNode(text: "✅ Got it! Back to Hub")
        btn.fontSize = 22
        btn.fontName = "AvenirNext-Bold"
        btn.fontColor = .green
        btn.position = CGPoint(x: size.width / 2, y: 180)
        btn.name = "done_task"
        gameLayer.addChild(btn)
    }
    
    private func completeCurrentTask() {
        switch currentPhase {
        case .clothes: clothesDone = true
        case .lunch: lunchDone = true
        case .bag: bagDone = true
        default: break
        }
        showHub()
    }

    private func setupDialogBox() {
        dialogBox = DialogBox()
        dialogBox.position = CGPoint(x: size.width / 2, y: 80)
        dialogBox.zPosition = 100
        gameLayer.addChild(dialogBox)
        dialogBox.onDialogComplete = { [weak self] in
            self?.dialogBox.hideDialog()
        }
    }

    override func handleTouch(at location: CGPoint, touch: UITouch) {
        let tappedNodes = nodes(at: location)

        for node in tappedNodes {
            guard let name = node.name else { continue }
            
            
            if name == "task_clothes" && !clothesDone { showClothesGame(); return }
            if name == "task_lunch" && !lunchDone { showLunchGame(); return }
            if name == "task_bag" && !bagDone { showBagGame(); return }
            
            
            if name == "done_task" { completeCurrentTask(); return }
        }

        dialogBox.handleTap()
    }
}
