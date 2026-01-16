import Foundation
import SwiftUI
import SwiftData

@Observable
public final class LearningPathManager {
    private let modelContext: ModelContext
    public var learningPath: LearningPath?
    public var chapters: [Chapter] = []
    public var currentLesson: Lesson?
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func initializeLearningPath(userId: String, userLevel: CEFRLevel) {
        let descriptor = FetchDescriptor<LearningPath>(
            predicate: #Predicate<LearningPath> { $0.userId == userId }
        )
        
        if let existing = (try? modelContext.fetch(descriptor))?.first {
            learningPath = existing
        } else {
            let newPath = LearningPath(userId: userId, targetLevel: userLevel)
            modelContext.insert(newPath)
            learningPath = newPath
            try? modelContext.save()
        }
        
        loadChapters(for: userLevel)
    }
    
    public func loadChapters(for level: CEFRLevel) {
        chapters = LearningPathData.getChapters(for: level)
    }
    
    public func getNextRecommendedLesson() -> Lesson? {
        guard let path = learningPath else { return nil }
        
        for chapter in chapters {
            if !chapter.isUnlocked(learningPath: path) {
                continue
            }
            
            for lesson in chapter.lessons {
                if !lesson.isCompleted(learningPath: path) && lesson.isUnlocked(learningPath: path) {
                    return lesson
                }
            }
        }
        
        return nil
    }
    
    public func completeLesson(lessonId: String, score: Double) {
        guard let path = learningPath else { return }
        
        if score >= 0.8 {
            path.markLessonCompleted(lessonId)
            path.currentLessonId = lessonId
            path.updatedAt = Date()
            
            if let lesson = findLesson(by: lessonId) {
                _ = checkChapterCompletion(chapterId: lesson.chapterId)
            }
            
            try? modelContext.save()
        }
    }
    
    public func checkChapterCompletion(chapterId: String) -> Bool {
        guard let path = learningPath,
              let chapter = chapters.first(where: { $0.id == chapterId }) else {
            return false
        }
        
        let allLessonsCompleted = chapter.lessons.allSatisfy { lesson in
            path.isLessonCompleted(lesson.id)
        }
        
        if allLessonsCompleted && !path.isChapterCompleted(chapterId) {
            path.markChapterCompleted(chapterId)
            path.currentChapterId = chapterId
            unlockNextChapter(currentChapterId: chapterId)
            try? modelContext.save()
            return true
        }
        
        return false
    }
    
    public func unlockNextChapter(currentChapterId: String) {
        guard let currentIndex = chapters.firstIndex(where: { $0.id == currentChapterId }),
              currentIndex + 1 < chapters.count else {
            return
        }
    }
    
    public func getProgressOverview() -> ProgressOverview {
        guard let path = learningPath else {
            return ProgressOverview(
                currentLevel: .a1,
                chaptersCompleted: 0,
                chaptersTotal: 0,
                lessonsCompleted: 0,
                lessonsTotal: 0,
                overallProgress: 0,
                estimatedTimeToNextLevel: 0
            )
        }
        
        let totalLessons = chapters.reduce(0) { $0 + $1.lessons.count }
        let completedLessons = path.lessonsCompleted.count
        
        let progress = totalLessons > 0 ? Double(completedLessons) / Double(totalLessons) : 0
        let remainingLessons = totalLessons - completedLessons
        let estimatedTime = remainingLessons * 15
        
        return ProgressOverview(
            currentLevel: path.target,
            chaptersCompleted: path.chaptersCompleted.count,
            chaptersTotal: chapters.count,
            lessonsCompleted: completedLessons,
            lessonsTotal: totalLessons,
            overallProgress: progress,
            estimatedTimeToNextLevel: estimatedTime / 60
        )
    }
    
    public func findLesson(by id: String) -> Lesson? {
        for chapter in chapters {
            if let lesson = chapter.lessons.first(where: { $0.id == id }) {
                return lesson
            }
        }
        return nil
    }
    
    public func findChapter(by id: String) -> Chapter? {
        return chapters.first(where: { $0.id == id })
    }
    
    public func resetProgress() {
        guard let path = learningPath else { return }
        path.lessonsCompleted.removeAll()
        path.chaptersCompleted.removeAll()
        path.currentLessonId = nil
        path.currentChapterId = nil
        path.updatedAt = Date()
        try? modelContext.save()
    }
}

public struct LearningPathData {
    public static func getChapters(for level: CEFRLevel) -> [Chapter] {
        switch level {
        case .a1:
            return italianA1Chapters
        case .a2:
            return italianA2Chapters
        default:
            return italianA1Chapters
        }
    }
    
