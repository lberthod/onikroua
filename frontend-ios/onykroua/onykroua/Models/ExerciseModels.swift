import Foundation
import SwiftUI

// MARK: - Exercise Types

enum ExerciseType: String, Codable, CaseIterable {
    case flashcard = "Flashcards"
    case fillInTheBlank = "Texte à trous"
    case matching = "Associations"
    case listening = "Écoute"
    case pronunciation = "Prononciation"
    case dictation = "Dictée"
    
    var icon: String {
        switch self {
        case .flashcard: return "rectangle.stack.fill"
        case .fillInTheBlank: return "doc.text.fill"
        case .matching: return "link"
        case .listening: return "ear.fill"
        case .pronunciation: return "waveform"
        case .dictation: return "pencil.and.outline"
        }
    }
    
    var color: Color {
        switch self {
        case .flashcard: return .blue
        case .fillInTheBlank: return .green
        case .matching: return .purple
        case .listening: return .orange
        case .pronunciation: return .pink
        case .dictation: return .teal
        }
    }
    
    var description: String {
        switch self {
        case .flashcard: return "Mémorise le vocabulaire avec des cartes"
        case .fillInTheBlank: return "Complete les phrases avec les mots corrects"
        case .matching: return "Associe les mots à leur traduction"
        case .listening: return "Écoute et comprends les phrases"
        case .pronunciation: return "Pratique ta prononciation"
        case .dictation: return "Écris ce que tu entends"
        }
    }
}

// MARK: - Flashcard Models

struct Flashcard: Identifiable, Codable {
    let id: UUID
    let front: String
    let back: String
    let imageURL: String?
    let audioURL: String?
    let example: String?
    let category: String?
    
    init(id: UUID = UUID(), front: String, back: String, 
         imageURL: String? = nil, audioURL: String? = nil,
         example: String? = nil, category: String? = nil) {
        self.id = id
        self.front = front
        self.back = back
        self.imageURL = imageURL
        self.audioURL = audioURL
        self.example = example
        self.category = category
    }
}

struct FlashcardDeck: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let cards: [Flashcard]
    let category: String?
    let difficulty: QuizDifficulty
    
    init(id: UUID = UUID(), title: String, description: String, 
         icon: String, cards: [Flashcard], category: String? = nil,
         difficulty: QuizDifficulty = .beginner) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.cards = cards
        self.category = category
        self.difficulty = difficulty
    }
}

// MARK: - Fill in the Blank Exercise

struct FillInTheBlankExercise: Identifiable, Codable {
    let id: UUID
    let sentence: String
    let missingWord: String
    let missingWordIndex: Int
    let options: [String]
    let translation: String?
    let difficulty: QuizDifficulty
    
    var sentenceWithBlank: String {
        let words = sentence.components(separatedBy: " ")
        var result = words
        if missingWordIndex < words.count {
            result[missingWordIndex] = "_____"
        }
        return result.joined(separator: " ")
    }
    
    init(id: UUID = UUID(), sentence: String, missingWord: String,
         missingWordIndex: Int, options: [String], translation: String? = nil,
         difficulty: QuizDifficulty = .beginner) {
        self.id = id
        self.sentence = sentence
        self.missingWord = missingWord
        self.missingWordIndex = missingWordIndex
        self.options = options
        self.translation = translation
        self.difficulty = difficulty
    }
}

// MARK: - Matching Exercise

struct MatchingPair: Identifiable, Codable {
    let id: UUID
    let left: String
    let right: String
    let category: String?
    
    init(id: UUID = UUID(), left: String, right: String, category: String? = nil) {
        self.id = id
        self.left = left
        self.right = right
        self.category = category
    }
}

struct MatchingExercise: Identifiable, Codable {
    let id: UUID
    let title: String
    let pairs: [MatchingPair]
    let difficulty: QuizDifficulty
    
    init(id: UUID = UUID(), title: String, pairs: [MatchingPair],
         difficulty: QuizDifficulty = .beginner) {
        self.id = id
        self.title = title
        self.pairs = pairs
        self.difficulty = difficulty
    }
}

// MARK: - Exercise Session

