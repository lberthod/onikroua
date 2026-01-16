import Foundation
import SwiftData

@Model
public final class UserProgress {
    @Attribute(.unique) public var id: UUID
    public var currentLevel: String
    public var currentXP: Int
    public var totalXP: Int
    public var wordsLearned: Int
    public var wordsReviewed: Int
    public var lessonsCompleted: Int
    public var lastStudyDate: Date?
    public var streak: Int
    public var longestStreak: Int
    public var createdAt: Date
    public var updatedAt: Date
    
    public var quizzesCompleted: Int
    public var quizzesCorrect: Int
    public var conversationsCompleted: Int
    public var grammarRulesLearned: Int
    public var verbsLearned: Int
    public var studyTimeMinutes: Int
    public var sessionsCompleted: Int
    
    public var levelNumber: Int {
        // Logique simple pour calculer le numéro du niveau basé sur l'XP
        // Par exemple : Niveau 1 = 0-100 XP, Niveau 2 = 101-250 XP, etc.
        let xp = totalXP
        if xp < 100 { return 1 }
        if xp < 250 { return 2 }
        if xp < 500 { return 3 }
        if xp < 1000 { return 4 }
        if xp < 2000 { return 5 }
        return 6 + (xp - 2000) / 1000
    }
    
    public init(
        id: UUID = UUID(),
        currentLevel: String = CEFRLevel.a1.rawValue,
        currentXP: Int = 0,
        totalXP: Int = 0,
        wordsLearned: Int = 0,
        wordsReviewed: Int = 0,
        lessonsCompleted: Int = 0,
        lastStudyDate: Date? = nil,
        streak: Int = 0,
        longestStreak: Int = 0,
        quizzesCompleted: Int = 0,
        quizzesCorrect: Int = 0,
        conversationsCompleted: Int = 0,
        grammarRulesLearned: Int = 0,
        verbsLearned: Int = 0,
        studyTimeMinutes: Int = 0,
        sessionsCompleted: Int = 0
    ) {
        self.id = id
        self.currentLevel = currentLevel
        self.currentXP = currentXP
        self.totalXP = totalXP
        self.wordsLearned = wordsLearned
        self.wordsReviewed = wordsReviewed
        self.lessonsCompleted = lessonsCompleted
        self.lastStudyDate = lastStudyDate
        self.streak = streak
        self.longestStreak = longestStreak
        self.quizzesCompleted = quizzesCompleted
        self.quizzesCorrect = quizzesCorrect
        self.conversationsCompleted = conversationsCompleted
        self.grammarRulesLearned = grammarRulesLearned
        self.verbsLearned = verbsLearned
        self.studyTimeMinutes = studyTimeMinutes
        self.sessionsCompleted = sessionsCompleted
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    public var level: CEFRLevel {
        get { CEFRLevel.fromString(currentLevel) }
        set { currentLevel = newValue.rawValue }
    }
    
    public var progressPercentage: Double {
        let required = Double(level.xpRequired)
        return min(Double(currentXP) / required, 1.0)
    }
    
    public var xpToNextLevel: Int {
        return max(0, level.xpRequired - currentXP)
    }
    
    public var quizSuccessRate: Double {
        guard quizzesCompleted > 0 else { return 0 }
        return Double(quizzesCorrect) / Double(quizzesCompleted)
    }
    
    public func addXP(_ amount: Int) {
        currentXP += amount
        totalXP += amount
        updatedAt = Date()
        checkLevelUp()
    }
    
    public func checkLevelUp() {
        while currentXP >= level.xpRequired, let nextLevel = level.nextLevel {
            currentXP -= level.xpRequired
            level = nextLevel
        }
    }
    
    public func incrementStreak() {
        streak += 1
        if streak > longestStreak {
            longestStreak = streak
        }
        lastStudyDate = Date()
        updatedAt = Date()
    }
    
    public func resetStreak() {
        streak = 0
        updatedAt = Date()
    }
    
    public func checkAndUpdateStreak() {
        guard let lastDate = lastStudyDate else {
            incrementStreak()
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastStudy = calendar.startOfDay(for: lastDate)
        let daysDifference = calendar.dateComponents([.day], from: lastStudy, to: today).day ?? 0
        
        if daysDifference == 0 {
            return
        } else if daysDifference == 1 {
            incrementStreak()
        } else {
            resetStreak()
            incrementStreak()
        }
    }
    
    public func recordWordLearned() {
        wordsLearned += 1
        updatedAt = Date()
    }
    
    public func recordWordReviewed() {
        wordsReviewed += 1
        updatedAt = Date()
    }
    
    public func recordLessonCompleted() {
        lessonsCompleted += 1
        sessionsCompleted += 1
        updatedAt = Date()
    }
    
    public func recordQuizCompleted(correct: Int, total: Int) {
        quizzesCompleted += 1
        quizzesCorrect += correct
        sessionsCompleted += 1
        updatedAt = Date()
        let percentage = Double(correct) / Double(total)
        if percentage >= 0.8 {
            addXP(30)
        } else if percentage >= 0.6 {
            addXP(20)
        } else {
            addXP(10)
        }
    }
    
    public func recordConversationCompleted() {
        conversationsCompleted += 1
        sessionsCompleted += 1
        updatedAt = Date()
        addXP(40)
    }
    
    public func recordGrammarRuleLearned() {
        grammarRulesLearned += 1
        updatedAt = Date()
        addXP(15)
    }
    
    public func recordVerbLearned() {
        verbsLearned += 1
        updatedAt = Date()
        addXP(20)
    }
    
    public func recordStudyTime(minutes: Int) {
        studyTimeMinutes += minutes
        updatedAt = Date()
    }
}
