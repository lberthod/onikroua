import SwiftUI

public struct PracticeTab: View {
    public let grammarData: GrammarData
    public let language: String
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedQuizType = "conjugation"
    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var userAnswer = ""
    @State private var quizStarted = false
    @State private var quizCompleted = false
    
    private var quizTypes = ["conjugation", "translation", "verb"]
    
    public init(grammarData: GrammarData, language: String) {
        self.grammarData = grammarData
        self.language = language
    }
    
    private var questions: [QuizQuestion] {
        generateQuestions()
    }
    
    private var currentQuizQuestion: QuizQuestion? {
        guard currentQuestion < questions.count else { return nil }
        return questions[currentQuestion]
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !quizStarted {
                    QuizStartView(
                        selectedQuizType: $selectedQuizType,
                        onStart: { 
                            quizStarted = true
                            currentQuestion = 0
                            score = 0
                            quizCompleted = false
                        }
                    )
                } else if quizCompleted {
                    QuizCompletedView(
                        score: score,
                        totalQuestions: questions.count,
                        onRestart: { 
                            quizStarted = false
                            currentQuestion = 0
                            score = 0
                            quizCompleted = false
                        }
                    )
                } else if let question = currentQuizQuestion {
                    QuizQuestionView(
                        question: question,
                        userAnswer: $userAnswer,
                        showResult: $showResult,
                        onNext: { 
                            if showResult {
                                nextQuestion()
                            } else {
                                checkAnswer()
                            }
                        },
                        speechService: env.speechService,
                        language: language
                    )
                }
            }
            .padding()
        }
    }
    
    private func generateQuestions() -> [QuizQuestion] {
        let verbs = grammarData.getVerbs(language: language)
        var questions: [QuizQuestion] = []
        
        switch selectedQuizType {
        case "conjugation":
            for verb in verbs.prefix(5) {
                if let conjugations = verb.conjugations["Présent"] {
                    for (pronoun, conjugation) in conjugations.prefix(3) {
                        questions.append(QuizQuestion(
                            question: "Conjuguez \(verb.verb) avec '\(pronoun)'",
                            correctAnswer: conjugation,
                            type: .conjugation,
                            verb: verb.verb,
                            pronoun: pronoun
                        ))
                    }
                }
            }
        case "translation":
            for verb in verbs.prefix(5) {
                questions.append(QuizQuestion(
                    question: "Traduire: \(verb.verb)",
                    correctAnswer: verb.translation,
                    type: .translation,
                    verb: verb.verb
                ))
            }
        case "verb":
            for verb in verbs.prefix(5) {
                questions.append(QuizQuestion(
                    question: "Quel est le verbe pour: \(verb.translation)?",
                    correctAnswer: verb.verb,
                    type: .verb,
                    verb: verb.verb
                ))
            }
        default:
            break
        }
        
        return questions.shuffled()
    }
    
    private func checkAnswer() {
        guard let question = currentQuizQuestion else { return }
        
        let isCorrect = userAnswer.lowercased().trimmingCharacters(in: .whitespaces) == 
                        question.correctAnswer.lowercased().trimmingCharacters(in: .whitespaces)
        
        if isCorrect {
            score += 1
        }
        
        showResult = true
    }
    
    private func nextQuestion() {
        userAnswer = ""
        showResult = false
        currentQuestion += 1
        
        if currentQuestion >= questions.count {
            quizCompleted = true
        }
    }
}

public struct QuizStartView: View {
    @Binding var selectedQuizType: String
    let onStart: () -> Void
    
    public var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("🎮 Mode Quiz")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Testez vos connaissances en conjugaison")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                QuizTypeButton(
                    title: "Conjugaison",
                    description: "Conjuguez des verbes",
                    isSelected: selectedQuizType == "conjugation"
                ) {
                    selectedQuizType = "conjugation"
                }
                
                QuizTypeButton(
                    title: "Traduction",
                    description: "Traduisez des verbes",
                    isSelected: selectedQuizType == "translation"
                ) {
                    selectedQuizType = "translation"
                }
                
                QuizTypeButton(
                    title: "Verbes",
                    description: "Trouvez le bon verbe",
                    isSelected: selectedQuizType == "verb"
                ) {
                    selectedQuizType = "verb"
                }
            }
            
            Button(action: onStart) {
                Text("Commencer le Quiz")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
    }
}

public struct QuizTypeButton: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

public struct QuizQuestionView: View {
    let question: QuizQuestion
    @Binding var userAnswer: String
    @Binding var showResult: Bool
    let onNext: () -> Void
    @ObservedObject var speechService: SpeechService
    let language: String
    
    public var isCorrect: Bool {
        userAnswer.lowercased().trimmingCharacters(in: .whitespaces) == 
        question.correctAnswer.lowercased().trimmingCharacters(in: .whitespaces)
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Progress Bar
            ProgressView(value: Double(question.id), total: 10)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            VStack(spacing: 16) {
                Text("Question \(question.id)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(question.question)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                if !showResult {
                    TextField("Votre réponse...", text: $userAnswer)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                }
            }
            
            if showResult {
                ResultView(isCorrect: isCorrect, correctAnswer: question.correctAnswer)
            }
            
            Button(action: onNext) {
                Text(showResult ? "Suivant" : "Vérifier")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(showResult ? Color.green : Color.blue)
                    .cornerRadius(12)
            }
            .disabled(!showResult && userAnswer.isEmpty)
        }
    }
}

public struct ResultView: View {
    let isCorrect: Bool
    let correctAnswer: String
    
    public var body: some View {
        HStack {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title)
                .foregroundColor(isCorrect ? .green : .red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isCorrect ? "Correct!" : "Incorrect")
                    .font(.headline)
                    .foregroundColor(isCorrect ? .green : .red)
                
                if !isCorrect {
                    Text("La bonne réponse: \(correctAnswer)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}

public struct QuizCompletedView: View {
    let score: Int
    let totalQuestions: Int
    let onRestart: () -> Void
    
    private var percentage: Double {
        Double(score) / Double(totalQuestions)
    }
    
    private var message: String {
        switch percentage {
        case 0.9...1.0: return "Excellent! 🎉"
        case 0.7..<0.9: return "Très bien! 👏"
        case 0.5..<0.7: return "Pas mal! 💪"
        default: return "Continuez à pratiquer! 📚"
        }
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Quiz Terminé!")
                .font(.title)
                .fontWeight(.bold)
            
            Text(message)
                .font(.title3)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("\(score) / \(totalQuestions)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("\(Int(percentage * 100))%")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onRestart) {
                Text("Recommencer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
    }
}

public struct QuizQuestion {
    let id: Int
    let question: String
    let correctAnswer: String
    let type: QuizType
    let verb: String?
    let pronoun: String?
    
    init(question: String, correctAnswer: String, type: QuizType, verb: String? = nil, pronoun: String? = nil) {
        self.id = Int.random(in: 1...10)
        self.question = question
        self.correctAnswer = correctAnswer
        self.type = type
        self.verb = verb
        self.pronoun = pronoun
    }
}

public enum QuizType {
    case conjugation
    case translation
    case verb
}
