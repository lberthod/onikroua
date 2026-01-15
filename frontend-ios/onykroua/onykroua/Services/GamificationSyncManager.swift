import Foundation
import SwiftData

@MainActor
final class GamificationSyncManager: ObservableObject {
    static let shared = GamificationSyncManager()
    
    private let syncService = FirebaseSyncService.shared
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?
    
    private init() {}
    
    // MARK: - Sync from Cloud
    
    func syncFromCloud(gamificationManager: GamificationManager) async {
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            if let remoteProgress = try await syncService.fetchUserProgress() {
                if let currentProgress = gamificationManager.currentProgress {
                    if remoteProgress.totalXP > currentProgress.totalXP {
                        mergeProgress(remote: remoteProgress, local: currentProgress)
                        print("✅ Sync: Merged remote progress")
                    }
                }
            }
            
            let remoteAchievements = try await syncService.fetchAchievements()
            for (achievementId, unlockedAt) in remoteAchievements {
                if let achievement = gamificationManager.achievements.first(where: { 
                    String(describing: $0.type) == achievementId 
                }), !achievement.isUnlocked {
                    achievement.unlock()
                    achievement.unlockedDate = unlockedAt
                }
            }
            
            lastSyncDate = Date()
            print("✅ Sync: Sync from cloud completed")
        } catch {
            syncError = error
            print("❌ Sync: Failed to sync from cloud - \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sync to Cloud
    
    func syncToCloud(gamificationManager: GamificationManager) async {
        guard let progress = gamificationManager.currentProgress else { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            try await syncService.syncUserProgress(progress)
            
            for achievement in gamificationManager.achievements where achievement.isUnlocked {
                if let unlockedDate = achievement.unlockedDate {
                    try await syncService.syncAchievement(
                        achievement.type,
                        unlockedAt: unlockedDate
                    )
                }
            }
            
            lastSyncDate = Date()
            print("✅ Sync: Sync to cloud completed")
        } catch {
            syncError = error
            print("❌ Sync: Failed to sync to cloud - \(error.localizedDescription)")
        }
    }
    
    // MARK: - Full Sync
    
    func performFullSync(gamificationManager: GamificationManager) async {
        await syncFromCloud(gamificationManager: gamificationManager)
        await syncToCloud(gamificationManager: gamificationManager)
    }
    
    // MARK: - Auto Sync on Action
    
    func autoSyncAfterAction(gamificationManager: GamificationManager) {
        Task { @MainActor in
            await syncToCloud(gamificationManager: gamificationManager)
        }
    }
    
    // MARK: - Merge Logic
    
    private func mergeProgress(remote: UserProgress, local: UserProgress) {
        local.currentXP = max(local.currentXP, remote.currentXP)
        local.totalXP = max(local.totalXP, remote.totalXP)
        local.wordsLearned = max(local.wordsLearned, remote.wordsLearned)
        local.verbsLearned = max(local.verbsLearned, remote.verbsLearned)
        local.grammarRulesLearned = max(local.grammarRulesLearned, remote.grammarRulesLearned)
        local.conversationsCompleted = max(local.conversationsCompleted, remote.conversationsCompleted)
        local.quizzesCompleted = max(local.quizzesCompleted, remote.quizzesCompleted)
        local.wordsReviewed = max(local.wordsReviewed, remote.wordsReviewed)
        local.lessonsCompleted = max(local.lessonsCompleted, remote.lessonsCompleted)
        local.longestStreak = max(local.longestStreak, remote.longestStreak)
        
        let remoteLevel = remote.level
        if remoteLevel.xpRequired > local.level.xpRequired {
            local.level = remoteLevel
        }
    }
    
    // MARK: - Activity Logging
    
    func logStudySession(duration: Int, xpGained: Int, activityType: String) async {
        do {
            try await syncService.logStudySession(
                duration: duration,
                xpGained: xpGained,
                activityType: activityType
            )
            print("✅ Sync: Study session logged")
        } catch {
            print("❌ Sync: Failed to log study session - \(error.localizedDescription)")
        }
    }
    
    func logQuizResult(quizType: String, score: Int, totalQuestions: Int, difficulty: String) async {
        do {
            try await syncService.syncQuizResult(
                quizType: quizType,
                score: score,
                totalQuestions: totalQuestions,
                difficulty: difficulty
            )
            print("✅ Sync: Quiz result logged")
        } catch {
            print("❌ Sync: Failed to log quiz result - \(error.localizedDescription)")
        }
    }
    
    func updateLeaderboard(username: String, gamificationManager: GamificationManager) async {
        guard let progress = gamificationManager.currentProgress else { return }
        
        do {
            try await syncService.updateLeaderboard(
                username: username,
                totalXP: progress.totalXP,
                level: progress.level.rawValue,
                streak: progress.streak
            )
            print("✅ Sync: Leaderboard updated")
        } catch {
            print("❌ Sync: Failed to update leaderboard - \(error.localizedDescription)")
        }
    }
}
