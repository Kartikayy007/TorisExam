//
//  TheoryView.swift
//  TorisExam
//
//  Created by kartikay on 26/02/26.
//

import SwiftUI


struct OOPPillar: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let color: Color
    let points: [TheoryPoint]
}

struct TheoryPoint: Identifiable {
    let id = UUID()
    let heading: String
    let body: String
    let codeSnippet: String?
}

private let oopPillars: [OOPPillar] = [
    OOPPillar(
        title: "Classes & Objects",
        subtitle: "The Building Blocks of OOP",
        color: Color(red: 0.25, green: 0.48, blue: 0.32),
        points: [
            TheoryPoint(
                heading: "What is a Class?",
                body:
                    "A class is a blueprint for creating objects. It defines the properties (data) and methods (behaviour) that every object of that type will have.",
                codeSnippet:
                    "class Sandwich {\n    var bread: String\n    var fillings: [String]\n\n    func eat() {\n        print(\"Nom nom nom!\")\n    }\n}"
            ),
            TheoryPoint(
                heading: "What is an Object?",
                body:
                    "An object is one specific instance of a class. You can make many objects from the same class — just like Tori could pack multiple sandwiches from the same recipe.",
                codeSnippet:
                    "let toriLunch = Sandwich()\ntoriLunch.bread = \"Wholegrain\"\ntoriLunch.fillings = [\"cheese\", \"tomato\", \"spinach\"]\ntoriLunch.eat() // Nom nom nom!"
            ),
            TheoryPoint(
                heading: "Why does this matter?",
                body:
                    "Instead of scattered variables, related data and behaviour live together in one organised unit — like all of Tori's lunch ingredients packaged in a single lunchbox.",
                codeSnippet: nil
            ),
        ]
    ),
    OOPPillar(
        title: "Inheritance",
        subtitle: "Extending Existing Classes",
        color: Color(red: 0.48, green: 0.28, blue: 0.58),
        points: [
            TheoryPoint(
                heading: "What is Inheritance?",
                body:
                    "Inheritance lets a subclass reuse all the methods of its parent (superclass) — without writing them again. In the Kitchen, MacAndCheese inherited everything BasicPasta already knew.",
                codeSnippet:
                    "class BasicPasta {\n    func boilWater() { }\n    func addPasta()  { }\n    func drain()     { }\n    func serve()     { }\n}\n\n// MacAndCheese IS-A BasicPasta\nclass MacAndCheese: BasicPasta {\n    // Inherits all 4 steps above!\n    func addCheese() { } // New step\n}"
            ),
            TheoryPoint(
                heading: "The 'is-a' Relationship",
                body:
                    "Inheritance models an 'is-a' relationship. MacAndCheese IS a BasicPasta. It has everything BasicPasta has, plus its own unique step: addCheese().",
                codeSnippet:
                    "let dinner = MacAndCheese()\ndinner.boilWater() // inherited\ndinner.addPasta()  // inherited\ndinner.drain()     // inherited\ndinner.serve()     // inherited\ndinner.addCheese() // its own!"
            ),
            TheoryPoint(
                heading: "Override",
                body:
                    "A subclass can also override a parent's method to behave differently, using the `override` keyword.",
                codeSnippet:
                    "class SpicyPasta: BasicPasta {\n    override func serve() {\n        print(\"Serve with chilli flakes!\")\n    }\n}"
            ),
        ]
    ),
    OOPPillar(
        title: "Encapsulation",
        subtitle: "Hiding Internal Details",
        color: Color(red: 0.55, green: 0.36, blue: 0.2),
        points: [
            TheoryPoint(
                heading: "What is Encapsulation?",
                body:
                    "Encapsulation means keeping a class's internal data private. Outside code can't directly touch it — it must go through controlled methods. In the Kitchen, the Sandwich ingredients were locked inside the class.",
                codeSnippet:
                    "class Sandwich {\n    // Private — only this class can touch them\n    private var bread: String = \"\"\n    private var fillings: [String] = []\n\n    func addFilling(_ item: String) {\n        fillings.append(item)\n    }\n\n    func getDescription() -> String {\n        return fillings.joined(separator: \", \")\n    }\n}"
            ),
            TheoryPoint(
                heading: "Why hide data?",
                body:
                    "If fillings were public, any part of the code could add random things or break the sandwich. Private properties ensure only safe, controlled changes happen — protecting the object's state.",
                codeSnippet:
                    "let lunch = Sandwich()\nlunch.addFilling(\"cheese\")  // OK\nlunch.addFilling(\"tomato\")  // OK\n// lunch.fillings = [] // Error! Private."
            ),
        ]
    ),
    OOPPillar(
        title: "Polymorphism",
        subtitle: "One Interface, Many Forms",
        color: Color(red: 0.6, green: 0.18, blue: 0.22),
        points: [
            TheoryPoint(
                heading: "What is Polymorphism?",
                body:
                    "The same method name can behave completely differently depending on which object calls it. In the Kitchen, prepare() was one button — but each ingredient reacted its own way.",
                codeSnippet:
                    "class Ingredient {\n    func prepare() { }\n}\n\nclass Tomato: Ingredient {\n    override func prepare() {\n        print(\"Slices cleanly\")\n    }\n}\n\nclass Egg: Ingredient {\n    override func prepare() {\n        print(\"Cracks open\")\n    }\n}\n\nclass Orange: Ingredient {\n    override func prepare() {\n        print(\"Peels skin\")\n    }\n}"
            ),
            TheoryPoint(
                heading: "Same Call, Different Result",
                body:
                    "You can call prepare() on any ingredient and get the right result — without knowing exactly which ingredient it is. This makes code flexible and easy to extend.",
                codeSnippet:
                    "let ingredients: [Ingredient] =\n    [Tomato(), Egg(), Orange()]\n\nfor item in ingredients {\n    item.prepare()\n    // Slices cleanly\n    // Cracks open\n    // Peels skin\n}"
            ),
        ]
    ),
    OOPPillar(
        title: "Abstraction",
        subtitle: "Focusing on What, Not How",
        color: Color(red: 0.2, green: 0.38, blue: 0.6),
        points: [
            TheoryPoint(
                heading: "What is Abstraction?",
                body:
                    "Abstraction means hiding complex steps behind one simple interface. In the Kitchen, all six cooking steps were hidden inside a single packLunch() call — one tap, everything done.",
                codeSnippet:
                    "func packLunch() {\n    boilWater()\n    addPasta()\n    drain()\n    serve()\n    addCheese()\n    packSandwich()\n}\n\n// Caller doesn't need to know any of\n// the six steps — just one call!\npackLunch()"
            ),
            TheoryPoint(
                heading: "Protocols",
                body:
                    "Swift uses protocols to define an abstract contract — any class that conforms must implement the methods listed, but each can do so in its own way.",
                codeSnippet:
                    "protocol Packable {\n    func pack()   // What to do\n    func label()  // How to label it\n}\n\nclass Lunchbox: Packable {\n    func pack()  { /* add food  */ }\n    func label() { /* write name */ }\n}"
            ),
            TheoryPoint(
                heading: "Real-World Analogy",
                body:
                    "Pressing Pack Lunch on the robot was abstraction in action. You didn't see boiling, draining, or plating — just one button. The complexity was hidden from you.",
                codeSnippet: nil
            ),
        ]
    ),
]


