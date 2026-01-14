import Foundation

struct GrammarRule: Identifiable, Codable {
    let id: String
    let category: String
    let subCategory: String
    let rule: String
    let content: String
    let example: String?
    let translation: String?
    let difficulty: String
}

struct GrammarCategory: Identifiable {
    let id: String
    let label: String
    let icon: String
    let color: String
    
    init(id: String, label: String, icon: String, color: String) {
        self.id = id
        self.label = label
        self.icon = icon
        self.color = color
    }
}

struct GrammarGroup: Identifiable {
    let id = UUID()
    let subCategory: String
    let label: String
    let rules: [GrammarRule]
}

enum GrammarDifficulty: String, CaseIterable {
    case all = "all"
    case beginner = "débutant"
    case intermediate = "intermédiaire"
    case advanced = "avancé"
    
    var label: String {
        switch self {
        case .all: return "Tous niveaux"
        case .beginner: return "Débutant"
        case .intermediate: return "Intermédiaire"
        case .advanced: return "Avancé"
        }
    }
    
    var color: String {
        switch self {
        case .all: return "#95A5A6"
        case .beginner: return "#27AE60"
        case .intermediate: return "#F39C12"
        case .advanced: return "#E74C3C"
        }
    }
}
