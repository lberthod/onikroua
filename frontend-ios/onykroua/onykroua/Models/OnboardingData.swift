import Foundation
import SwiftData

enum LearningGoal: String, Codable, CaseIterable {
    case travel = "Voyage / Vacances"
    case work = "Travail / Business"
    case study = "Études"
    case passion = "Passion / Culture"
    
    var icon: String {
        switch self {
        case .travel: return "✈️"
        case .work: return "💼"
        case .study: return "📚"
        case .passion: return "❤️"
        }
    }
}

enum Language: String, Codable {
    case italian = "it"
    case spanish = "es"
    
    var displayName: String {
        switch self {
        case .italian: return "Italien"
        case .spanish: return "Espagnol"
        }
    }
    
    var flag: String {
        switch self {
        case .italian: return "🇮🇹"
        case .spanish: return "🇪🇸"
        }
    }
}

@Model
final class OnboardingData {
    var hasCompletedOnboarding: Bool = false
    var selectedLanguage: String = ""
    var selectedGoals: [String] = []
    var initialLevel: String = ""
    var dailyGoalMinutes: Int = 10
    var notificationsEnabled: Bool = false
    var preferredStudyTime: Date?
    var completedAt: Date?
    
    init(
        hasCompletedOnboarding: Bool = false,
        selectedLanguage: String = Language.italian.rawValue,
        selectedGoals: [String] = [],
        initialLevel: String = CEFRLevel.a1.rawValue,
        dailyGoalMinutes: Int = 10,
        notificationsEnabled: Bool = false,
        preferredStudyTime: Date? = nil,
        completedAt: Date? = nil
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.selectedLanguage = selectedLanguage
        self.selectedGoals = selectedGoals
        self.initialLevel = initialLevel
        self.dailyGoalMinutes = dailyGoalMinutes
        self.notificationsEnabled = notificationsEnabled
        self.preferredStudyTime = preferredStudyTime
        self.completedAt = completedAt
    }
    
    var language: Language {
        get { Language(rawValue: selectedLanguage) ?? .italian }
        set { selectedLanguage = newValue.rawValue }
    }
    
    var level: CEFRLevel {
        get { CEFRLevel.fromString(initialLevel) }
        set { initialLevel = newValue.rawValue }
    }
    
    var goals: [LearningGoal] {
        selectedGoals.compactMap { LearningGoal(rawValue: $0) }
    }
    
    var dailyXPGoal: Int {
        switch dailyGoalMinutes {
        case 0..<10: return 50
        case 10..<20: return 100
        case 20..<30: return 150
        default: return 200
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        completedAt = Date()
    }
}