    private static let italianA1Chapters: [Chapter] = [
        Chapter(
            id: "a1-ch1",
            level: "A1",
            order: 0,
            title: "Se présenter",
            description: "Apprends les bases pour te présenter et saluer en italien",
            icon: "👋",
            estimatedDuration: 45,
            lessons: [
                Lesson(
                    id: "a1-ch1-l1",
                    chapterId: "a1-ch1",
                    order: 0,
                    title: "Salutations",
                    description: "Les salutations essentielles",
                    type: .vocabulary,
                    estimatedDuration: 10,
                    xpReward: 20,
                    vocabularyIds: ["ciao", "buongiorno", "buonasera", "arrivederci", "salve"],
                    grammarRuleIds: [],
                    exercises: []
                ),
                Lesson(
                    id: "a1-ch1-l2",
                    chapterId: "a1-ch1",
                    order: 1,
                    title: "Se présenter",
                    description: "Dire son nom et sa nationalité",
                    type: .conversation,
                    estimatedDuration: 15,
                    xpReward: 30,
                    vocabularyIds: ["nome", "cognome", "nazionalità"],
                    grammarRuleIds: ["essere-present"],
                    exercises: []
                ),
                Lesson(
                    id: "a1-ch1-l3",
                    chapterId: "a1-ch1",
                    order: 2,
                    title: "Les nombres 1-20",
                    description: "Apprends à compter jusqu'à 20",
                    type: .vocabulary,
                    estimatedDuration: 10,
                    xpReward: 20,
                    vocabularyIds: Array(1...20).map { "number_\($0)" },
                    grammarRuleIds: [],
                    exercises: []
                ),
                Lesson(
                    id: "a1-ch1-l4",
                    chapterId: "a1-ch1",
                    order: 3,
                    title: "Phrases essentielles",
                    description: "Les phrases de base du quotidien",
                    type: .mixed,
                    estimatedDuration: 10,
                    xpReward: 25,
                    vocabularyIds: ["grazie", "prego", "scusa", "per_favore"],
                    grammarRuleIds: [],
                    exercises: []
                )
            ],
            quizId: "a1-ch1-quiz"
        ),
        Chapter(
            id: "a1-ch2",
            level: "A1",
            order: 1,
            title: "La famille et les amis",
            description: "Vocabulaire sur la famille et les relations",
            icon: "👨‍👩‍👧‍👦",
            estimatedDuration: 60,
            lessons: [
                Lesson(
                    id: "a1-ch2-l1",
                    chapterId: "a1-ch2",
                    order: 0,
                    title: "Les membres de la famille",
                    description: "Padre, madre, fratello, sorella...",
                    type: .vocabulary,
                    estimatedDuration: 15,
                    xpReward: 25,
                    vocabularyIds: ["padre", "madre", "fratello", "sorella", "nonno", "nonna"],
                    grammarRuleIds: [],
                    exercises: []
                ),
                Lesson(
                    id: "a1-ch2-l2",
                    chapterId: "a1-ch2",
                    order: 1,
                    title: "Décrire sa famille",
                    description: "Phrases pour parler de sa famille",
                    type: .conversation,
                    estimatedDuration: 20,
                    xpReward: 30,
                    vocabularyIds: [],
                    grammarRuleIds: ["avere-present", "possessives"],
                    exercises: []
                )
            ],
            quizId: "a1-ch2-quiz"
        ),
        Chapter(
            id: "a1-ch3",
            level: "A1",
            order: 2,
            title: "Vie quotidienne",
            description: "Expressions pour les activités du quotidien",
            icon: "🏠",
            estimatedDuration: 50,
            lessons: [
                Lesson(
                    id: "a1-ch3-l1",
                    chapterId: "a1-ch3",
                    order: 0,
                    title: "Les activités quotidiennes",
                    description: "Manger, dormir, travailler...",
                    type: .vocabulary,
                    estimatedDuration: 15,
                    xpReward: 25,
                    vocabularyIds: ["mangiare", "dormire", "lavorare", "studiare"],
                    grammarRuleIds: ["present-regular-are"],
                    exercises: []
                )
            ],
            quizId: "a1-ch3-quiz"
        )
    ]
    
    private static let italianA2Chapters: [Chapter] = [
        Chapter(
            id: "a2-ch1",
            level: "A2",
            order: 0,
            title: "Voyages et loisirs",
            description: "Vocabulaire pour voyager et parler de ses hobbies",
            icon: "✈️",
            estimatedDuration: 70,
            lessons: [
                Lesson(
                    id: "a2-ch1-l1",
                    chapterId: "a2-ch1",
                    order: 0,
                    title: "À l'aéroport",
                    description: "Vocabulaire essentiel pour voyager",
                    type: .vocabulary,
                    estimatedDuration: 20,
                    xpReward: 30,
                    vocabularyIds: ["aeroporto", "volo", "biglietto", "valigia"],
                    grammarRuleIds: [],
                    exercises: []
                )
            ],
            quizId: "a2-ch1-quiz"
        )
    ]
}
