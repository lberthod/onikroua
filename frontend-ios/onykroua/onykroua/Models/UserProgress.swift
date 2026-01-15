import Foundation
import SwiftData

@Model
final class UserProgress {
    var currentLevel: String
    var currentXP: Int
    var totalXP: Int
    var wordsLearned: Int
    var wordsReviewed: Int
    var lessonsCompleted: Int
    var lastStudyDate: Date?
    var streak: Int
    var longestStreak: Int
    var createdAt: Date
    var updatedAt: Date
    
    var quizzesCompleted: Int
    var quizzesCorrect: Int
    var conversationsCompleted: Int
    var grammarRulesLearned: Int
    var verbsLearned: Int
    
    init(
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
        verbsLearned: Int = 0
    ) {
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
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var level: CEFRLevel {
        get { CEFRLevel.fromString(currentLevel) }
        set { currentLevel = newValue.rawValue }
    }
    
    var progressPercentage: Double {
        let required = Double(level.xpRequired)
        return min(Double(currentXP) / required, 1.0)
    }
    
    var xpToNextLevel: Int {
        return max(0, level.xpRequired - currentXP)
    }
    
    var quizSuccessRate: Double {
        guard quizzesCompleted > 0 else { return 0 }
        return Double(quizzesCorrect) / Double(quizzesCompleted)
    }
    
    func addXP(_ amount: Int) {
        currentXP += amount
        totalXP += amount
        updatedAt = Date()
        
        checkLevelUp()
    }
    
    func checkLevelUp() {
        while currentXP >= level.xpRequired, let nextLevel = level.nextLevel {
            currentXP -= level.xpRequired
            level = nextLevel
        }
    }
    
    func incrementStreak() {
        streak += 1
        if streak > longestStreak {
            longestStreak = streak
        }
        lastStudyDate = Date()
        updatedAt = Date()
    }
    
    func resetStreak() {
        streak = 0
        updatedAt = Date()
    }
    
    func checkAndUpdateStreak() {
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
    
    func recordWordLearned() {
        wordsLearned += 1
        addXP(10)
    }
    
    func recordWordReviewed() {
        wordsReviewed += 1
        addXP(5)
    }
    
    func recordLessonCompleted() {
        lessonsCompleted += 1
        addXP(20)
    }
    
    func recordQuizCompleted(correct: Int, total: Int) {
        quizzesCompleted += 1
        quizzesCorrect += correct
        
        let percentage = Double(correct) / Double(total)
        if percentage >= 0.8 {
            addXP(30)
        } else if percentage >= 0.6 {
            addXP(20)
        } else {
            addXP(10)
        }
    }
    
    func recordConversationCompleted() {
        conversationsCompleted += 1
        addXP(40)
    }
    
    func recordGrammarRuleLearned() {
        grammarRulesLearned += 1
        addXP(15)
    }
    
    func recordVerbLearned() {
        verbsLearned += 1
        addXP(20)
    }
}
