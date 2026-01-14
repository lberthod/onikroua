import Foundation
import SwiftUI

// MARK: - Progress Tracker

class ProgressTracker: ObservableObject {
    @Published var wordsLearned: Set<String> = []
    @Published var favorites: Set<String> = []
    @Published var dailyStreak: Int = 0
    @Published var totalXP: Int = 0
    @Published var lastActivityDate: Date?
    
    static let shared = ProgressTracker()
    
    private init() {
        load()
        updateStreak()
    }
    
    func save() {
        UserDefaults.standard.set(Array(wordsLearned), forKey: AppConstants.UserDefaultsKeys.learnedWords)
        UserDefaults.standard.set(Array(favorites), forKey: AppConstants.UserDefaultsKeys.favorites)
        UserDefaults.standard.set(dailyStreak, forKey: AppConstants.UserDefaultsKeys.dailyStreak)
        UserDefaults.standard.set(totalXP, forKey: AppConstants.UserDefaultsKeys.totalXP)
        if let date = lastActivityDate {
            UserDefaults.standard.set(date, forKey: AppConstants.UserDefaultsKeys.lastActivity)
        }
    }
    
    func load() {
        wordsLearned = Set(UserDefaults.standard.stringArray(forKey: AppConstants.UserDefaultsKeys.learnedWords) ?? [])
        favorites = Set(UserDefaults.standard.stringArray(forKey: AppConstants.UserDefaultsKeys.favorites) ?? [])
        dailyStreak = UserDefaults.standard.integer(forKey: AppConstants.UserDefaultsKeys.dailyStreak)
        totalXP = UserDefaults.standard.integer(forKey: AppConstants.UserDefaultsKeys.totalXP)
        lastActivityDate = UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.lastActivity) as? Date
    }
    
    func markWordLearned(_ word: String, xp: Int = AppConstants.Gamification.xpPerWord) {
        wordsLearned.insert(word)
        addXP(xp)
        save()
    }
    
    func toggleFavorite(_ id: String) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
        save()
    }
    
    func isFavorite(_ id: String) -> Bool {
        return favorites.contains(id)
    }
    
    func addXP(_ amount: Int) {
        totalXP += amount
        recordActivity()
        save()
    }
    
    private func recordActivity() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastActivityDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                dailyStreak += 1
            } else if daysDifference > 1 {
                dailyStreak = 1
            }
        } else {
            dailyStreak = 1
        }
        
        lastActivityDate = Date()
    }
    
    private func updateStreak() {
        guard let lastDate = lastActivityDate else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let lastDay = Calendar.current.startOfDay(for: lastDate)
        let daysDifference = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        if daysDifference > 1 {
            dailyStreak = 0
            save()
        }
    }
    
    func getUserLevel() -> Int {
        return (totalXP / AppConstants.Gamification.xpPerLevel) + 1
    }
    
    func getProgressToNextLevel() -> Double {
        let currentLevelXP = (getUserLevel() - 1) * AppConstants.Gamification.xpPerLevel
        let nextLevelXP = getUserLevel() * AppConstants.Gamification.xpPerLevel
        let progress = Double(totalXP - currentLevelXP) / Double(nextLevelXP - currentLevelXP)
        return max(0, min(1, progress))
    }
}
