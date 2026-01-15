import Foundation
import SwiftUI

// MARK: - Quiz Types

enum QuizType: String, Codable, CaseIterable {
    case vocabulary = "Vocabulaire"
    case conjugation = "Conjugaison"
    case grammar = "Grammaire"
    case listening = "Écoute"
    case translation = "Traduction"
    case conversation = "Conversation"
    
    var icon: String {
        switch self {
        case .vocabulary: return "📚"
        case .conjugation: return "✏️"
        case .grammar: return "📖"
        case .listening: return "🎧"
        case .translation: return "🔄"
        case .conversation: return "💬"
        }
    }
    
    var color: Color {
        switch self {
        case .vocabulary: return .blue
        case .conjugation: return .green
        case .grammar: return .purple
        case .listening: return .orange
        case .translation: return .pink
        case .conversation: return .teal
        }
    }
}

enum QuizDifficulty: String, Codable, CaseIterable {
    case beginner = "Débutant"
    case intermediate = "Intermédiaire"
    case advanced = "Avancé"
    
    var cefrLevels: [CEFRLevel] {
        switch self {
        case .beginner: return [.A1, .A2]
        case .intermediate: return [.B1, .B2]
        case .advanced: return [.C1, .C2]
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "🌱"
        case .intermediate: return "🌿"
        case .advanced: return "🌳"
        }
    }
}

// MARK: - Quiz Question Models

struct QuizQuestion: Identifiable, Codable {
    let id: UUID
    let type: QuizType
    let difficulty: QuizDifficulty
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String?
    let imageURL: String?
    let audioURL: String?
    
    var correctAnswer: String {
        options[correctAnswerIndex]
    }
    
    init(id: UUID = UUID(), type: QuizType, difficulty: QuizDifficulty, 
         question: String, options: [String], correctAnswerIndex: Int,
         explanation: String? = nil, imageURL: String? = nil, audioURL: String? = nil) {
        self.id = id
        self.type = type
        self.difficulty = difficulty
        self.question = question
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
        self.imageURL = imageURL
        self.audioURL = audioURL
    }
}

// MARK: - Quiz Session

struct QuizSession: Identifiable, Codable {
    let id: UUID
    let type: QuizType
    let difficulty: QuizDifficulty
    let questions: [QuizQuestion]
    var currentQuestionIndex: Int
    var answers: [Int?]
    var startDate: Date
    var endDate: Date?
    
    var isCompleted: Bool {
        return currentQuestionIndex >= questions.count
    }
    
    var correctAnswersCount: Int {
        return answers.enumerated().filter { index, answer in
            guard let answer = answer else { return false }
            return answer == questions[index].correctAnswerIndex
        }.count
    }
    
    var score: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(correctAnswersCount) / Double(questions.count) * 100
    }
    
    var xpEarned: Int {
        let baseXP = 10
        let bonusXP = Int(score / 10) * 2
        return baseXP * correctAnswersCount + bonusXP
    }
    
    init(id: UUID = UUID(), type: QuizType, difficulty: QuizDifficulty, questions: [QuizQuestion]) {
        self.id = id
        self.type = type
        self.difficulty = difficulty
        self.questions = questions
        self.currentQuestionIndex = 0
        self.answers = Array(repeating: nil, count: questions.count)
        self.startDate = Date()
        self.endDate = nil
    }
    
    mutating func answerQuestion(answerIndex: Int) {
        guard currentQuestionIndex < questions.count else { return }
        answers[currentQuestionIndex] = answerIndex
        currentQuestionIndex += 1
        
        if isCompleted {
            endDate = Date()
        }
    }
}

// MARK: - Quiz Data Manager

class QuizDataManager: ObservableObject {
    static let shared = QuizDataManager()
    
    private init() {}
    
    // MARK: - Vocabulary Quizzes
    
    func generateVocabularyQuiz(difficulty: QuizDifficulty, language: String = "it", count: Int = 10) -> [QuizQuestion] {
        let allWords = VocabularyDataManager.shared.getAllWords(language: language)
        let shuffledWords = allWords.shuffled().prefix(count)
        
        return shuffledWords.map { word in
            // Obtenir 3 traductions incorrectes aléatoires
            let incorrectTranslations = allWords
                .filter { $0.translation != word.translation }
                .map { $0.translation }
                .shuffled()
                .prefix(3)
            
            var options = Array(incorrectTranslations) + [word.translation]
            options.shuffle()
            
            let correctIndex = options.firstIndex(of: word.translation) ?? 0
            
            return QuizQuestion(
                type: .vocabulary,
                difficulty: difficulty,
                question: "Que signifie \"\(word.word)\" en français ?",
                options: options,
                correctAnswerIndex: correctIndex,
                explanation: word.example != nil ? "\(word.example!) - \(word.exampleTranslation ?? "")" : nil
            )
        }
    }
    
    // MARK: - Conjugation Quizzes
    
