import Foundation
import SwiftUI

// MARK: - Quiz Types

public enum QuizType: String, Codable, CaseIterable {
    case vocabulary = "Vocabulaire"
    case conjugation = "Conjugaison"
    case grammar = "Grammaire"
    case translation = "Traduction"
    case conversation = "Conversation"
    case listening = "Écoute"
    case mixed = "Mixte"
    
    public var icon: String {
        switch self {
        case .vocabulary: return "book.fill"
        case .conjugation: return "text.alignleft"
        case .grammar: return "text.book.closed.fill"
        case .translation: return "character.bubble.fill"
        case .conversation: return "bubble.left.and.bubble.right.fill"
        case .listening: return "ear"
        case .mixed: return "shuffle"
        }
    }
    
    public var color: Color {
        switch self {
        case .vocabulary: return .blue
        case .conjugation: return .green
        case .grammar: return .purple
        case .translation: return .orange
        case .conversation: return .pink
        case .listening: return .cyan
        case .mixed: return .indigo
        }
    }
}

public enum QuizDifficulty: String, Codable, CaseIterable {
    case beginner = "Débutant"
    case intermediate = "Intermédiaire"
    case advanced = "Avancé"
    
    var cefrLevels: [CEFRLevel] {
        switch self {
        case .beginner: return [.a1, .a2]
        case .intermediate: return [.b1, .b2]
        case .advanced: return [.c1, .c2]
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

public struct QuizQuestion: Identifiable, Codable {
    public let id: UUID
    public let type: QuizType
    public let difficulty: QuizDifficulty
    public let question: String
    public let options: [String]
    public let correctAnswerIndex: Int
    public let explanation: String?
    public let imageURL: String?
    public let audioURL: String?
    
    public var correctAnswer: String {
        options[correctAnswerIndex]
    }
    
    public init(id: UUID = UUID(), type: QuizType, difficulty: QuizDifficulty, question: String, options: [String], correctAnswerIndex: Int, explanation: String? = nil, imageURL: String? = nil, audioURL: String? = nil) {
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

public struct QuizSession: Identifiable, Codable {
    public let id: UUID
    public let type: QuizType
    public let difficulty: QuizDifficulty
    public let questions: [QuizQuestion]
    public var currentQuestionIndex: Int
    public var answers: [Int?]
    public var startDate: Date
    public var endDate: Date?
    
    public init(id: UUID = UUID(), type: QuizType, difficulty: QuizDifficulty, questions: [QuizQuestion], currentQuestionIndex: Int = 0, answers: [Int?] = [], startDate: Date = Date()) {
        self.id = id
        self.type = type
        self.difficulty = difficulty
        self.questions = questions
        self.currentQuestionIndex = currentQuestionIndex
        self.answers = answers
        self.startDate = startDate
    }
    
    public var isCompleted: Bool {
        return currentQuestionIndex >= questions.count
    }
    
    public var correctAnswersCount: Int {
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
        
        return shuffledVerbs.compactMap { verb -> QuizQuestion? in
            let tense = tenses.randomElement() ?? "Présent"
            let pronoun = pronouns.randomElement() ?? "io"
            
            guard let conjugation = verb.conjugations[tense],
                  let correctForm = conjugation[pronoun] else {
                return nil
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
                question: "Conjugue \"\(verb.verb)\" au \(tense) avec \"\(pronoun)\"",
                options: options,
                correctAnswerIndex: correctIndex,
                explanation: "\(verb.verb) (\(verb.translation))"
            )
        }
    }
    
    // MARK: - Grammar Quizzes
    
    func generateGrammarQuiz(difficulty: QuizDifficulty, language: String = "it", count: Int = 10) -> [QuizQuestion] {
        let grammarData = GrammarData()
        let rules = grammarData.getGrammarRules(language: language)
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
        
        return shuffledMessages.compactMap { message -> QuizQuestion? in
            // Générer des traductions incorrectes
            let incorrectTranslations = allMessages
                .filter { $0.translation != message.translation }
                .map { $0.translation }
                .shuffled()
                .prefix(3)
            
            var options = Array(incorrectTranslations) + [message.translation]
            options.shuffle()
            
            guard let correctIndex = options.firstIndex(of: message.translation) else { return nil }
            
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
                .map { $0.text }
                .shuffled()
                .prefix(3)
            
            var options = Array(incorrectResponses) + [correctResponse]
            options.shuffle()
            
            let correctIndex = options.firstIndex(of: correctResponse) ?? 0
            
            return QuizQuestion(
                type: .conversation,
                difficulty: difficulty,
                question: "Dans le contexte \"\(scenario.name)\", que répondre à :\n\"\(questionMessage.text)\" ?",
                options: options,
                correctAnswerIndex: correctIndex,
                explanation: "Traduction : \(messages[1].translation)"
            )
        }
        
        return Array(questions).compactMap { $0 }
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
