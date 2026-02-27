import FoundationModels
import SwiftUI

@available(iOS 26.0, macOS 16.0, *)
struct AIDebugView: View {
    let onDismiss: () -> Void

    @State private var session = LanguageModelSession()
    @State private var isGenerating = false
    @State private var promptText: String = """
    Generate exactly 10 Easy multiple choice questions testing Object-Oriented Programming (OOP) in Swift.
    Strictly limit the syllabus to: class objects, Inheritance, Polymorphism, Encapsulation, and Abstraction only and no SYNTAX QUESTIONS.
    Make the questions beginner friendly. Ensure exactly 4 options per question. The correctAnswer MUST exactly match the text of one of the options.
    """
    @State private var outputText: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Output area (scrollable chat)
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {

                            // Empty state
                            if outputText.isEmpty && !isGenerating {
                                VStack(spacing: 12) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue.opacity(0.4))
                                    Text("Enter a prompt below and tap Run.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                            }

                            // AI output bubble
                            if !outputText.isEmpty {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 26, height: 26)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .padding(.top, 2)

                                    Text(outputText)
                                        .font(.system(size: 14))
                                        .foregroundColor(outputText.starts(with: "Error") ? .red : .primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.leading)
                                        .textSelection(.enabled)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(Color(.secondarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id("output")
                            }

                            // Typing indicator
                            if isGenerating {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 26, height: 26)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .padding(.top, 2)

                                    HStack(spacing: 5) {
                                        Circle().fill(Color.secondary.opacity(0.5)).frame(width: 7, height: 7)
                                        Circle().fill(Color.secondary.opacity(0.5)).frame(width: 7, height: 7)
                                        Circle().fill(Color.secondary.opacity(0.5)).frame(width: 7, height: 7)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id("typing")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: isGenerating) {
                        withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
                    }
                    .onChange(of: outputText) {
                        withAnimation { proxy.scrollTo("output", anchor: .bottom) }
                    }
                }

                Divider()

                // MARK: - Bottom input bar
                VStack(spacing: 10) {
                    TextEditor(text: $promptText)
                        .font(.system(size: 15))
                        .frame(minHeight: 80, maxHeight: 130)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Button(action: { generateQuestions() }) {
                        HStack(spacing: 6) {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 17))
                            }
                            Text(isGenerating ? "Generating..." : "Run Prompt")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            (isGenerating || promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                ? Color.blue.opacity(0.4)
                                : Color.blue
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .disabled(isGenerating || promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .animation(.easeInOut(duration: 0.15), value: isGenerating)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 16)
                .background(Color(.systemBackground))
            }
            .navigationTitle("AI Debugger")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", action: onDismiss)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func generateQuestions() {
        isGenerating = true
        outputText = ""

        Task {
            do {
                let response = try await session.respond(
                    to: promptText,
                    generating: ExamPaper.self
                )
                let paper = response.content

                var resultString = "Generated \(paper.questions.count) questions\n\n"
                for (index, q) in paper.questions.enumerated() {
                    resultString += "Q\(index + 1): \(q.question)\n"
                    for (optIndex, opt) in q.options.enumerated() {
                        let isCorrect = (opt == q.correctAnswer)
                        resultString += "  \(optIndex + 1). \(isCorrect ? "✅ " : "")\(opt)\n"
                    }
                    resultString += "💡 \(q.explanation)\n\n"
                }

                DispatchQueue.main.async {
                    self.outputText = resultString
                    self.isGenerating = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.outputText = "Error: \(error.localizedDescription)"
                    self.isGenerating = false
                }
            }
        }
    }
}