    func generateConjugationQuiz(difficulty: QuizDifficulty, language: String = "it", count: Int = 10) -> [QuizQuestion] {
        let verbs = language == "it" ? VerbData.getItalianVerbs() : VerbData.getSpanishVerbs()
        let shuffledVerbs = verbs.shuffled().prefix(count)
        
        let tenses = ["Présent", "Passé composé", "Futur"]
        let pronouns = ["io", "tu", "lui/lei", "noi", "voi", "loro"]
        
        return shuffledVerbs.map { verb in
            let tense = tenses.randomElement() ?? "Présent"
            let pronoun = pronouns.randomElement() ?? "io"
            
            guard let conjugation = verb.conjugations[tense],
                  let correctForm = conjugation[pronoun] else {
                return QuizQuestion(
                    type: .conjugation,
                    difficulty: difficulty,
                    question: "Erreur de génération",
                    options: ["N/A"],
                    correctAnswerIndex: 0
                )
            }
            
            // Générer des options incorrectes
            var options = [correctForm]
            
            // Ajouter d'autres formes du même verbe
            conjugation.values.prefix(2).forEach { form in
                if form != correctForm && !options.contains(form) {
                    options.append(form)
                }
            }
            
            // Compléter avec d'autres verbes si nécessaire
            while options.count < 4 {
                if let randomVerb = verbs.randomElement(),
                   let randomConjugation = randomVerb.conjugations[tense],
                   let randomForm = randomConjugation[pronoun],
                   !options.contains(randomForm) {
                    options.append(randomForm)
                }
            }
            
            options.shuffle()
            let correctIndex = options.firstIndex(of: correctForm) ?? 0
            
            return QuizQuestion(
                type: .conjugation,
                difficulty: difficulty,
                question: "Conjugue \"\(verb.infinitive)\" au \(tense) avec \"\(pronoun)\"",
                options: options,
                correctAnswerIndex: correctIndex,
                explanation: "\(verb.infinitive) (\(verb.translation))"
            )
        }
    }
    
    // MARK: - Grammar Quizzes
    
    func generateGrammarQuiz(difficulty: QuizDifficulty, language: String = "it", count: Int = 10) -> [QuizQuestion] {
        let rules = GrammarData.getGrammarRules(for: language)
        let shuffledRules = rules.shuffled().prefix(count)
        
        return shuffledRules.compactMap { rule in
            guard rule.examples.count >= 2 else { return nil }
            
            let correctExample = rule.examples.randomElement() ?? ""
            
            // Générer des exemples incorrects basés sur d'autres règles
            let incorrectExamples = rules
                .filter { $0.title != rule.title }
                .flatMap { $0.examples }
                .shuffled()
                .prefix(3)
            
            var options = Array(incorrectExamples) + [correctExample]
            options.shuffle()
            
            let correctIndex = options.firstIndex(of: correctExample) ?? 0
            
            return QuizQuestion(
                type: .grammar,
                difficulty: difficulty,
                question: "Quel exemple illustre la règle : \"\(rule.title)\" ?",
                options: options,
                correctAnswerIndex: correctIndex,
                explanation: rule.description
            )
        }
    }
    
    // MARK: - Translation Quizzes
    
    func generateTranslationQuiz(difficulty: QuizDifficulty, language: String = "it", count: Int = 10) -> [QuizQuestion] {
        let scenarios = ConversationData.getScenarios(for: language)
        let allMessages = scenarios.flatMap { $0.messages }
        let shuffledMessages = allMessages.shuffled().prefix(count)
        
        return shuffledMessages.map { message in
            // Générer des traductions incorrectes
            let incorrectTranslations = allMessages
                .filter { $0.translation != message.translation }
                .map { $0.translation }
                .shuffled()
                .prefix(3)
            
            var options = Array(incorrectTranslations) + [message.translation]
            options.shuffle()
            
            let correctIndex = options.firstIndex(of: message.translation) ?? 0
            
            return QuizQuestion(
                type: .translation,
                difficulty: difficulty,
                question: "Traduis : \"\(message.text)\"",
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    // MARK: - Conversation Quizzes
    
    func generateConversationQuiz(difficulty: QuizDifficulty, language: String = "it", count: Int = 10) -> [QuizQuestion] {
        let scenarios = ConversationData.getScenarios(for: language)
        let questions = scenarios.prefix(count).compactMap { scenario -> QuizQuestion? in
            guard scenario.messages.count >= 2 else { return nil }
            
            let messages = scenario.messages
            let questionMessage = messages[0]
            let correctResponse = messages[1].text
            
            // Générer des réponses incorrectes
            let incorrectResponses = scenarios
                .filter { $0.id != scenario.id }
                .flatMap { $0.messages }
                .filter { $0.speaker != questionMessage.speaker }
                .map { $0.text }
                .shuffled()
                .prefix(3)
            
            var options = Array(incorrectResponses) + [correctResponse]
            options.shuffle()
            
            let correctIndex = options.firstIndex(of: correctResponse) ?? 0
            
            return QuizQuestion(
                type: .conversation,
                difficulty: difficulty,
                question: "Dans le contexte \"\(scenario.title)\", que répondre à :\n\"\(questionMessage.text)\" ?",
                options: options,
                correctAnswerIndex: correctIndex,
                explanation: "Traduction : \(messages[1].translation)"
            )
        }
        
        return Array(questions)
    }
    
    // MARK: - Generate Mixed Quiz
    
    func generateMixedQuiz(difficulty: QuizDifficulty, language: String = "it", count: Int = 10) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        let vocabCount = count / 3
        let conjugationCount = count / 3
        let grammarCount = count - vocabCount - conjugationCount
        
        questions.append(contentsOf: generateVocabularyQuiz(difficulty: difficulty, language: language, count: vocabCount))
        questions.append(contentsOf: generateConjugationQuiz(difficulty: difficulty, language: language, count: conjugationCount))
        questions.append(contentsOf: generateGrammarQuiz(difficulty: difficulty, language: language, count: grammarCount))
        
        return questions.shuffled()
    }
}
