import SpriteKit
import SwiftUI

#if canImport(FoundationModels)
    import FoundationModels
#endif

// MARK: - Plain structs (all iOS versions) for the exam UI

struct ExamQuestion {
    var question: String
    var options: [String]
    var correctAnswer: String
    var explanation: String
}

struct ExamQuestionPaper {
    var questions: [ExamQuestion]
}

// MARK: - @Generable structs (iOS 26+ only) for AI generation

@available(iOS 26.0, macOS 16.0, *)
@Generable
struct MCQ {
    var question: String
    @Guide(description: "Exactly 4 options.", .count(4))
    var options: [String]
    @Guide(
        description:
            "The exact text of the correct option. MUST uniquely match one item in `options`.")
    var correctAnswer: String
    var explanation: String
}

@available(iOS 26.0, macOS 16.0, *)
@Generable
struct ExamPaper {
    @Guide(description: "Exactly 10 multiple choice questions about OOP", .count(10))
    var questions: [MCQ]
}

// MARK: - Exam State

enum ExamState {
    case loading
    case testing
    case grading
    case scorecard
}

// MARK: - Hardcoded fallback questions

let fallbackQuestions: [ExamQuestion] = [
    ExamQuestion(
        question: "What does OOP stand for?",
        options: [
            "Object-Oriented Programming",
            "Open Output Processing",
            "Ordered Object Placement",
            "Optional Output Programming",
        ],
        correctAnswer: "Object-Oriented Programming",
        explanation:
            "OOP stands for Object-Oriented Programming, a style of coding that organizes software around objects."
    ),
    ExamQuestion(
        question: "In Swift, what keyword do you use to create a class?",
        options: ["struct", "func", "class", "var"],
        correctAnswer: "class",
        explanation: "The 'class' keyword is used to define a class in Swift."
    ),
    ExamQuestion(
        question: "Which of these is a real-world example of a Class and Object?",
        options: [
            "Car is an object, Toyota is the class",
            "Animal is a class, Dog is an object",
            "Swift is a class, Xcode is an object",
            "A loop is a class, a variable is an object",
        ],
        correctAnswer: "Animal is a class, Dog is an object",
        explanation:
            "A class is a blueprint (Animal), and an object is a specific instance created from it (Dog)."
    ),
    ExamQuestion(
        question: "What is an object in OOP?",
        options: [
            "A type of loop",
            "A keyword in Swift",
            "An instance created from a class",
            "A function that returns a value",
        ],
        correctAnswer: "An instance created from a class",
        explanation: "An object is created (instantiated) from a class blueprint."
    ),
    ExamQuestion(
        question:
            "Which OOP concept allows one class to inherit properties from another?",
        options: ["Encapsulation", "Abstraction", "Polymorphism", "Inheritance"],
        correctAnswer: "Inheritance",
        explanation:
            "Inheritance lets a child class reuse properties and methods from a parent class."
    ),
    ExamQuestion(
        question: "If class Dog inherits from class Animal, what is Animal called?",
        options: ["Child class", "Sub class", "Parent class", "Object class"],
        correctAnswer: "Parent class",
        explanation:
            "The class being inherited from is called the Parent (or Super) class, while Dog is the child class."
    ),
    ExamQuestion(
        question: "What does Encapsulation mean in OOP?",
        options: [
            "A class inheriting from another class",
            "Hiding an object's internal data and protecting it",
            "An object taking many forms",
            "Removing unwanted properties",
        ],
        correctAnswer: "Hiding an object's internal data and protecting it",
        explanation:
            "Encapsulation means bundling data inside a class and restricting direct access to it."
    ),
    ExamQuestion(
        question: "What does Abstraction help us do in OOP?",
        options: [
            "Copy one class into another",
            "Show all internal details of a class",
            "Hide unnecessary details and show only what is needed",
            "Create multiple objects at once",
        ],
        correctAnswer: "Hide unnecessary details and show only what is needed",
        explanation:
            "Abstraction hides complex implementation details and exposes only the essential features."
    ),
    ExamQuestion(
        question: "What is Polymorphism in simple terms?",
        options: [
            "A class that cannot be inherited",
            "The ability of different objects to respond to the same method differently",
            "Storing data inside a class",
            "Writing a function inside a loop",
        ],
        correctAnswer:
            "The ability of different objects to respond to the same method differently",
        explanation:
            "Polymorphism allows different classes to define their own version of the same method."
    ),
    ExamQuestion(
        question: "Which of the following is NOT one of the four pillars of OOP?",
        options: ["Encapsulation", "Inheritance", "Compilation", "Abstraction"],
        correctAnswer: "Compilation",
        explanation:
            "The four pillars of OOP are Encapsulation, Inheritance, Polymorphism, and Abstraction. Compilation is not one of them."
    ),
]

