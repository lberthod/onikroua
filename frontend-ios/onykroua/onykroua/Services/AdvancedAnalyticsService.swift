import Foundation
import SwiftData

// MARK: - Advanced Analytics Service

class AdvancedAnalyticsService: ObservableObject {
    @Published var insights: [LearningInsight] = []
    @Published var recommendations: [Recommendation] = []
    @Published var strengths: [SkillArea] = []
    @Published var weaknesses: [SkillArea] = []
    
    private let modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    // MARK: - Learning Insight
    
    struct LearningInsight: Identifiable {
        let id = UUID()
        let type: InsightType
        let title: String
        let message: String
        let metric: Double
        let trend: Trend
        let icon: String
        let color: String
        let actionable: Bool
        
        enum InsightType {
            case strength
            case weakness
            case improvement
            case milestone
            case warning
            case suggestion
        }
        
        enum Trend {
            case up
            case down
            case stable
            case unknown
            
            var icon: String {
                switch self {
                case .up: return "arrow.up.circle.fill"
                case .down: return "arrow.down.circle.fill"
                case .stable: return "minus.circle.fill"
                case .unknown: return "questionmark.circle.fill"
                }
            }
            
            var color: String {
                switch self {
                case .up: return "green"
                case .down: return "red"
                case .stable: return "blue"
                case .unknown: return "gray"
                }
            }
        }
    }
    
    // MARK: - Recommendation
    
    struct Recommendation: Identifiable {
        let id = UUID()
        let priority: Priority
        let category: Category
        let title: String
        let description: String
        let actionText: String
        let estimatedTime: Int // minutes
        let potentialXP: Int
        let icon: String
        
        enum Priority: Int {
            case low = 1
            case medium = 2
            case high = 3
            case critical = 4
            
            var color: String {
                switch self {
                case .low: return "blue"
                case .medium: return "yellow"
                case .high: return "orange"
                case .critical: return "red"
                }
            }
            
            var label: String {
                switch self {
                case .low: return "Suggéré"
                case .medium: return "Recommandé"
                case .high: return "Important"
                case .critical: return "Urgent"
                }
            }
        }
        
        enum Category {
            case vocabulary
            case grammar
            case conjugation
            case conversation
            case review
            case practice
            case streak
            
            var icon: String {
                switch self {
                case .vocabulary: return "📚"
                case .grammar: return "📖"
                case .conjugation: return "✏️"
                case .conversation: return "💬"
                case .review: return "🔄"
                case .practice: return "💪"
                case .streak: return "🔥"
                }
            }
        }
    }
    
    // MARK: - Skill Area
    
    struct SkillArea: Identifiable {
        let id = UUID()
        let name: String
        let category: String
        let score: Double // 0-100
        let reviewCount: Int
        let lastPracticed: Date?
        let trend: LearningInsight.Trend
        
        var level: SkillLevel {
            switch score {
            case 90...100: return .expert
            case 75..<90: return .advanced
            case 60..<75: return .intermediate
            case 40..<60: return .beginner
            default: return .novice
            }
        }
        
        enum SkillLevel: String {
            case novice = "Débutant"
            case beginner = "Élémentaire"
            case intermediate = "Intermédiaire"
            case advanced = "Avancé"
            case expert = "Expert"
            
            var icon: String {
                switch self {
                case .novice: return "🌱"
                case .beginner: return "🌿"
                case .intermediate: return "🌳"
                case .advanced: return "⭐"
                case .expert: return "🏆"
                }
            }
        }
    }
    
    // MARK: - Analytics Methods
    
