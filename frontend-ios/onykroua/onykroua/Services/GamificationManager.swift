import Foundation
import SwiftUI
import SwiftData

@Observable
final class GamificationManager {
    private let modelContext: ModelContext
    
    var currentProgress: UserProgress?
    var achievements: [Achievement] = []
    var showXPAnimation: Bool = false
    var lastXPGained: Int = 0
    var showLevelUpModal: Bool = false
    var showAchievementModal: Bool = false
    var lastUnlockedAchievement: Achievement?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadOrCreateProgress()
        loadAchievements()
    }
    
    private func loadOrCreateProgress() {
        let descriptor = FetchDescriptor<UserProgress>()
        if let existing = try? modelContext.fetch(descriptor).first {
            currentProgress = existing
        } else {
            let newProgress = UserProgress()
            modelContext.insert(newProgress)
            currentProgress = newProgress
            try? modelContext.save()
        }
    }
    
    private func loadAchievements() {
        let descriptor = FetchDescriptor<Achievement>()
        if let existing = try? modelContext.fetch(descriptor), !existing.isEmpty {
            achievements = existing
        } else {
            createInitialAchievements()
        }
    }
    
    private func createInitialAchievements() {
        achievements = AchievementType.allCases.map { type in
            let achievement = Achievement(type: type)
            modelContext.insert(achievement)
            return achievement
        }
        try? modelContext.save()
    }
    
    func awardXP(_ amount: Int, for activity: String) {
        guard let progress = currentProgress else { return }
        
        lastXPGained = amount
        let oldLevel = progress.level
        
        progress.addXP(amount)
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showXPAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showXPAnimation = false
        }
        
        if progress.level != oldLevel {
            showLevelUpModal = true
            checkLevelAchievements(progress.level)
        }
        
        try? modelContext.save()
    }
    
    func checkAchievements() {
        guard let progress = currentProgress else { return }
        
        checkWordAchievements(progress.wordsLearned)
        checkStreakAchievements(progress.streak)
        checkLevelAchievements(progress.level)
        checkActivityAchievements(progress)
        checkPerfectWeek()
    }
    
    private func checkWordAchievements(_ count: Int) {
        if count >= 1 {
            unlockAchievement(.firstWord)
        }
        if count >= 100 {
            unlockAchievement(.words100)
        }
        if count >= 500 {
            unlockAchievement(.words500)
        }
        if count >= 1000 {
            unlockAchievement(.words1000)
        }
    }
    
    private func checkStreakAchievements(_ streak: Int) {
        if streak >= 7 {
            unlockAchievement(.streak7)
        }
        if streak >= 30 {
            unlockAchievement(.streak30)
        }
        if streak >= 100 {
            unlockAchievement(.streak100)
        }
    }
    
    private func checkLevelAchievements(_ level: CEFRLevel) {
        switch level {
        case .a2:
            unlockAchievement(.levelA2)
        case .b1:
            unlockAchievement(.levelB1)
        case .b2:
            unlockAchievement(.levelB2)
        case .c1:
            unlockAchievement(.levelC1)
        case .c2:
            unlockAchievement(.levelC2)
        default:
            break
        }
    }
    
    private func checkActivityAchievements(_ progress: UserProgress) {
        if progress.conversationsCompleted >= 10 {
            unlockAchievement(.conversations10)
        }
        if progress.grammarRulesLearned >= 20 {
            unlockAchievement(.grammar20)
        }
        if progress.lessonsCompleted >= 50 {
            unlockAchievement(.dedicated50)
        }
        if progress.lessonsCompleted >= 100 {
            unlockAchievement(.dedicated100)
        }
        if progress.wordsReviewed >= 100 {
            unlockAchievement(.reviewer100)
        }
        
        if progress.quizSuccessRate >= 0.95 && progress.quizzesCompleted >= 10 {
            unlockAchievement(.precision)
        }
    }
    
    private func checkPerfectWeek() {
        guard let progress = currentProgress else { return }
        if progress.streak >= 7 {
            unlockAchievement(.perfectWeek)
        }
    }
    
    func checkTimeBasedAchievements() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 8 {
            unlockAchievement(.earlyBird)
        } else if hour >= 22 {
            unlockAchievement(.nightOwl)
        }
    }
    
    func unlockAchievement(_ type: AchievementType) {
        guard let achievement = achievements.first(where: { $0.achievementType == type }),
              !achievement.isUnlocked else { return }
        
        achievement.unlock()
        lastUnlockedAchievement = achievement
        
        if let progress = currentProgress {
            progress.addXP(type.xpReward)
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showAchievementModal = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showAchievementModal = false
        }
        
        try? modelContext.save()
        
        checkLegendAchievement()
    }
    
    private func checkLegendAchievement() {
        let totalAchievements = AchievementType.allCases.count
        let unlockedCount = achievements.filter { $0.isUnlocked }.count
        
        if unlockedCount >= totalAchievements - 1 {
            unlockAchievement(.legend)
        }
    }
    
    func recordWordLearned() {
        currentProgress?.recordWordLearned()
        checkAchievements()
        try? modelContext.save()
    }
    
    func recordWordReviewed() {
        currentProgress?.recordWordReviewed()
        checkAchievements()
        try? modelContext.save()
    }
    
    func recordLessonCompleted() {
        currentProgress?.recordLessonCompleted()
        checkAchievements()
        try? modelContext.save()
    }
    
    func recordQuizCompleted(correct: Int, total: Int) {
        currentProgress?.recordQuizCompleted(correct: correct, total: total)
        checkAchievements()
        try? modelContext.save()
    }
    
    func recordConversationCompleted() {
        currentProgress?.recordConversationCompleted()
        checkAchievements()
        try? modelContext.save()
    }
    
    func recordGrammarRuleLearned() {
        currentProgress?.recordGrammarRuleLearned()
        checkAchievements()
        try? modelContext.save()
    }
    
    func recordVerbLearned() {
        currentProgress?.recordVerbLearned()
        checkAchievements()
        try? modelContext.save()
    }
    
    func updateStreak() {
        currentProgress?.checkAndUpdateStreak()
        checkAchievements()
        try? modelContext.save()
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    func getLockedAchievements() -> [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
    
    // MARK: - Firebase Sync (To be implemented with proper async context)
    // Note: Firebase sync methods removed to fix Swift 6 compilation errors
    // These should be implemented in a separate @MainActor service or with proper Sendable conformance
    
    func getAchievementProgress(for type: AchievementType) -> Double {
        guard let progress = currentProgress else { return 0 }
        
        switch type {
        case .firstWord:
            return progress.wordsLearned >= 1 ? 1.0 : 0.0
        case .words100:
            return min(Double(progress.wordsLearned) / 100.0, 1.0)
        case .words500:
            return min(Double(progress.wordsLearned) / 500.0, 1.0)
        case .words1000:
            return min(Double(progress.wordsLearned) / 1000.0, 1.0)
        case .streak7:
            return min(Double(progress.streak) / 7.0, 1.0)
        case .streak30:
            return min(Double(progress.streak) / 30.0, 1.0)
        case .streak100:
            return min(Double(progress.streak) / 100.0, 1.0)
        case .conversations10:
            return min(Double(progress.conversationsCompleted) / 10.0, 1.0)
        case .grammar20:
            return min(Double(progress.grammarRulesLearned) / 20.0, 1.0)
        case .dedicated50:
            return min(Double(progress.lessonsCompleted) / 50.0, 1.0)
        case .dedicated100:
            return min(Double(progress.lessonsCompleted) / 100.0, 1.0)
        case .reviewer100:
            return min(Double(progress.wordsReviewed) / 100.0, 1.0)
        default:
            return 0.0
        }
    }
}
