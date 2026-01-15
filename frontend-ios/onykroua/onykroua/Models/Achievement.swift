import Foundation
import SwiftUI
import SwiftData

enum AchievementType: String, Codable, CaseIterable {
    case firstWord = "first_word"
    case words100 = "words_100"
    case words500 = "words_500"
    case words1000 = "words_1000"
    case streak7 = "streak_7"
    case streak30 = "streak_30"
    case streak100 = "streak_100"
    case perfectWeek = "perfect_week"
    case levelA2 = "level_a2"
    case levelB1 = "level_b1"
    case levelB2 = "level_b2"
    case levelC1 = "level_c1"
    case levelC2 = "level_c2"
    case conversations10 = "conversations_10"
    case grammar20 = "grammar_20"
    case speedDemon = "speed_demon"
    case precision = "precision"
    case earlyBird = "early_bird"
    case nightOwl = "night_owl"
    case dedicated50 = "dedicated_50"
    case dedicated100 = "dedicated_100"
    case emojiMaster = "emoji_master"
    case traveler = "traveler"
    case luckyTen = "lucky_ten"
    case reviewer100 = "reviewer_100"
    case analyst = "analyst"
    case social = "social"
    case referrer = "referrer"
    case legend = "legend"
    
    var title: String {
        switch self {
        case .firstWord: return "Premier Mot"
        case .words100: return "Bibliophile"
        case .words500: return "Érudit"
        case .words1000: return "Maître des Mots"
        case .streak7: return "Flamme Persistante"
        case .streak30: return "Étudiant Assidu"
        case .streak100: return "Diamant"
        case .perfectWeek: return "Semaine Parfaite"
        case .levelA2: return "Premier Niveau"
        case .levelB1: return "Intermédiaire"
        case .levelB2: return "Avancé"
        case .levelC1: return "Autonome"
        case .levelC2: return "Maître Complet"
        case .conversations10: return "Conversateur"
        case .grammar20: return "Grammairien"
        case .speedDemon: return "Éclair"
        case .precision: return "Perfectionniste"
        case .earlyBird: return "Lève-Tôt"
        case .nightOwl: return "Noctambule"
        case .dedicated50: return "Accro"
        case .dedicated100: return "Acharné"
        case .emojiMaster: return "Collectionneur"
        case .traveler: return "Voyageur"
        case .luckyTen: return "Chanceux"
        case .reviewer100: return "Réviseur"
        case .analyst: return "Analytique"
        case .social: return "Social"
        case .referrer: return "Généreux"
        case .legend: return "Légende"
        }
    }
    
    var description: String {
        switch self {
        case .firstWord: return "Apprends ton premier mot"
        case .words100: return "Apprends 100 mots"
        case .words500: return "Apprends 500 mots"
        case .words1000: return "Apprends 1000 mots"
        case .streak7: return "Maintiens un streak de 7 jours"
        case .streak30: return "Maintiens un streak de 30 jours"
        case .streak100: return "Maintiens un streak de 100 jours"
        case .perfectWeek: return "Étudie 7 jours d'affilée"
        case .levelA2: return "Atteins le niveau A2"
        case .levelB1: return "Atteins le niveau B1"
        case .levelB2: return "Atteins le niveau B2"
        case .levelC1: return "Atteins le niveau C1"
        case .levelC2: return "Atteins le niveau C2"
        case .conversations10: return "Complète 10 conversations"
        case .grammar20: return "Maîtrise 20 règles de grammaire"
        case .speedDemon: return "Termine une leçon en moins de 2 minutes"
        case .precision: return "Obtiens 95% de réussite à un quiz"
        case .earlyBird: return "Étudie avant 8h du matin"
        case .nightOwl: return "Étudie après 22h"
        case .dedicated50: return "Complète 50 sessions d'étude"
        case .dedicated100: return "Complète 100 sessions d'étude"
        case .emojiMaster: return "Explore toutes les catégories d'emojis"
        case .traveler: return "Complète tous les scénarios de voyage"
        case .luckyTen: return "Obtiens 10 quiz parfaits"
        case .reviewer100: return "Effectue 100 révisions"
        case .analyst: return "Consulte tes statistiques 10 fois"
        case .social: return "Partage 5 badges"
        case .referrer: return "Invite 3 amis"
        case .legend: return "Débloque tous les autres badges"
        }
    }
    
    var icon: String {
        switch self {
        case .firstWord: return "🎯"
        case .words100: return "📚"
        case .words500: return "🧠"
        case .words1000: return "🏆"
        case .streak7: return "🔥"
        case .streak30: return "⚡"
        case .streak100: return "💎"
        case .perfectWeek: return "✨"
        case .levelA2: return "🎓"
        case .levelB1: return "🌟"
        case .levelB2: return "💫"
        case .levelC1: return "🚀"
        case .levelC2: return "👑"
        case .conversations10: return "🗣️"
        case .grammar20: return "✍️"
        case .speedDemon: return "⚡"
        case .precision: return "🎯"
        case .earlyBird: return "🌅"
        case .nightOwl: return "🌙"
        case .dedicated50: return "📱"
        case .dedicated100: return "💪"
        case .emojiMaster: return "🎨"
        case .traveler: return "🚂"
        case .luckyTen: return "🎲"
        case .reviewer100: return "🔄"
        case .analyst: return "📊"
        case .social: return "👥"
        case .referrer: return "🎁"
        case .legend: return "🏅"
        }
    }
    
    var xpReward: Int {
        switch self {
        case .firstWord: return 10
        case .words100: return 100
        case .words500: return 500
        case .words1000: return 1000
        case .streak7: return 100
        case .streak30: return 500
        case .streak100: return 2000
        case .perfectWeek: return 200
        case .levelA2: return 300
        case .levelB1: return 600
        case .levelB2: return 1200
        case .levelC1: return 2500
        case .levelC2: return 5000
        case .conversations10: return 150
        case .grammar20: return 200
        case .speedDemon: return 50
        case .precision: return 100
        case .earlyBird: return 50
        case .nightOwl: return 50
        case .dedicated50: return 300
        case .dedicated100: return 750
        case .emojiMaster: return 200
        case .traveler: return 250
        case .luckyTen: return 300
        case .reviewer100: return 500
        case .analyst: return 50
        case .social: return 100
        case .referrer: return 200
        case .legend: return 10000
        }
    }
    
    var rarity: AchievementRarity {
        switch self {
        case .firstWord, .earlyBird, .nightOwl, .analyst:
            return .common
        case .words100, .streak7, .perfectWeek, .conversations10, .grammar20, .speedDemon, .precision, .dedicated50, .social:
            return .uncommon
        case .words500, .streak30, .levelA2, .levelB1, .emojiMaster, .traveler, .luckyTen, .reviewer100, .dedicated100, .referrer:
            return .rare
        case .words1000, .streak100, .levelB2, .levelC1:
            return .epic
        case .levelC2, .legend:
            return .legendary
        }
    }
}

enum AchievementRarity: String, Codable {
    case common = "Commun"
    case uncommon = "Peu Commun"
    case rare = "Rare"
    case epic = "Épique"
    case legendary = "Légendaire"
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

@Model
final class Achievement {
    var type: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var progress: Int
    
    init(type: AchievementType, isUnlocked: Bool = false, progress: Int = 0) {
        self.type = type.rawValue
        self.isUnlocked = isUnlocked
        self.unlockedDate = nil
        self.progress = progress
    }
    
    var achievementType: AchievementType {
        AchievementType(rawValue: type) ?? .firstWord
    }
    
    func unlock() {
        isUnlocked = true
        unlockedDate = Date()
    }
}