struct ExerciseSession: Identifiable, Codable {
    let id: UUID
    let type: ExerciseType
    var currentIndex: Int
    var correctCount: Int
    var incorrectCount: Int
    var startDate: Date
    var endDate: Date?
    
    var totalAttempts: Int {
        correctCount + incorrectCount
    }
    
    var successRate: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctCount) / Double(totalAttempts) * 100
    }
    
    var xpEarned: Int {
        return correctCount * 5
    }
    
    init(id: UUID = UUID(), type: ExerciseType) {
        self.id = id
        self.type = type
        self.currentIndex = 0
        self.correctCount = 0
        self.incorrectCount = 0
        self.startDate = Date()
        self.endDate = nil
    }
    
    mutating func recordAnswer(isCorrect: Bool) {
        if isCorrect {
            correctCount += 1
        } else {
            incorrectCount += 1
        }
    }
    
    mutating func complete() {
        endDate = Date()
    }
}

// MARK: - Exercise Data Manager

class ExerciseDataManager: ObservableObject {
    static let shared = ExerciseDataManager()
    
    private init() {}
    
    // MARK: - Flashcard Generation
    
    func generateFlashcardDeck(from words: [VocabWord], title: String, difficulty: QuizDifficulty) -> FlashcardDeck {
        let cards = words.map { word in
            Flashcard(
                front: word.word,
                back: word.translation,
                example: word.example,
                category: word.category
            )
        }
        
        return FlashcardDeck(
            title: title,
            description: "\(cards.count) cartes de vocabulaire",
            icon: "📚",
            cards: cards,
            difficulty: difficulty
        )
    }
    
    func generateVocabularyFlashcards(language: String, category: String? = nil, limit: Int = 20) -> FlashcardDeck {
        var words = VocabularyDataManager.shared.getAllWords(language: language)
        
        if let category = category {
            words = words.filter { $0.category == category }
        }
        
        let selectedWords = Array(words.shuffled().prefix(limit))
        
        return generateFlashcardDeck(
            from: selectedWords,
            title: category ?? "Vocabulaire général",
            difficulty: .beginner
        )
    }
    
    func generateConjugationFlashcards(language: String, limit: Int = 15) -> FlashcardDeck {
        let verbs = language == "it" ? VerbData.getItalianVerbs() : VerbData.getSpanishVerbs()
        let selectedVerbs = Array(verbs.shuffled().prefix(limit))
        let tenses = ["Présent", "Passé composé", "Futur"]
        let pronouns = ["io", "tu", "lui/lei"]
        
        let cards = selectedVerbs.compactMap { verb -> Flashcard? in
            guard let tense = tenses.randomElement(),
                  let pronoun = pronouns.randomElement(),
                  let conjugation = verb.conjugations[tense],
                  let form = conjugation[pronoun] else {
                return nil
            }
            
            return Flashcard(
                front: "\(verb.infinitive) - \(tense) - \(pronoun)",
                back: form,
                example: "\(pronoun) \(form)",
                category: "Conjugaison"
            )
        }
        
        return FlashcardDeck(
            title: "Conjugaison",
            description: "\(cards.count) verbes à conjuguer",
            icon: "✏️",
            cards: cards,
            difficulty: .intermediate
        )
    }
    
    // MARK: - Fill in the Blank Generation
    
    func generateFillInTheBlankExercises(language: String, count: Int = 10) -> [FillInTheBlankExercise] {
        let scenarios = ConversationData.getScenarios(for: language)
        let messages = scenarios.flatMap { $0.messages }
        let shuffled = messages.shuffled().prefix(count)
        
        return shuffled.compactMap { message -> FillInTheBlankExercise? in
            let words = message.text.components(separatedBy: " ")
            guard words.count >= 3 else { return nil }
            
            let randomIndex = Int.random(in: 0..<words.count)
            let missingWord = words[randomIndex]
            
            // Generate incorrect options
            let allWords = messages.flatMap { $0.text.components(separatedBy: " ") }
            let incorrectOptions = allWords
                .filter { $0 != missingWord && $0.count > 2 }
                .shuffled()
                .prefix(3)
            
            var options = Array(incorrectOptions) + [missingWord]
            options.shuffle()
            
            return FillInTheBlankExercise(
                sentence: message.text,
                missingWord: missingWord,
                missingWordIndex: randomIndex,
                options: options,
                translation: message.translation,
                difficulty: .beginner
            )
        }
    }
    
