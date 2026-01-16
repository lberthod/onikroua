import Foundation
import SwiftData

// MARK: - Adaptive Review System

public class AdaptiveReviewSystem: ObservableObject {
    public static let shared = AdaptiveReviewSystem()
    
    @Published public var reviewQueue: [ReviewItem] = []
    @Published public var dailyReviewCount: Int = 0
    @Published public var reviewStreak: Int = 0
    
    private let modelContext: ModelContext?
    
    public init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    // MARK: - Review Item
    
    public struct ReviewItem: Identifiable, Codable {
        public let id: UUID
        public let type: ReviewType
        public let content: ReviewContent
        public var difficulty: DifficultyLevel
        public var lastReviewed: Date
        public var nextReview: Date
        public var reviewCount: Int
        public var correctCount: Int
        public var incorrectCount: Int
        public var easeFactor: Double
        public var interval: Int
        
        public enum ReviewType: String, Codable {
            case vocabulary
            case conjugation
            case grammar
            case conversation
        }
        
        public struct ReviewContent: Codable {
            public let question: String
            public let answer: String
            public let hint: String?
            public let example: String?
        }
        
        public enum DifficultyLevel: Int, Codable {
            case veryEasy = 1
            case easy = 2
            case medium = 3
            case hard = 4
            case veryHard = 5
            
            public var color: String {
                switch self {
                case .veryEasy: return "green"
                case .easy: return "blue"
                case .medium: return "yellow"
                case .hard: return "orange"
                case .veryHard: return "red"
                }
            }
            
            public var multiplier: Double {
                switch self {
                case .veryEasy: return 2.5
                case .easy: return 2.0
                case .medium: return 1.5
                case .hard: return 1.0
                case .veryHard: return 0.8
                }
            }
        }
        
        public init(type: ReviewType, content: ReviewContent, difficulty: DifficultyLevel = .medium) {
            self.id = UUID()
            self.type = type
            self.content = content
            self.difficulty = difficulty
            self.lastReviewed = Date()
            self.nextReview = Date()
            self.reviewCount = 0
            self.correctCount = 0
            self.incorrectCount = 0
            self.easeFactor = 2.5
            self.interval = 0
        }
        
        public var successRate: Double {
            guard reviewCount > 0 else { return 0 }
            return Double(correctCount) / Double(reviewCount)
        }
        
        public var isDueForReview: Bool {
            return nextReview <= Date()
        }
        
        public var mastery: MasteryLevel {
            if successRate >= 0.9 && reviewCount >= 10 {
                return .mastered
            } else if successRate >= 0.75 && reviewCount >= 5 {
                return .proficient
            } else if successRate >= 0.5 && reviewCount >= 3 {
                return .learning
            } else {
                return .new
            }
        }
        
        public enum MasteryLevel: String {
            case new = "Nouveau"
            case learning = "En apprentissage"
            case proficient = "Compétent"
            case mastered = "Maîtrisé"
            
            public var icon: String {
                switch self {
                case .new: return "🌱"
                case .learning: return "📚"
                case .proficient: return "⭐"
                case .mastered: return "🏆"
                }
            }
        }
    }
    
    // MARK: - Adaptive Algorithm (SuperMemo SM-2 Modified)
    