    func analyzeProgress(progress: UserProgress) -> [LearningInsight] {
        var insights: [LearningInsight] = []
        
        // XP Growth Analysis
        if progress.currentXP > 0 {
            let xpInsight = LearningInsight(
                type: .milestone,
                title: "Progression XP",
                message: "Tu as accumulé \(progress.currentXP) XP !",
                metric: Double(progress.currentXP),
                trend: .up,
                icon: "star.fill",
                color: "yellow",
                actionable: false
            )
            insights.append(xpInsight)
        }
        
        // Streak Analysis
        if progress.streak >= 7 {
            let streakInsight = LearningInsight(
                type: .strength,
                title: "Série impressionnante",
                message: "Bravo ! \(progress.streak) jours d'affilée 🔥",
                metric: Double(progress.streak),
                trend: .up,
                icon: "flame.fill",
                color: "orange",
                actionable: false
            )
            insights.append(streakInsight)
        } else if progress.streak == 0 {
            let streakInsight = LearningInsight(
                type: .warning,
                title: "Série interrompue",
                message: "Pratique aujourd'hui pour relancer ta série",
                metric: 0,
                trend: .down,
                icon: "exclamationmark.triangle.fill",
                color: "red",
                actionable: true
            )
            insights.append(streakInsight)
        }
        
        // Words Learned Analysis
        let expectedWords = progress.level.estimatedWordsToKnow
        let wordsPercentage = Double(progress.wordsLearned) / Double(expectedWords) * 100
        
        if wordsPercentage >= 80 {
            let wordsInsight = LearningInsight(
                type: .strength,
                title: "Vocabulaire solide",
                message: "Tu maîtrises \(progress.wordsLearned) mots (\(Int(wordsPercentage))% de ton niveau)",
                metric: wordsPercentage,
                trend: .up,
                icon: "book.fill",
                color: "blue",
                actionable: false
            )
            insights.append(wordsInsight)
        } else if wordsPercentage < 40 {
            let wordsInsight = LearningInsight(
                type: .weakness,
                title: "Vocabulaire à enrichir",
                message: "Concentre-toi sur l'apprentissage de nouveaux mots",
                metric: wordsPercentage,
                trend: .down,
                icon: "book.closed.fill",
                color: "orange",
                actionable: true
            )
            insights.append(wordsInsight)
        }
        
        // Quiz Success Rate
        if progress.quizSuccessRate >= 0.8 {
            let quizInsight = LearningInsight(
                type: .strength,
                title: "Excellentes performances",
                message: "Taux de réussite de \(Int(progress.quizSuccessRate * 100))% aux quiz",
                metric: progress.quizSuccessRate * 100,
                trend: .up,
                icon: "checkmark.seal.fill",
                color: "green",
                actionable: false
            )
            insights.append(quizInsight)
        } else if progress.quizSuccessRate < 0.5 {
            let quizInsight = LearningInsight(
                type: .weakness,
                title: "Difficulté aux quiz",
                message: "Révise davantage avant de passer les quiz",
                metric: progress.quizSuccessRate * 100,
                trend: .down,
                icon: "xmark.seal.fill",
                color: "red",
                actionable: true
            )
            insights.append(quizInsight)
        }
        
        // Conversation Practice
        if progress.conversationsCompleted >= 10 {
            let convInsight = LearningInsight(
                type: .improvement,
                title: "Pratique conversationnelle",
                message: "\(progress.conversationsCompleted) conversations complétées",
                metric: Double(progress.conversationsCompleted),
                trend: .up,
                icon: "bubble.left.and.bubble.right.fill",
                color: "purple",
                actionable: false
            )
            insights.append(convInsight)
        } else {
            let convInsight = LearningInsight(
                type: .suggestion,
                title: "Plus de conversations",
                message: "Pratique plus de dialogues pour améliorer ta fluidité",
                metric: Double(progress.conversationsCompleted),
                trend: .stable,
                icon: "bubble.left.and.bubble.right",
                color: "blue",
                actionable: true
            )
            insights.append(convInsight)
        }
        
        return insights
    }
    
    func generateRecommendations(progress: UserProgress) -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // Streak Recommendation
        if progress.streak == 0 {
            recommendations.append(Recommendation(
                priority: .critical,
                category: .streak,
                title: "Reprends ta série quotidienne",
                description: "Fais au moins un exercice aujourd'hui pour relancer ta série",
                actionText: "Commencer maintenant",
                estimatedTime: 5,
                potentialXP: 50,
                icon: "🔥"
            ))
        } else if progress.streak >= 7 && progress.streak < 14 {
            recommendations.append(Recommendation(
                priority: .medium,
                category: .streak,
                title: "Continue ta série !",
                description: "Tu es à \(progress.streak) jours, vise les 14 jours",
                actionText: "Pratiquer aujourd'hui",
                estimatedTime: 10,
                potentialXP: 100,
                icon: "🔥"
            ))
        }
        
