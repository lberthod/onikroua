import Foundation
import SwiftData

@Observable
public final class DailySessionService {
    private let modelContext: ModelContext
    public var todaySession: DailySession?
    public var todayMission: Mission?
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func loadTodaySession(userId: String) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let descriptor = FetchDescriptor<DailySession>(
            predicate: #Predicate<DailySession> { session in
                session.date >= today
            }
        )
        
        if let existing = (try? modelContext.fetch(descriptor))?.first {
            todaySession = existing
        } else {
            let newSession = DailySession()
            modelContext.insert(newSession)
            todaySession = newSession
            try? modelContext.save()
        }
        
        generateTodayMission()
    }
    
    public func startNewDay(userProgress: UserProgress, reviewSystem: AdaptiveReviewSystem, learningPathManager: LearningPathManager) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let descriptor = FetchDescriptor<DailySession>(
            predicate: #Predicate<DailySession> { session in
                session.date >= today
            }
        )
        
        if let existing = (try? modelContext.fetch(descriptor))?.first {
            todaySession = existing
        } else {
            let newSession = DailySession()
            modelContext.insert(newSession)
            todaySession = newSession
            try? modelContext.save()
        }
        
        generateTodayMission()
    }
    
    public func generateTodayMission() {
        guard let session = todaySession else { return }
        
        let missions: [Mission] = [
            Mission(
                type: .review,
                title: "Révise 20 mots",
                description: "Révise 20 mots de vocabulaire pour maintenir ta mémoire",
                estimatedTime: 15,
                xpReward: 50,
                targetCount: 20
            ),
            Mission(
                type: .newLesson,
                title: "Complète une leçon",
                description: "Apprends quelque chose de nouveau aujourd'hui",
                estimatedTime: 20,
                xpReward: 100,
                targetCount: 1
            ),
            Mission(
                type: .practice,
                title: "Pratique 10 conjugaisons",
                description: "Renforce tes compétences en conjugaison",
                estimatedTime: 10,
                xpReward: 40,
                targetCount: 10
            )
        ]
        
        if !session.missionCompleted {
            todayMission = missions.randomElement()
        }
    }
    
    public func updateProgress(reviewsCompleted: Int = 0, lessonsCompleted: Int = 0, xp: Int = 0) {
        guard let session = todaySession else { return }
        
        if reviewsCompleted > 0 {
            session.reviewsCompleted += reviewsCompleted
        }
        
        if lessonsCompleted > 0 {
            session.lessonsCompleted += lessonsCompleted
        }
        
        if xp > 0 {
            session.xpEarned += xp
        }
        
        session.updatedAt = Date()
        try? modelContext.save()
        
        checkMissionCompletion()
    }
    
    private func checkMissionCompletion() {
        guard let session = todaySession, let mission = todayMission else { return }
        
        var currentProgress = 0
        
        switch mission.type {
        case .review:
            currentProgress = session.reviewsCompleted
        case .newLesson:
            currentProgress = session.lessonsCompleted
        case .practice:
            currentProgress = session.reviewsCompleted
        default:
            break
        }
        
        if currentProgress >= mission.targetCount && !session.missionCompleted {
            session.completeMission(xp: mission.xpReward)
            try? modelContext.save()
        }
    }
    
    public func getWeeklyStats() -> [DailySession] {
        let calendar = Calendar.current
        let today = Date()
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) else {
            return []
        }
        
        let descriptor = FetchDescriptor<DailySession>(
            predicate: #Predicate<DailySession> { session in
                session.date >= weekAgo
            }
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    public func getTotalXPThisWeek() -> Int {
        return getWeeklyStats().reduce(0) { $0 + $1.xpEarned }
    }
    
    public func getStreakDays() -> Int {
        let sessions = getWeeklyStats().sorted { $0.date > $1.date }
        var streak = 0
        var lastDate: Date?
        
        for session in sessions {
            if let last = lastDate {
                let calendar = Calendar.current
                let daysDiff = calendar.dateComponents([.day], from: session.date, to: last).day ?? 0
                
                if daysDiff == 1 {
                    streak += 1
                } else {
                    break
                }
            } else if session.missionCompleted {
                streak = 1
            }
            lastDate = session.date
        }
        
        return streak
    }
}