    public func calculateNextReview(item: ReviewItem, quality: Int) -> (interval: Int, easeFactor: Double, nextReview: Date) {
        var newEaseFactor = item.easeFactor
        var newInterval = item.interval
        
        // Update ease factor based on quality (0-5 scale)
        // 0-1: Again, 2: Hard, 3: Good, 4-5: Easy
        if quality >= 3 {
            newEaseFactor = item.easeFactor + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02))
        } else {
            newEaseFactor = max(1.3, item.easeFactor - 0.2)
        }
        
        newEaseFactor = max(1.3, min(2.5, newEaseFactor))
        
        // Calculate interval
        if quality < 3 {
            // Reset if answered incorrectly
            newInterval = 1
        } else {
            if item.interval == 0 {
                newInterval = 1
            } else if item.interval == 1 {
                newInterval = 6
            } else {
                newInterval = Int(Double(item.interval) * newEaseFactor)
            }
        }
        
        // Apply difficulty multiplier
        let difficultyMultiplier = item.difficulty.multiplier
        newInterval = Int(Double(newInterval) * difficultyMultiplier)
        
        // Calculate next review date
        let nextReview = Calendar.current.date(byAdding: .day, value: newInterval, to: Date()) ?? Date()
        
        return (newInterval, newEaseFactor, nextReview)
    }
    
    // MARK: - Review Item Management
    
    public func recordReview(item: inout ReviewItem, wasCorrect: Bool, difficulty: ReviewItem.DifficultyLevel? = nil) {
        item.reviewCount += 1
        item.lastReviewed = Date()
        
        if wasCorrect {
            item.correctCount += 1
        } else {
            item.incorrectCount += 1
        }
        
        if let difficulty = difficulty {
            item.difficulty = difficulty
        }
        
        // Calculate quality score (0-5)
        let quality: Int
        if wasCorrect {
            switch item.difficulty {
            case .veryEasy: quality = 5
            case .easy: quality = 4
            case .medium: quality = 3
            case .hard: quality = 2
            case .veryHard: quality = 1
            }
        } else {
            quality = 0
        }
        
        let result = calculateNextReview(item: item, quality: quality)
        item.interval = result.interval
        item.easeFactor = result.easeFactor
        item.nextReview = result.nextReview
    }
    
    // MARK: - Queue Management
    
    public func getDueItemsCount() -> Int {
        return reviewQueue.filter { $0.isDueForReview }.count
    }
    
    public func getUrgentItemsCount() -> Int {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        return reviewQueue.filter { $0.nextReview < twoDaysAgo }.count
    }
    
    public func getDueItems(limit: Int = 20) -> [ReviewItem] {
        return reviewQueue
            .filter { $0.isDueForReview }
            .sorted { item1, item2 in
                // Prioritize by: overdue time, then difficulty, then success rate
                if item1.nextReview != item2.nextReview {
                    return item1.nextReview < item2.nextReview
                }
                if item1.difficulty != item2.difficulty {
                    return item1.difficulty.rawValue > item2.difficulty.rawValue
                }
                return item1.successRate < item2.successRate
            }
            .prefix(limit)
            .map { $0 }
    }
    
    public func getNewItems(limit: Int = 10) -> [ReviewItem] {
        return reviewQueue
            .filter { $0.reviewCount == 0 }
            .shuffled()
            .prefix(limit)
            .map { $0 }
    }
    
    public func getLearningItems(limit: Int = 15) -> [ReviewItem] {
        return reviewQueue
            .filter { $0.mastery == .learning || $0.mastery == .new }
            .sorted { $0.successRate < $1.successRate }
            .prefix(limit)
            .map { $0 }
    }
    
    public func getWeakItems(limit: Int = 10) -> [ReviewItem] {
        return reviewQueue
            .filter { $0.reviewCount >= 3 && $0.successRate < 0.6 }
            .sorted { $0.successRate < $1.successRate }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Statistics
    
    public func getStatistics() -> ReviewStatistics {
        let totalItems = reviewQueue.count
        let dueItems = reviewQueue.filter { $0.isDueForReview }.count
        let masteredItems = reviewQueue.filter { $0.mastery == .mastered }.count
        let learningItems = reviewQueue.filter { $0.mastery == .learning }.count
        let newItems = reviewQueue.filter { $0.reviewCount == 0 }.count
        
        let totalReviews = reviewQueue.reduce(0) { $0 + $1.reviewCount }
        let totalCorrect = reviewQueue.reduce(0) { $0 + $1.correctCount }
        
        let averageSuccessRate = totalReviews > 0 ? Double(totalCorrect) / Double(totalReviews) : 0
        
        return ReviewStatistics(
            totalItems: totalItems,
            dueItems: dueItems,
            masteredItems: masteredItems,
            learningItems: learningItems,
            newItems: newItems,
            totalReviews: totalReviews,
            averageSuccessRate: averageSuccessRate,
            dailyReviewCount: dailyReviewCount,
            reviewStreak: reviewStreak
        )
    }
    
    public struct ReviewStatistics {
        public let totalItems: Int
        public let dueItems: Int
        public let masteredItems: Int
        public let learningItems: Int
        public let newItems: Int
        public let totalReviews: Int
        public let averageSuccessRate: Double
        public let dailyReviewCount: Int
        public let reviewStreak: Int
        
        public var progressPercentage: Double {
            guard totalItems > 0 else { return 0 }
            return Double(masteredItems) / Double(totalItems) * 100
        }
    }
    
    // MARK: - Data Generation
    
    public func generateReviewItemsFromVocabulary(language: String, limit: Int = 100) -> [ReviewItem] {
        let words = VocabularyDataManager.shared.getAllWords(language: language).shuffled().prefix(limit)
        
        return words.map { word in
            ReviewItem(
                type: .vocabulary,
                content: ReviewItem.ReviewContent(
                    question: word.word,
                    answer: word.translation,
                    hint: word.category,
                    example: word.example
                )
            )
        }
    }
    
    public func generateReviewItemsFromConjugation(language: String, limit: Int = 50) -> [ReviewItem] {
        let verbs = language == "it" ? VerbData.getItalianVerbs() : VerbData.getSpanishVerbs()
        let tenses = ["Présent", "Passé composé", "Futur"]
        let pronouns = ["io", "tu", "lui/lei", "noi", "voi", "loro"]
        
        var items: [ReviewItem] = []
        
        for verb in verbs.shuffled().prefix(limit / 6) {
            for _ in 0..<6 {
                guard let tense = tenses.randomElement(),
                      let pronoun = pronouns.randomElement(),
                      let conjugation = verb.conjugations[tense],
                      let form = conjugation[pronoun] else {
                    continue
                }
                
                items.append(ReviewItem(
                    type: .conjugation,
                    content: ReviewItem.ReviewContent(
                        question: "\(verb) - \(tense) - \(pronoun)",
                        answer: form,
                        hint: verb.translation,
                        example: "\(pronoun) \(form)"
                    )
                ))
            }
        }
        
        return items
    }
    
    public func generateReviewItemsFromGrammar(language: String, limit: Int = 30) -> [ReviewItem] {
        let grammarData = GrammarData()
        let rules = grammarData.getGrammarRules(language: language).shuffled().prefix(limit)
        
        return rules.compactMap { rule -> ReviewItem? in
            guard let example = rule.examples.randomElement() else { return nil }
            
            return ReviewItem(
                type: .grammar,
                content: ReviewItem.ReviewContent(
                    question: rule.title,
                    answer: example,
                    hint: rule.category,
                    example: rule.description
                )
            )
        }
    }
    
    // MARK: - Daily Review Session
    
    public func generateDailyReviewSession(targetCount: Int = 30) -> [ReviewItem] {
        var session: [ReviewItem] = []
        
        // 50% due items (high priority)
        let dueCount = Int(Double(targetCount) * 0.5)
        session.append(contentsOf: getDueItems(limit: dueCount))
        
        // 25% weak items (need reinforcement)
        let weakCount = Int(Double(targetCount) * 0.25)
        session.append(contentsOf: getWeakItems(limit: weakCount))
        
        // 15% new items (introduce new content)
        let newCount = Int(Double(targetCount) * 0.15)
        session.append(contentsOf: getNewItems(limit: newCount))
        
        // 10% random learning items (variety)
        let learningCount = targetCount - session.count
        session.append(contentsOf: getLearningItems(limit: learningCount))
        
        return session.shuffled()
    }
}

// MARK: - Leitner System (Alternative Algorithm)

class LeitnerSystem {
    static let boxIntervals = [1, 2, 4, 8, 16, 32] // days
    
    struct LeitnerCard {
        var item: AdaptiveReviewSystem.ReviewItem
        var box: Int = 0
        var lastReviewed: Date = Date()
        
        var nextReview: Date {
            let interval = LeitnerSystem.boxIntervals[box]
            return Calendar.current.date(byAdding: .day, value: interval, to: lastReviewed) ?? Date()
        }
        
        var isDue: Bool {
            return nextReview <= Date()
        }
        
        mutating func moveToNextBox() {
            box = min(box + 1, LeitnerSystem.boxIntervals.count - 1)
            lastReviewed = Date()
        }
        
        mutating func moveToFirstBox() {
            box = 0
            lastReviewed = Date()
        }
        
        mutating func recordAnswer(correct: Bool) {
            if correct {
                moveToNextBox()
            } else {
                moveToFirstBox()
            }
        }
    }
}