// MARK: - ExamHallView (works on ALL iOS versions)

struct ExamHallView: View {
    @ObservedObject var gameState: GameStateManager

    @State private var examState: ExamState = .loading
    @State private var paper: ExamQuestionPaper? = nil

    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int: String] = [:]

    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: Date())
    }

    var body: some View {
        ZStack {
            if examState == .loading {
                loadingView()
            } else {
                Image("woodedbg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .blur(radius: 10)

                Color.black.opacity(0.4).ignoresSafeArea()

                ZStack(alignment: .top) {

                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.7, green: 0.45, blue: 0.25))
                        .frame(maxWidth: 1100, maxHeight: 1100)
                        .shadow(radius: 10)

                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white)
                        .frame(maxWidth: 1020, maxHeight: 1020)
                        .padding(.top, 40)
                        .shadow(radius: 2)

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

                    VStack(spacing: 0) {
                        Text("EXAM: OOPS")
                            .font(.custom("AmericanTypewriter-Bold", size: 36))
                            .foregroundColor(.black)
                            .padding(.top, 55)
                            .padding(.bottom, 6)

                        if examState != .loading {
                            HStack {
                                Text("NAME: Tori")
                                Spacer()
                                Text("DATE: \(currentDate)")
                            }
                            .font(.custom("AmericanTypewriter", size: 20))
                            .foregroundColor(.black)
                            .padding(.horizontal, 50)
                            .padding(.bottom, 6)
                        }

                        switch examState {
                        case .loading:
                            EmptyView()
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
                    .frame(maxWidth: 1020, maxHeight: 1020)
                }
                .padding(.vertical, 40)
            }
        }
        .onAppear {
            generateExam()
        }
    }

    // MARK: - Generate Exam (AI or Fallback)

    private func generateExam() {
        if #available(iOS 26.0, macOS 16.0, *) {
            generateWithAI()
        } else {
            useFallbackQuestions()
        }
    }

    @available(iOS 26.0, macOS 16.0, *)
    private func generateWithAI() {
        Task {
            do {
                let session = LanguageModelSession()
                let prompt = """
                    Generate exactly 10 Easy multiple choice questions testing Object-Oriented Programming (OOP) in Swift.
                    Strictly limit the syllabus to: class objects, Inheritance, Polymorphism, Encapsulation, and Abstraction only and no SYNTAX QUESTIONS.
                    Make the questions beginner friendly. Ensure exactly 4 options per question. The correctAnswer MUST exactly match the text of one of the options.
                    """

                let response = try await session.respond(
                    to: prompt,
                    generating: ExamPaper.self
                )

                // Convert AI MCQs to plain ExamQuestions
                let questions = response.content.questions.map { mcq in
                    ExamQuestion(
                        question: mcq.question,
                        options: mcq.options,
                        correctAnswer: mcq.correctAnswer,
                        explanation: mcq.explanation
                    )
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.paper = ExamQuestionPaper(questions: questions)
                    withAnimation {
                        self.examState = .testing
                    }
                }
            } catch {
                // AI failed — use fallback
                useFallbackQuestions()
            }
        }
    }

    private func useFallbackQuestions() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.paper = ExamQuestionPaper(questions: fallbackQuestions)
            withAnimation {
                self.examState = .testing
            }
        }
    }

    // MARK: - Views

    @ViewBuilder
    private func loadingView() -> some View {
        ZStack {
            SpriteView(scene: getBusScene())
                .ignoresSafeArea()

            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)

                    Text("Arriving at School... Generating Exam...")
                        .font(.custom("AmericanTypewriter", size: 14))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.leading, 30)
                .padding(.bottom, 30)
            }
        }
    }

    private func getBusScene() -> BusScene {
        let scene = BusScene(size: CGSize(width: 1920, height: 1080))
        scene.scaleMode = .aspectFill
        return scene
    }

    @ViewBuilder
    private func testingView(paper: ExamQuestionPaper) -> some View {
        ScrollView(showsIndicators: true) {
            VStack(alignment: .leading, spacing: 50) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SECTION A: MULTIPLE CHOICE (10 Questions)")
                        .font(.custom("AmericanTypewriter-Bold", size: 28))
                        .foregroundColor(.black)

                    HStack {
                        Image(systemName: "chevron.up.chevron.down")
                        Text("Scroll down to view all questions")
                    }
                    .font(.custom("AmericanTypewriter", size: 18))
                    .foregroundColor(Color.gray)
                }
                .padding(.bottom, 10)

                ForEach(0..<10, id: \.self) { index in
                    let q = paper.questions[index]

                    VStack(alignment: .leading, spacing: 20) {
                        Text("\(index + 1). \(q.question)")
                            .font(.custom("AmericanTypewriter-Bold", size: 32))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)

                        VStack(alignment: .leading, spacing: 15) {
                            ForEach(0..<q.options.count, id: \.self) { optIndex in
                                optionButton(
                                    for: index, optIndex: optIndex, text: q.options[optIndex])
                            }
                        }
                        .padding(.leading, 30)
                    }
                }

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

    private func optionButton(for questionIndex: Int, optIndex: Int, text: String) -> some View {
        let isSelected = selectedAnswers[questionIndex] == text
        let labels = ["A", "B", "C", "D", "E"]
        let letter = optIndex < labels.count ? labels[optIndex] : "?"

        return Button(action: {
            selectedAnswers[questionIndex] = text
        }) {
            HStack(spacing: 15) {

                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 30, height: 30)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
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
            examState = .scorecard
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
    private func scorecardView(paper: ExamQuestionPaper) -> some View {
        let score = calculateScore(paper: paper)
        let pass = score >= 7

        VStack(spacing: 0) {
            Text(pass ? "EXAM PASSED!" : "EXAM FAILED")
                .font(.custom("AmericanTypewriter-Bold", size: 36))
                .foregroundColor(pass ? .green : .red)
                .rotationEffect(.degrees(-5))
                .padding(.bottom, 4)

            Text("Final Score: \(score) / 10")
                .font(.custom("AmericanTypewriter-Bold", size: 24))
                .foregroundColor(.black)
                .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<10, id: \.self) { i in
                        let q = paper.questions[i]
                        let userAns = selectedAnswers[i] ?? "None"
                        let isCorrect = userAns == q.correctAnswer

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Q\(i+1): \(q.question)")
                                .font(.custom("AmericanTypewriter-Bold", size: 20))
                                .foregroundColor(.black)

                            HStack {
                                Text("Your Answer: \(userAns)")
                                    .foregroundColor(isCorrect ? .blue : .red)
                                Text("| Correct: \(q.correctAnswer)")
                                    .foregroundColor(.green)
                            }
                            .font(.custom("AmericanTypewriter", size: 16))

                            if !isCorrect {
                                Text("Explanation: \(q.explanation)")
                                    .font(.custom("AmericanTypewriter", size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
            }

            Button(action: {
                gameState.quitToMainMenu()
            }) {
                Text("Return to Menu")
                    .font(.custom("AmericanTypewriter-Bold", size: 24))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top, 12)
        }
    }

    private func calculateScore(paper: ExamQuestionPaper) -> Int {
        var score = 0
        for i in 0..<10 {
            if selectedAnswers[i] == paper.questions[i].correctAnswer {
                score += 1
            }
        }
        return score
    }
}

#Preview {
    ExamHallView(gameState: GameStateManager())
}
