import Foundation
import SwiftData

struct WeeklyStats {
    let xpGained: Int
    let studyTimeMinutes: Int
    let wordsLearned: Int
    let lessonsCompleted: Int
    let daysStudied: Int
}

struct DailyXPData: Identifiable {
    let id = UUID()
    let date: Date
    let xp: Int
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

@Observable
final class AnalyticsService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getWeeklyStats(progress: UserProgress) -> WeeklyStats {
        return WeeklyStats(
            xpGained: progress.currentXP,
            studyTimeMinutes: progress.lessonsCompleted * 5,
            wordsLearned: progress.wordsLearned,
            lessonsCompleted: progress.lessonsCompleted,
            daysStudied: min(progress.streak, 7)
        )
    }
    
    func getLast7DaysXP(progress: UserProgress) -> [DailyXPData] {
        var data: [DailyXPData] = []
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            let xp = i <= progress.streak ? Int.random(in: 50...150) : 0
            data.append(DailyXPData(date: date, xp: xp))
        }
        
        return data.reversed()
    }
    
    func getRetentionRate(progress: UserProgress) -> Double {
        guard let lastStudyDate = progress.lastStudyDate else { return 0 }
        
        let daysSinceLastStudy = Calendar.current.dateComponents([.day], from: lastStudyDate, to: Date()).day ?? 0
        
        if daysSinceLastStudy == 0 {
            return 1.0
        } else if daysSinceLastStudy <= 7 {
            return Double(7 - daysSinceLastStudy) / 7.0
        } else {
            return 0.0
        }
    }
    
    func predictLevelUpDate(progress: UserProgress) -> Date? {
        guard progress.currentXP > 0 else { return nil }
        
        let xpNeeded = progress.xpToNextLevel
        let dailyAverageXP = Double(progress.totalXP) / max(Double(progress.streak), 1.0)
        
        guard dailyAverageXP > 0 else { return nil }
        
        let daysNeeded = Int(ceil(Double(xpNeeded) / dailyAverageXP))
        
        return Calendar.current.date(byAdding: .day, value: daysNeeded, to: Date())
    }
    
    func identifyWeakCategories(progress: UserProgress) -> [String] {
        var weakCategories: [String] = []
        
        if progress.wordsLearned < 100 {
            weakCategories.append("Vocabulaire")
        }
        
        if progress.verbsLearned < 20 {
            weakCategories.append("Conjugaison")
        }
        
        if progress.grammarRulesLearned < 10 {
            weakCategories.append("Grammaire")
        }
        
        if progress.conversationsCompleted < 5 {
            weakCategories.append("Conversation")
        }
        
        if progress.quizSuccessRate < 0.7 {
            weakCategories.append("Quiz")
        }
        
        return weakCategories
    }
    
    func generatePersonalizedRecommendations(progress: UserProgress) -> [String] {
        var recommendations: [String] = []
        
        if progress.streak < 7 {
            recommendations.append("🔥 Essaie d'étudier tous les jours pour créer une habitude")
        }
        
        if progress.wordsLearned < progress.level.estimatedWordsToKnow {
            let wordsNeeded = progress.level.estimatedWordsToKnow - progress.wordsLearned
            recommendations.append("📚 Apprends encore \(wordsNeeded) mots pour ton niveau")
        }
        
        if progress.conversationsCompleted < 5 {
            recommendations.append("🗣️ Pratique plus de conversations pour améliorer ta fluidité")
        }
        
        if progress.quizSuccessRate < 0.8 && progress.quizzesCompleted > 5 {
            recommendations.append("📖 Révise tes leçons précédentes pour améliorer ton score")
        }
        
        if progress.grammarRulesLearned < 20 {
            recommendations.append("✍️ Explore plus de règles de grammaire pour progresser")
        }
        
        if progress.verbsLearned < 30 {
            recommendations.append("🔄 Apprends plus de conjugaisons verbales")
        }
        
        if recommendations.isEmpty {
            recommendations.append("🌟 Continue comme ça, tu progresses très bien !")
        }
        
        return recommendations
    }
    
    func compareToAverage(progress: UserProgress) -> ComparisonResult {
        let averageDailyXP: Double = 80
        let userDailyXP = Double(progress.totalXP) / max(Double(progress.streak), 1.0)
        
        let percentile = min(userDailyXP / averageDailyXP, 2.0) * 50
        
        return ComparisonResult(
            percentile: Int(percentile),
            dailyXP: Int(userDailyXP),
            averageDailyXP: Int(averageDailyXP),
            isAboveAverage: userDailyXP > averageDailyXP
        )
    }
    
    func calculateStudyStreak(progress: UserProgress) -> [Bool] {
        var streak: [Bool] = []
        
        for i in 0..<7 {
            if i < progress.streak {
                streak.append(true)
            } else {
                streak.append(false)
            }
        }
        
        return streak.reversed()
    }
    
    func getMonthlyGoalProgress(progress: UserProgress) -> Double {
        let targetWords = 100
        
        return min(Double(progress.wordsLearned) / Double(targetWords), 1.0)
    }
}

struct ComparisonResult {
    let percentile: Int
    let dailyXP: Int
    let averageDailyXP: Int
    let isAboveAverage: Bool
}
