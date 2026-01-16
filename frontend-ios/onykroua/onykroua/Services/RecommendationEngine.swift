import Foundation
import SwiftUI
import SwiftData

@Observable
public final class RecommendationEngine {
    private let modelContext: ModelContext
    private var userProgress: UserProgress?
    private var learningPath: LearningPath?
    private let reviewSystem: AdaptiveReviewSystem
    
    public init(modelContext: ModelContext, reviewSystem: AdaptiveReviewSystem) {
        self.modelContext = modelContext
        self.reviewSystem = reviewSystem
    }
    
    public func loadUserData(progress: UserProgress, path: LearningPath?) {
        self.userProgress = progress
        self.learningPath = path
    }
    
    public func getRecommendedContent(
        type: RecommendedContent.ContentType,
        limit: Int = 20
    ) -> [RecommendedContent] {
        guard let progress = userProgress else { return [] }
        
        let userLevel = progress.level
        var recommendations: [RecommendedContent] = []
        
        switch type {
        case .vocabulary:
            recommendations = getVocabularyRecommendations(level: userLevel, limit: limit)
        case .grammar:
            recommendations = getGrammarRecommendations(level: userLevel, limit: limit)
        case .lesson:
            recommendations = getLessonRecommendations(level: userLevel, limit: limit)
        default:
            break
        }
        
        return recommendations.sorted { $0.relevanceScore > $1.relevanceScore }
    }
    
    private func getVocabularyRecommendations(level: CEFRLevel, limit: Int) -> [RecommendedContent] {
        return []
    }
    
    private func getGrammarRecommendations(level: CEFRLevel, limit: Int) -> [RecommendedContent] {
        return []
    }
    
    private func getLessonRecommendations(level: CEFRLevel, limit: Int) -> [RecommendedContent] {
        return []
    }
    
    public func identifyWeakAreas() -> [ContentArea] {
        guard let progress = userProgress else { return [] }
        
        var weakAreas: [ContentArea] = []
        
        if progress.quizSuccessRate < 0.7 {
            weakAreas.append(.general)
        }
        
        let stats = reviewSystem.getStatistics()
        if stats.averageSuccessRate < 0.7 {
            weakAreas.append(.vocabulary)
        }
        
        return weakAreas
    }
    
    public func getNextBestAction(
        dailySessionService: DailySessionService,
        learningPathManager: LearningPathManager
    ) -> RecommendedAction {
        let dueCount = reviewSystem.getDueItemsCount()
        let urgentCount = reviewSystem.getUrgentItemsCount()
        
        if urgentCount > 20 {
            return .urgentReview(count: urgentCount)
        }
        
        if let mission = dailySessionService.todayMission, !mission.isCompleted {
            return .dailyMission(mission)
        }
        
        if dueCount > 10 {
            return .urgentReview(count: dueCount)
        }
        
        if let nextLesson = learningPathManager.getNextRecommendedLesson() {
            return .continueLesson(nextLesson)
        }
        
        let weakAreas = identifyWeakAreas()
        if let weakest = weakAreas.first {
            return .reinforceArea(weakest)
        }
        
        return .explore
    }
    
    public func filterFeedItems(items: [FeedItem], userLevel: CEFRLevel) -> [FeedItem] {
        return items.filter { item in
            guard let difficulty = item.difficulty else { return true }
            return difficulty.isAppropriateFor(userLevel)
        }
    }
    
    public func getSuccessRate(for area: ContentArea) -> Double {
        let stats = reviewSystem.getStatistics()
        return stats.averageSuccessRate
    }
}

extension CEFRLevel {
    public func isAppropriateFor(_ userLevel: CEFRLevel) -> Bool {
        let levelIndex = CEFRLevel.allCases.firstIndex(of: self) ?? 0
        let userIndex = CEFRLevel.allCases.firstIndex(of: userLevel) ?? 0
        return abs(levelIndex - userIndex) <= 1
    }
}

extension FeedItem {
    public var difficulty: CEFRLevel? {
        switch type {
        case .vocabulary:
            return .a2
        case .conjugation:
            return .b1
        case .expression:
            return .a2
        case .culture:
            return .b2
        case .quiz:
            return .b1
        }
    }
}