    // MARK: - Matching Exercise Generation
    
    func generateMatchingExercise(language: String, count: Int = 8) -> MatchingExercise {
        let words = VocabularyDataManager.shared.getAllWords(language: language)
        let selectedWords = Array(words.shuffled().prefix(count))
        
        let pairs = selectedWords.map { word in
            MatchingPair(
                left: word.word,
                right: word.translation,
                category: word.category
            )
        }
        
        return MatchingExercise(
            title: "Associe les mots",
            pairs: pairs,
            difficulty: .beginner
        )
    }
    
    func generateConjugationMatching(language: String, count: Int = 6) -> MatchingExercise {
        let verbs = language == "it" ? VerbData.getItalianVerbs() : VerbData.getSpanishVerbs()
        let selectedVerbs = Array(verbs.shuffled().prefix(count))
        let tense = "Présent"
        let pronoun = "io"
        
        let pairs = selectedVerbs.compactMap { verb -> MatchingPair? in
            guard let conjugation = verb.conjugations[tense],
                  let form = conjugation[pronoun] else {
                return nil
            }
            
            return MatchingPair(
                left: verb.infinitive,
                right: form,
                category: "Conjugaison"
            )
        }
        
        return MatchingExercise(
            title: "Associe les verbes conjugués",
            pairs: pairs,
            difficulty: .intermediate
        )
    }
    
    // MARK: - Daily Practice Generation
    
    func generateDailyPractice(language: String) -> [Any] {
        var exercises: [Any] = []
        
        // 1 deck de flashcards vocabulaire
        exercises.append(generateVocabularyFlashcards(language: language, limit: 15))
        
        // 1 deck de flashcards conjugaison
        exercises.append(generateConjugationFlashcards(language: language, limit: 10))
        
        // 5 exercices texte à trous
        exercises.append(contentsOf: generateFillInTheBlankExercises(language: language, count: 5))
        
        // 2 exercices d'associations
        exercises.append(generateMatchingExercise(language: language, count: 8))
        exercises.append(generateConjugationMatching(language: language, count: 6))
        
        return exercises
    }
}

// MARK: - Spaced Repetition System (SRS)

enum SRSInterval: Int, Codable {
    case new = 0
    case learning = 1
    case review1 = 3
    case review2 = 7
    case review3 = 14
    case review4 = 30
    case review5 = 90
    case mastered = 180
    
    var nextInterval: SRSInterval? {
        switch self {
        case .new: return .learning
        case .learning: return .review1
        case .review1: return .review2
        case .review2: return .review3
        case .review3: return .review4
        case .review4: return .review5
        case .review5: return .mastered
        case .mastered: return nil
        }
    }
    
    var previousInterval: SRSInterval? {
        switch self {
        case .new: return nil
        case .learning: return .new
        case .review1: return .learning
        case .review2: return .review1
        case .review3: return .review2
        case .review4: return .review3
        case .review5: return .review4
        case .mastered: return .review5
        }
    }
}

struct SRSCard: Identifiable, Codable {
    let id: UUID
    let flashcard: Flashcard
    var interval: SRSInterval
    var nextReviewDate: Date
    var easeFactor: Double
    var reviewCount: Int
    
    init(flashcard: Flashcard) {
        self.id = UUID()
        self.flashcard = flashcard
        self.interval = .new
        self.nextReviewDate = Date()
        self.easeFactor = 2.5
        self.reviewCount = 0
    }
    
    mutating func recordReview(quality: Int) {
        reviewCount += 1
        
        // Update ease factor
        easeFactor = max(1.3, easeFactor + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02)))
        
        // Update interval based on quality
        if quality >= 3 {
            if let next = interval.nextInterval {
                interval = next
            }
        } else {
            if let previous = interval.previousInterval {
                interval = previous
            }
        }
        
        // Calculate next review date
        let days = Double(interval.rawValue) * easeFactor
        nextReviewDate = Calendar.current.date(byAdding: .day, value: Int(days), to: Date()) ?? Date()
    }
    
    var isDueForReview: Bool {
        return nextReviewDate <= Date()
    }
}