        // Vocabulary Recommendation
        let vocabPercentage = Double(progress.wordsLearned) / Double(progress.level.estimatedWordsToKnow)
        if vocabPercentage < 0.5 {
            recommendations.append(Recommendation(
                priority: .high,
                category: .vocabulary,
                title: "Enrichis ton vocabulaire",
                description: "Apprends 10 nouveaux mots avec les flashcards",
                actionText: "Flashcards vocabulaire",
                estimatedTime: 10,
                potentialXP: 50,
                icon: "📚"
            ))
        }
        
        // Grammar Recommendation
        if progress.grammarRulesLearned < 20 {
            recommendations.append(Recommendation(
                priority: .medium,
                category: .grammar,
                title: "Renforce ta grammaire",
                description: "Étudie 3 nouvelles règles de grammaire",
                actionText: "Quiz de grammaire",
                estimatedTime: 15,
                potentialXP: 75,
                icon: "📖"
            ))
        }
        
        // Conjugation Recommendation
        if progress.quizSuccessRate < 0.7 {
            recommendations.append(Recommendation(
                priority: .high,
                category: .conjugation,
                title: "Pratique les conjugaisons",
                description: "Les verbes sont essentiels pour progresser",
                actionText: "Quiz de conjugaison",
                estimatedTime: 10,
                potentialXP: 60,
                icon: "✏️"
            ))
        }
        
        // Conversation Recommendation
        if progress.conversationsCompleted < 5 {
            recommendations.append(Recommendation(
                priority: .medium,
                category: .conversation,
                title: "Pratique les conversations",
                description: "Améliore ta compréhension avec des dialogues réels",
                actionText: "Scénarios de conversation",
                estimatedTime: 15,
                potentialXP: 80,
                icon: "💬"
            ))
        }
        
        // Daily Practice
        recommendations.append(Recommendation(
            priority: .high,
            category: .practice,
            title: "Pratique quotidienne",
            description: "Session de 20 minutes avec exercices variés",
            actionText: "Commencer la session",
            estimatedTime: 20,
            potentialXP: 150,
            icon: "💪"
        ))
        
        // Review Recommendation
        recommendations.append(Recommendation(
            priority: .medium,
            category: .review,
            title: "Révise tes acquis",
            description: "Consolide ce que tu as appris cette semaine",
            actionText: "Session de révision",
            estimatedTime: 15,
            potentialXP: 100,
            icon: "🔄"
        ))
        
        return recommendations.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    func analyzeSkillAreas(progress: UserProgress) -> ([SkillArea], [SkillArea]) {
        var areas: [SkillArea] = []
        
        // Vocabulary Skill
        let vocabScore = min(100, Double(progress.wordsLearned) / Double(progress.level.estimatedWordsToKnow) * 100)
        areas.append(SkillArea(
            name: "Vocabulaire",
            category: "Lexique",
            score: vocabScore,
            reviewCount: progress.wordsLearned,
            lastPracticed: progress.lastStudyDate,
            trend: vocabScore >= 70 ? .up : .stable
        ))
        
        // Grammar Skill
        let grammarScore = min(100, Double(progress.grammarRulesLearned) / 50.0 * 100)
        areas.append(SkillArea(
            name: "Grammaire",
            category: "Structure",
            score: grammarScore,
            reviewCount: progress.grammarRulesLearned,
            lastPracticed: progress.lastStudyDate,
            trend: grammarScore >= 60 ? .up : .down
        ))
        
        // Conjugation Skill
        let conjugationScore = min(100, Double(progress.verbsLearned) / 80.0 * 100)
        areas.append(SkillArea(
            name: "Conjugaison",
            category: "Verbes",
            score: conjugationScore,
            reviewCount: progress.verbsLearned,
            lastPracticed: progress.lastStudyDate,
            trend: conjugationScore >= 50 ? .up : .stable
        ))
        
        // Conversation Skill
        let conversationScore = min(100, Double(progress.conversationsCompleted) / 20.0 * 100)
        areas.append(SkillArea(
            name: "Conversation",
            category: "Expression orale",
            score: conversationScore,
            reviewCount: progress.conversationsCompleted,
            lastPracticed: progress.lastStudyDate,
            trend: conversationScore >= 40 ? .up : .down
        ))
        
        // Quiz Performance Skill
        let quizScore = progress.quizSuccessRate * 100
        areas.append(SkillArea(
            name: "Compréhension",
            category: "Évaluation",
            score: quizScore,
            reviewCount: progress.quizzesCompleted,
            lastPracticed: progress.lastStudyDate,
            trend: quizScore >= 75 ? .up : quizScore >= 60 ? .stable : .down
        ))
        
        // Separate strengths and weaknesses
        let strengths = areas.filter { $0.score >= 70 }.sorted { $0.score > $1.score }
        let weaknesses = areas.filter { $0.score < 70 }.sorted { $0.score < $1.score }
        
        return (strengths, weaknesses)
    }
    