struct TheoryView: View {
    let onDismiss: () -> Void
    @State private var isVisible = false
    @State private var selectedPillarIndex = 0

    private let warmBg = Color(red: 0.94, green: 0.87, blue: 0.73)
    private let sidebarBg = Color(red: 0.88, green: 0.80, blue: 0.64)
    private let borderOuter = Color(red: 0.65, green: 0.45, blue: 0.25)
    private let borderInner = Color(red: 0.35, green: 0.25, blue: 0.15)
    private let textPrimary = Color(red: 0.2, green: 0.15, blue: 0.1)
    private let textSecondary = Color(red: 0.35, green: 0.27, blue: 0.18)

    var selectedPillar: OOPPillar { oopPillars[selectedPillarIndex] }

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            HStack(spacing: 0) {

                VStack(spacing: 0) {
                    Text("OOP Theory")
                        .font(.custom("AmericanTypewriter-Bold", size: 24))
                        .foregroundColor(textPrimary)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 14)

                    Divider().background(borderOuter)

                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(Array(oopPillars.enumerated()), id: \.offset) { idx, pillar in
                                PillarTabButton(
                                    pillar: pillar,
                                    isSelected: selectedPillarIndex == idx,
                                    textPrimary: textPrimary
                                ) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        selectedPillarIndex = idx
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                    }

                    Spacer()

                    Divider().background(borderOuter)

                    Button(action: onDismiss) {
                        Text("Close")
                            .font(.custom("AmericanTypewriter-Bold", size: 22))
                            .foregroundColor(textPrimary)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 32)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.85, green: 0.75, blue: 0.6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(borderInner, lineWidth: 3)
                            )
                    }
                    .padding(18)
                }
                .frame(width: 220)
                .background(sidebarBg)

                Rectangle()
                    .fill(borderOuter)
                    .frame(width: 3)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedPillar.title)
                                .font(.custom("AmericanTypewriter-Bold", size: 34))
                                .foregroundColor(selectedPillar.color)
                            Text(selectedPillar.subtitle)
                                .font(.custom("AmericanTypewriter", size: 18))
                                .foregroundColor(textSecondary)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 28)
                        .padding(.bottom, 12)

                        Rectangle()
                            .fill(selectedPillar.color.opacity(0.45))
                            .frame(height: 2)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 22)

                        ForEach(selectedPillar.points) { point in
                            TheoryPointCard(
                                point: point,
                                accentColor: selectedPillar.color,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary
                            )
                            .padding(.horizontal, 26)
                            .padding(.bottom, 18)
                        }

                        Spacer(minLength: 24)
                    }
                }
                .id(selectedPillarIndex)
                .frame(maxWidth: .infinity)
            }
            .frame(width: 1180, height: 780)
            .background(warmBg)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(borderOuter, lineWidth: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(borderInner, lineWidth: 3)
                    .padding(10)
            )
            .shadow(color: .black.opacity(0.6), radius: 25, x: 5, y: 15)
            .scaleEffect(isVisible ? 1 : 0.85)
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
}


