import Foundation
import SwiftUI

class ProgressTracker: ObservableObject {
    @Published var wordsLearned: Set<String> = []
    @Published var favorites: Set<String> = []
    @Published var dailyStreak: Int = 0
    @Published var totalXP: Int = 0
    @Published var lastActivityDate: Date?
    
    private let wordsKey = "learned_words"
    private let favKey = "favorites"
    private let streakKey = "daily_streak"
    private let xpKey = "total_xp"
    private let lastActivityKey = "last_activity"
    
    static let shared = ProgressTracker()
    
    private init() {
        load()
        updateStreak()
    }
    
    func save() {
        UserDefaults.standard.set(Array(wordsLearned), forKey: wordsKey)
        UserDefaults.standard.set(Array(favorites), forKey: favKey)
        UserDefaults.standard.set(dailyStreak, forKey: streakKey)
        UserDefaults.standard.set(totalXP, forKey: xpKey)
        if let date = lastActivityDate {
            UserDefaults.standard.set(date, forKey: lastActivityKey)
        }
    }
    
    func load() {
        wordsLearned = Set(UserDefaults.standard.stringArray(forKey: wordsKey) ?? [])
        favorites = Set(UserDefaults.standard.stringArray(forKey: favKey) ?? [])
        dailyStreak = UserDefaults.standard.integer(forKey: streakKey)
        totalXP = UserDefaults.standard.integer(forKey: xpKey)
        lastActivityDate = UserDefaults.standard.object(forKey: lastActivityKey) as? Date
    }
    
    func markWordLearned(_ word: String, xp: Int = 10) {
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
        return (totalXP / 100) + 1
    }
    
    func getProgressToNextLevel() -> Double {
        let currentLevelXP = (getUserLevel() - 1) * 100
        let nextLevelXP = getUserLevel() * 100
        let progress = Double(totalXP - currentLevelXP) / Double(nextLevelXP - currentLevelXP)
        return max(0, min(1, progress))
    }
}
