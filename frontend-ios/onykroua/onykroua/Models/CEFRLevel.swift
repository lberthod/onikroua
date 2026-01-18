import Foundation
import SwiftUI

public enum CEFRLevel: String, Codable, CaseIterable, Identifiable {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"
    case b2 = "B2"
    case c1 = "C1"
    case c2 = "C2"
    
    public var id: String { rawValue }
    
    public var levelNumber: Int {
        switch self {
        case .a1: return 1
        case .a2: return 2
        case .b1: return 3
        case .b2: return 4
        case .c1: return 5
        case .c2: return 6
        }
    }
    
    public var displayName: String {
        switch self {
        case .a1: return "A1 - Débutant"
        case .a2: return "A2 - Élémentaire"
        case .b1: return "B1 - Intermédiaire"
        case .b2: return "B2 - Avancé"
        case .c1: return "C1 - Autonome"
        case .c2: return "C2 - Maîtrise"
        }
    }
    
    public var shortDescription: String {
        switch self {
        case .a1: return "Découverte"
        case .a2: return "Survie"
        case .b1: return "Seuil"
        case .b2: return "Indépendant"
        case .c1: return "Expérimenté"
        case .c2: return "Maîtrise complète"
        }
    }
    
    public var description: String {
        switch self {
        case .a1:
            return "Je peux comprendre et utiliser des expressions familières et quotidiennes. Je peux me présenter et poser des questions simples."
        case .a2:
            return "Je peux communiquer lors de tâches simples. Je peux décrire mon environnement immédiat et mes besoins."
        case .b1:
            return "Je peux comprendre les points essentiels d'une conversation claire. Je peux me débrouiller dans la plupart des situations de voyage."
        case .b2:
            return "Je peux comprendre le contenu essentiel de sujets concrets ou abstraits. Je peux communiquer avec spontanéité."
        case .c1:
            return "Je peux comprendre des textes longs et exigeants. Je m'exprime spontanément et couramment."
        case .c2:
            return "Je comprends sans effort tout ce que j'entends ou lis. Je peux m'exprimer avec précision dans toutes les situations."
        }
    }
    
    public var detailedDescription: String {
        return description
    }
    
    public var xpRequired: Int {
        switch self {
        case .a1: return 1000
        case .a2: return 2500
        case .b1: return 5000
        case .b2: return 10000
        case .c1: return 20000
        case .c2: return 50000
        }
    }
    
    public var color: Color {
        switch self {
        case .a1: return Color.green
        case .a2: return Color.mint
        case .b1: return Color.blue
        case .b2: return Color.indigo
        case .c1: return Color.purple
        case .c2: return Color.pink
        }
    }
    
    public var gradientColors: [Color] {
        switch self {
        case .a1: return [Color.green, Color.mint]
        case .a2: return [Color.mint, Color.cyan]
        case .b1: return [Color.blue, Color.indigo]
        case .b2: return [Color.indigo, Color.purple]
        case .c1: return [Color.purple, Color.pink]
        case .c2: return [Color.pink, Color.red]
        }
    }
    
    public var icon: String {
        switch self {
        case .a1: return "🌱"
        case .a2: return "🌿"
        case .b1: return "🌳"
        case .b2: return "🌲"
        case .c1: return "🏆"
        case .c2: return "👑"
        }
    }
    
    public var estimatedWordsToKnow: Int {
        switch self {
        case .a1: return 500
        case .a2: return 1000
        case .b1: return 2000
        case .b2: return 4000
        case .c1: return 8000
        case .c2: return 15000
        }
    }
    
    public var nextLevel: CEFRLevel? {
        switch self {
        case .a1: return .a2
        case .a2: return .b1
        case .b1: return .b2
        case .b2: return .c1
        case .c1: return .c2
        case .c2: return nil
        }
    }
    
    public var previousLevel: CEFRLevel? {
        switch self {
        case .a1: return nil
        case .a2: return .a1
        case .b1: return .a2
        case .b2: return .b1
        case .c1: return .b2
        case .c2: return .c1
        }
    }
    
    public static func fromString(_ string: String) -> CEFRLevel {
        return CEFRLevel(rawValue: string.uppercased()) ?? .a1
    }
    
    public static func fromLevelNumber(_ level: Int) -> CEFRLevel {
        switch level {
        case 1: return .a1
        case 2: return .a2
        case 3: return .b1
        case 4: return .b2
        case 5: return .c1
        default: return .c2
        }
    }
}