struct PillarTabButton: View {
    let pillar: OOPPillar
    let isSelected: Bool
    let textPrimary: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(isSelected ? pillar.color : Color.clear)
                    .frame(width: 4)
                    .padding(.trailing, 10)

                Text(pillar.title)
                    .font(.custom("AmericanTypewriter-Bold", size: 15))
                    .foregroundColor(isSelected ? pillar.color : textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? pillar.color.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}


struct TheoryPointCard: View {
    let point: TheoryPoint
    let accentColor: Color
    let textPrimary: Color
    let textSecondary: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor)
                    .frame(width: 4, height: 22)
                Text(point.heading)
                    .font(.custom("AmericanTypewriter-Bold", size: 20))
                    .foregroundColor(accentColor)
            }

            Text(point.body)
                .font(.custom("AmericanTypewriter", size: 16))
                .foregroundColor(textPrimary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            if let code = point.codeSnippet {
                Text(code)
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundColor(Color(red: 0.1, green: 0.42, blue: 0.25))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.86, green: 0.95, blue: 0.86).opacity(0.8))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(accentColor.opacity(0.25), lineWidth: 1.5)
                    )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.38))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(accentColor.opacity(0.18), lineWidth: 1.5)
        )
    }
}

#Preview {
    TheoryView(onDismiss: {})
}
