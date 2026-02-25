import FoundationModels
import SwiftUI

@available(iOS 26.0, macOS 16.0, *)
@Generable
struct MCQ {
    var question: String
    var optionA: String
    var optionB: String
    var optionC: String
    var optionD: String
    var correctOption: String
    var explanation: String
}

@available(iOS 26.0, macOS 16.0, *)
@Generable
struct ExamPaper {
    @Guide(description: "Exactly 10 multiple choice questions about OOP", .count(10))
    var questions: [MCQ]
}

enum ExamState {
    case loading
    case testing
    case grading
    case scorecard
}

@available(iOS 26.0, macOS 16.0, *)
struct ExamHallView: View {
    @ObservedObject var gameState: GameStateManager

    @State private var session = LanguageModelSession()
    @State private var examState: ExamState = .loading
    @State private var paper: ExamPaper? = nil

    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int: String] = [:]

    var body: some View {
        ZStack {
            Image("Room")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .blur(radius: 10)

            Color.black.opacity(0.4).ignoresSafeArea()

            // Clipboard Setup
            ZStack(alignment: .top) {
                // Brown Board
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.7, green: 0.45, blue: 0.25))
                    .frame(maxWidth: 900, maxHeight: 1100)
                    .shadow(radius: 10)

                // White Paper
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(maxWidth: 820, maxHeight: 1020)
                    .padding(.top, 40)
                    .shadow(radius: 2)

                // Silver Clip
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(white: 0.9), Color(white: 0.6)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 300, height: 60)
                    .shadow(radius: 3)
                    .offset(y: -15)

                // Content Layer
                VStack {
                    Text("EXAM: ROBOTICS 101")
                        .font(.custom("AmericanTypewriter-Bold", size: 48))
                        .foregroundColor(.black)
                        .padding(.top, 80)
                        .padding(.bottom, 20)

                    if examState != .loading {
                        HStack {
                            Text("NAME: Tori")
                            Spacer()
                            Text("DATE: _____")
                        }
                        .font(.custom("AmericanTypewriter", size: 28))
                        .foregroundColor(.black)
                        .padding(.horizontal, 60)
                        .padding(.bottom, 30)
                    }

                    Spacer()

                    switch examState {
                    case .loading:
                        loadingView()
                    case .testing:
                        if let paper = paper {
                            testingView(paper: paper)
                        }
                    case .grading:
                        gradingView()
                    case .scorecard:
                        if let paper = paper {
                            scorecardView(paper: paper)
                        }
                    }

                    Spacer()
                }
                .frame(maxWidth: 820, maxHeight: 1020)
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            generateExam()
        }
    }

    private func generateExam() {
        Task {
            do {
                let prompt = """
                    Generate exactly 10 multiple choice questions testing Object-Oriented Programming (OOP) in Swift.
                    Strictly limit the syllabus to: Inheritance, Polymorphism, Encapsulation, and Abstraction.
                    Make the questions beginner friendly. Ensure exactly one correct option (A, B, C, or D).
                    """

                let response = try await session.respond(
                    to: prompt,
                    generating: ExamPaper.self
                )

                DispatchQueue.main.async {
                    self.paper = response.content
                    withAnimation {
                        self.examState = .testing
                    }
                }
            } catch {
                print("Failed to generate exam: \(error)")
                let mockPaper = ExamPaper(questions: [
                    MCQ(
                        question: "What does OOP stand for?",
                        optionA: "Object-Oriented Programming", optionB: "Only Open Papers",
                        optionC: "Overly Optimistic Programming",
                        optionD: "Optional Object Passing", correctOption: "A",
                        explanation: "OOP stands for Object-Oriented Programming."),
                    MCQ(
                        question: "Which of these is a pillar of OOP?", optionA: "Compilation",
                        optionB: "Polymorphism", optionC: "Iteration", optionD: "Execution",
                        correctOption: "B",
                        explanation: "Polymorphism is one of the 4 pillars of OOP."),
                    MCQ(
                        question: "What is a Class in Swift?", optionA: "A real-world object",
                        optionB: "A blueprint for creating objects", optionC: "A type of loop",
                        optionD: "A compiled binary", correctOption: "B",
                        explanation:
                            "A Class acts as a blueprint from which objects are instantiated."),
                    MCQ(
                        question: "What allows an object to take on many forms?",
                        optionA: "Encapsulation", optionB: "Polymorphism", optionC: "Inheritance",
                        optionD: "Abstraction", correctOption: "B",
                        explanation:
                            "Polymorphism allows objects of different types to be treated as instances of the same class through a common interface."
                    ),
                    MCQ(
                        question: "What hides the internal state of an object?",
                        optionA: "Encapsulation", optionB: "Abstraction", optionC: "Polymorphism",
                        optionD: "Inheritance", correctOption: "A",
                        explanation:
                            "Encapsulation bundles data and methods and hides the internal state."),
                    MCQ(
                        question:
                            "What simplifies complex reality by modeling classes appropriate to the problem?",
                        optionA: "Polymorphism", optionB: "Encapsulation", optionC: "Abstraction",
                        optionD: "Inheritance", correctOption: "C",
                        explanation:
                            "Abstraction reduces complexity by hiding unnecessary details from the user."
                    ),
                    MCQ(
                        question:
                            "Which mechanism allows a class to acquire properties of another class?",
                        optionA: "Abstraction", optionB: "Encapsulation", optionC: "Inheritance",
                        optionD: "Polymorphism", correctOption: "C",
                        explanation:
                            "Inheritance creates a parent-child relationship where the child inherits from the parent."
                    ),
                    MCQ(
                        question: "What is an instance of a Class called?", optionA: "A method",
                        optionB: "A property", optionC: "An object", optionD: "A function",
                        correctOption: "C",
                        explanation: "An object is an instantiated instance of a Class."),
                    MCQ(
                        question: "Which of the following is NOT a pillar of OOP?",
                        optionA: "Encapsulation", optionB: "Inheritance", optionC: "Recursion",
                        optionD: "Polymorphism", correctOption: "C",
                        explanation:
                            "Recursion is a procedural programming concept, not an OOP pillar."),
                    MCQ(
                        question: "What is the purpose of an init() method?",
                        optionA: "To delete an object",
                        optionB: "To initialize an object's properties", optionC: "To hide data",
                        optionD: "To inherit from a superclass", correctOption: "B",
                        explanation: "The init method sets up the initial state of an object."),
                ])
                DispatchQueue.main.async {
                    self.paper = mockPaper
                    withAnimation {
                        self.examState = .testing
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func loadingView() -> some View {
        VStack(spacing: 30) {
            ProgressView()
                .scaleEffect(2.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .black))

            Text("Robot is printing your personalized AI exam...")
                .font(.custom("AmericanTypewriter", size: 28))
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    private func testingView(paper: ExamPaper) -> some View {
        ScrollView(showsIndicators: true) {
            VStack(alignment: .leading, spacing: 50) {
                Text("SECTION A: MULTIPLE CHOICE (10 Questions)")
                    .font(.custom("AmericanTypewriter-Bold", size: 28))
                    .foregroundColor(.black)
                    .padding(.bottom, 10)

                ForEach(0..<10, id: \.self) { index in
                    let q = paper.questions[index]

                    VStack(alignment: .leading, spacing: 20) {
                        Text("\(index + 1). \(q.question)")
                            .font(.custom("AmericanTypewriter-Bold", size: 32))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)

                        VStack(alignment: .leading, spacing: 15) {
                            optionButton(for: index, letter: "A", text: q.optionA)
                            optionButton(for: index, letter: "B", text: q.optionB)
                            optionButton(for: index, letter: "C", text: q.optionC)
                            optionButton(for: index, letter: "D", text: q.optionD)
                        }
                        .padding(.leading, 30)
                    }
                }

                // Submit Button
                HStack {
                    Spacer()
                    Button(action: {
                        submitExam()
                    }) {
                        Text("Submit Exam")
                            .font(.custom("AmericanTypewriter-Bold", size: 32))
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 40)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.bottom, 60)
            }
            .padding(.horizontal, 40)
            .padding(.top, 30)
        }
    }

    private func optionButton(for questionIndex: Int, letter: String, text: String) -> some View {
        let isSelected = selectedAnswers[questionIndex] == letter

        return Button(action: {
            selectedAnswers[questionIndex] = letter
        }) {
            HStack(spacing: 15) {
                // Checkbox styling (like drawing on paper)
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 30, height: 30)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)  // Blue ink look
                    }
                }

                Text("\(letter). \(text)")
                    .font(.custom("AmericanTypewriter", size: 26))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func submitExam() {
        withAnimation {
            examState = .grading
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                examState = .scorecard
            }
        }
    }

    @ViewBuilder
    private func gradingView() -> some View {
        VStack(spacing: 30) {
            ProgressView()
                .scaleEffect(2.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .black))

            Text("Robot is checking your answers...")
                .font(.custom("AmericanTypewriter", size: 28))
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    private func scorecardView(paper: ExamPaper) -> some View {
        let score = calculateScore(paper: paper)
        let pass = score >= 7

        VStack(spacing: 0) {
            Text(pass ? "EXAM PASSED!" : "EXAM FAILED")
                .font(.custom("AmericanTypewriter-Bold", size: 64))
                .foregroundColor(pass ? .green : .red)
                .rotationEffect(.degrees(-5))  // give it a fun "stamped" look
                .scaleEffect(1.1)
                .padding(.bottom, 20)

            Text("Final Score: \(score) / 10")
                .font(.custom("AmericanTypewriter-Bold", size: 42))
                .foregroundColor(.black)
                .padding(.bottom, 20)

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<10, id: \.self) { i in
                        let q = paper.questions[i]
                        let userAns = selectedAnswers[i] ?? "None"
                        let isCorrect = userAns == q.correctOption

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Q\(i+1): \(q.question)")
                                .font(.custom("AmericanTypewriter-Bold", size: 24))
                                .foregroundColor(.black)

                            HStack {
                                Text("Your Answer: \(userAns)")
                                    .foregroundColor(isCorrect ? .blue : .red)
                                Text("| Correct: \(q.correctOption)")
                                    .foregroundColor(.green)
                            }
                            .font(.custom("AmericanTypewriter", size: 20))

                            if !isCorrect {
                                Text("Explanation: \(q.explanation)")
                                    .font(.custom("AmericanTypewriter", size: 18))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)
            }
            .frame(maxHeight: 450)

            Button(action: {
                gameState.quitToMainMenu()
            }) {
                Text("Return to Menu")
                    .font(.custom("AmericanTypewriter-Bold", size: 32))
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 40)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top, 30)
        }
    }

    private func calculateScore(paper: ExamPaper) -> Int {
        var score = 0
        for i in 0..<10 {
            if selectedAnswers[i] == paper.questions[i].correctOption {
                score += 1
            }
        }
        return score
    }
}

@available(iOS 26.0, macOS 16.0, *)
#Preview {
    ExamHallView(gameState: GameStateManager())
}
