import Foundation

// MARK: - App Constants

struct AppConstants {
    
    // MARK: - Languages
    
    enum Language: String {
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
        
        var speechCode: String {
            switch self {
            case .italian: return "it-IT"
            case .spanish: return "es-ES"
            }
        }
    }
    
    // MARK: - UserDefaults Keys
    
    struct UserDefaultsKeys {
        static let learnedWords = "learned_words"
        static let favorites = "favorites"
        static let dailyStreak = "daily_streak"
        static let totalXP = "total_xp"
        static let lastActivity = "last_activity"
        static let selectedLanguage = "selected_language"
        static let userEmail = "user_email"
    }
    
    // MARK: - XP & Levels
    
    struct Gamification {
        static let xpPerWord = 10
        static let xpPerLevel = 100
        static let xpForPractice = 5
        static let xpForQuiz = 20
    }
    
    // MARK: - UI Constants
    
    struct UI {
        static let cornerRadius: CGFloat = 16
        static let smallCornerRadius: CGFloat = 12
        static let cardShadowRadius: CGFloat = 8
        static let cardShadowOpacity: Double = 0.05
        static let spacing: CGFloat = 16
        static let padding: CGFloat = 16
    }
    
    // MARK: - Animation
    
    struct Animation {
        static let defaultDuration: Double = 0.3
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.7
    }
}