    // MARK: - Study Pattern Analysis
    
    func analyzeStudyPatterns(progress: UserProgress) -> StudyPattern {
        let totalStudyTime = progress.studyTimeMinutes
        let averageSessionTime = progress.sessionsCompleted > 0 ? totalStudyTime / progress.sessionsCompleted : 0
        
        let consistency: Double
        if progress.streak >= 14 {
            consistency = 1.0
        } else if progress.streak >= 7 {
            consistency = 0.8
        } else if progress.streak >= 3 {
            consistency = 0.6
        } else {
            consistency = 0.3
        }
        
        let intensity: StudyPattern.StudyIntensity
        if averageSessionTime >= 30 {
            intensity = .high
        } else if averageSessionTime >= 15 {
            intensity = .medium
        } else {
            intensity = .low
        }
        
        return StudyPattern(
            totalStudyTime: totalStudyTime,
            averageSessionTime: averageSessionTime,
            consistency: consistency,
            intensity: intensity,
            preferredTime: nil, // À implémenter avec tracking
            optimalDuration: calculateOptimalDuration(currentAverage: averageSessionTime)
        )
    }
    
    struct StudyPattern {
        let totalStudyTime: Int
        let averageSessionTime: Int
        let consistency: Double
        let intensity: StudyIntensity
        let preferredTime: String?
        let optimalDuration: Int
        
        enum StudyIntensity: String {
            case low = "Légère"
            case medium = "Modérée"
            case high = "Intensive"
            
            var recommendation: String {
                switch self {
                case .low: return "Essaie d'augmenter progressivement ton temps d'étude"
                case .medium: return "Bon équilibre ! Continue comme ça"
                case .high: return "Excellent engagement ! N'oublie pas de faire des pauses"
                }
            }
        }
    }
    
    private func calculateOptimalDuration(currentAverage: Int) -> Int {
        // Based on research: 15-25 minutes is optimal for language learning
        if currentAverage < 10 {
            return 15
        } else if currentAverage < 20 {
            return 20
        } else if currentAverage > 30 {
            return 25
        } else {
            return currentAverage
        }
    }
    
    // MARK: - Progress Prediction
    
    func predictNextMilestone(progress: UserProgress) -> MilestonePrediction? {
        let xpToNextLevel = progress.xpToNextLevel
        let averageXPPerDay = progress.currentXP / max(1, progress.streak)
        
        guard averageXPPerDay > 0 else { return nil }
        
        let daysToNextLevel = xpToNextLevel / averageXPPerDay
        let estimatedDate = Calendar.current.date(byAdding: .day, value: daysToNextLevel, to: Date())
        
        return MilestonePrediction(
            milestone: "Niveau \(progress.level.nextLevel?.displayName ?? "Suivant")",
            estimatedDate: estimatedDate ?? Date(),
            daysRemaining: daysToNextLevel,
            confidence: calculateConfidence(streak: progress.streak)
        )
    }
    
    struct MilestonePrediction {
        let milestone: String
        let estimatedDate: Date
        let daysRemaining: Int
        let confidence: Double // 0-1
        
        var confidenceLabel: String {
            switch confidence {
            case 0.8...1.0: return "Très probable"
            case 0.6..<0.8: return "Probable"
            case 0.4..<0.6: return "Possible"
            default: return "Incertain"
            }
        }
    }
    
    private func calculateConfidence(streak: Int) -> Double {
        return min(1.0, Double(streak) / 30.0)
    }
}
