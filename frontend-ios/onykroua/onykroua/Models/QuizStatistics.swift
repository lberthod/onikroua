import Foundation
import SwiftData

@Model
class QuizStatistics {
    var id: UUID
    var userId: String
    var quizType: String
    var difficulty: String
    var score: Double
    var correctAnswers: Int
    var totalQuestions: Int
    var timeSpent: TimeInterval
    var date: Date
    var xpEarned: Int
    
    init(id: UUID = UUID(), userId: String, quizType: String, difficulty: String, score: Double, correctAnswers: Int, totalQuestions: Int, timeSpent: TimeInterval, date: Date = Date(), xpEarned: Int) {
        self.id = id
        self.userId = userId
        self.quizType = quizType
        self.difficulty = difficulty
        self.score = score
        self.correctAnswers = correctAnswers
        self.totalQuestions = totalQuestions
        self.timeSpent = timeSpent
        self.date = date
        self.xpEarned = xpEarned
    }
}

@Model
class QuizHistory {
    var id: UUID
    var userId: String
    var session: Data
    var date: Date
    
    init(id: UUID = UUID(), userId: String, session: Data, date: Date = Date()) {
        self.id = id
        self.userId = userId
        self.session = session
        self.date = date
    }
}

class QuizStatsManager {
    static func saveQuizResult(session: QuizSession, userId: String, modelContext: ModelContext) {
        let stats = QuizStatistics(
            userId: userId,
            quizType: session.type.rawValue,
            difficulty: session.difficulty.rawValue,
            score: session.score,
            correctAnswers: session.correctAnswersCount,
            totalQuestions: session.questions.count,
            timeSpent: session.endDate?.timeIntervalSince(session.startDate) ?? 0,
            xpEarned: session.xpEarned
        )
        
        modelContext.insert(stats)
        
        if let sessionData = try? JSONEncoder().encode(session) {
            let history = QuizHistory(userId: userId, session: sessionData)
            modelContext.insert(history)
        }
        
        try? modelContext.save()
    }
    
    static func getQuizStats(userId: String, modelContext: ModelContext) -> [QuizStatistics] {
        let descriptor = FetchDescriptor<QuizStatistics>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    static func getTotalQuizzes(userId: String, modelContext: ModelContext) -> Int {
        let stats = getQuizStats(userId: userId, modelContext: modelContext)
        return stats.count
    }
    
    static func getAverageScore(userId: String, modelContext: ModelContext) -> Double {
        let stats = getQuizStats(userId: userId, modelContext: modelContext)
        guard !stats.isEmpty else { return 0 }
        let total = stats.reduce(0.0) { $0 + $1.score }
        return total / Double(stats.count)
    }
    
    static func getCurrentStreak(userId: String, modelContext: ModelContext) -> Int {
        let stats = getQuizStats(userId: userId, modelContext: modelContext)
        guard !stats.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        for stat in stats {
            if calendar.isDate(stat.date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if calendar.isDate(stat.date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: currentDate)!) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}
