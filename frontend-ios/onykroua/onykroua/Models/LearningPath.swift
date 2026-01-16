import Foundation
import SwiftData

@Model
public final class LearningPath {
    public var userId: String
    public var targetLevel: String
    public var currentChapterId: String?
    public var currentLessonId: String?
    public var chaptersCompleted: [String]
    public var lessonsCompleted: [String]
    public var lastAccessedDate: Date
    public var estimatedCompletionDate: Date?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        userId: String,
        targetLevel: CEFRLevel = .b2,
        currentChapterId: String? = nil,
        currentLessonId: String? = nil,
        chaptersCompleted: [String] = [],
        lessonsCompleted: [String] = []
    ) {
        self.userId = userId
        self.targetLevel = targetLevel.rawValue
        self.currentChapterId = currentChapterId
        self.currentLessonId = currentLessonId
        self.chaptersCompleted = chaptersCompleted
        self.lessonsCompleted = lessonsCompleted
        self.lastAccessedDate = Date()
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    public var target: CEFRLevel {
        get { CEFRLevel.fromString(targetLevel) }
        set { targetLevel = newValue.rawValue }
    }
    
    public func markLessonCompleted(_ lessonId: String) {
        if !lessonsCompleted.contains(lessonId) {
            lessonsCompleted.append(lessonId)
            updatedAt = Date()
        }
    }
    
    public func markChapterCompleted(_ chapterId: String) {
        if !chaptersCompleted.contains(chapterId) {
            chaptersCompleted.append(chapterId)
            updatedAt = Date()
        }
    }
    
    public func isLessonCompleted(_ lessonId: String) -> Bool {
        return lessonsCompleted.contains(lessonId)
    }
    
    public func isChapterCompleted(_ chapterId: String) -> Bool {
        return chaptersCompleted.contains(chapterId)
    }
}

public struct Chapter: Identifiable, Codable, Equatable {
    public let id: String
    public let level: String
    public let order: Int
    public let title: String
    public let description: String
    public let icon: String
    public let estimatedDuration: Int
    public let lessons: [Lesson]
    public let quizId: String?
    
    public init(id: String, level: String, order: Int, title: String, description: String, icon: String, estimatedDuration: Int, lessons: [Lesson], quizId: String?) {
        self.id = id
        self.level = level
        self.order = order
        self.title = title
        self.description = description
        self.icon = icon
        self.estimatedDuration = estimatedDuration
        self.lessons = lessons
        self.quizId = quizId
    }
    
    public var cefrLevel: CEFRLevel {
        CEFRLevel.fromString(level)
    }
    
    public func isUnlocked(learningPath: LearningPath) -> Bool {
        if order == 0 { return true }
        
        guard let previousChapter = getPreviousChapterId() else {
            return true
        }
        
        return learningPath.isChapterCompleted(previousChapter)
    }
    
    public func isCompleted(learningPath: LearningPath) -> Bool {
        return learningPath.isChapterCompleted(id)
    }
    
    public func progress(learningPath: LearningPath) -> Double {
        let completed = lessons.filter { learningPath.isLessonCompleted($0.id) }.count
        guard !lessons.isEmpty else { return 0 }
        return Double(completed) / Double(lessons.count)
    }
    
    private func getPreviousChapterId() -> String? {
        let parts = id.split(separator: "-")
        guard parts.count >= 2,
              let currentNumStr = parts[1].replacingOccurrences(of: "ch", with: "") as String?,
              let currentNum = Int(currentNumStr) else {
            return nil
        }
        
        if currentNum > 1 {
            return "\(parts[0])-ch\(currentNum - 1)"
        }
        return nil
    }
}

public struct Lesson: Identifiable, Codable, Equatable {
    public let id: String
    public let chapterId: String
    public let order: Int
    public let title: String
    public let description: String
    public let type: LessonType
    public let estimatedDuration: Int
    public let xpReward: Int
    public let vocabularyIds: [String]
    public let grammarRuleIds: [String]
    public let exercises: [Exercise]
    
    public init(id: String, chapterId: String, order: Int, title: String, description: String, type: LessonType, estimatedDuration: Int, xpReward: Int, vocabularyIds: [String], grammarRuleIds: [String], exercises: [Exercise]) {
        self.id = id
        self.chapterId = chapterId
        self.order = order
        self.title = title
        self.description = description
        self.type = type
        self.estimatedDuration = estimatedDuration
        self.xpReward = xpReward
        self.vocabularyIds = vocabularyIds
        self.grammarRuleIds = grammarRuleIds
        self.exercises = exercises
    }
    
    public enum LessonType: String, Codable {
        case vocabulary
        case grammar
        case conjugation
        case conversation
        case listening
        case mixed
        
        public var icon: String {
            switch self {
            case .vocabulary: return "📚"
            case .grammar: return "📖"
            case .conjugation: return "✏️"
            case .conversation: return "💬"
            case .listening: return "👂"
            case .mixed: return "🎯"
            }
        }
    }
    
    public func isUnlocked(learningPath: LearningPath) -> Bool {
        if order == 0 { return true }
        
        guard let previousLesson = getPreviousLessonId() else {
            return true
        }
        
        return learningPath.isLessonCompleted(previousLesson)
    }
    
    public func isCompleted(learningPath: LearningPath) -> Bool {
        return learningPath.isLessonCompleted(id)
    }
    
    private func getPreviousLessonId() -> String? {
        let parts = id.split(separator: "-")
        guard parts.count >= 3,
              let currentNumStr = parts[2].replacingOccurrences(of: "l", with: "") as String?,
              let currentNum = Int(currentNumStr) else {
            return nil
        }
        
        if currentNum > 1 {
            return "\(parts[0])-\(parts[1])-l\(currentNum - 1)"
        }
        return nil
    }
}

public struct Exercise: Identifiable, Codable, Equatable {
    public let id: String
    public let type: ExerciseType
    public let question: String
    public let options: [String]
    public let correctAnswer: String
    public let explanation: String
    public let hint: String?
    
    public init(id: String, type: ExerciseType, question: String, options: [String], correctAnswer: String, explanation: String, hint: String?) {
        self.id = id
        self.type = type
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.hint = hint
    }
    
    public enum ExerciseType: String, Codable {
        case multipleChoice
        case fillBlank
        case matching
        case translation
        case listening
        case speaking
        
        public var icon: String {
            switch self {
            case .multipleChoice: return "checklist"
            case .fillBlank: return "text.cursor"
            case .matching: return "link"
            case .translation: return "arrow.left.arrow.right"
            case .listening: return "ear"
            case .speaking: return "mic"
            }
        }
    }
}

public struct ProgressOverview {
    public let currentLevel: CEFRLevel
    public let chaptersCompleted: Int
    public let chaptersTotal: Int
    public let lessonsCompleted: Int
    public let lessonsTotal: Int
    public let overallProgress: Double
    public let estimatedTimeToNextLevel: Int
    
    public init(currentLevel: CEFRLevel, chaptersCompleted: Int, chaptersTotal: Int, lessonsCompleted: Int, lessonsTotal: Int, overallProgress: Double, estimatedTimeToNextLevel: Int) {
        self.currentLevel = currentLevel
        self.chaptersCompleted = chaptersCompleted
        self.chaptersTotal = chaptersTotal
        self.lessonsCompleted = lessonsCompleted
        self.lessonsTotal = lessonsTotal
        self.overallProgress = overallProgress
        self.estimatedTimeToNextLevel = estimatedTimeToNextLevel
    }
    
    public var progressPercentage: Int {
        return Int(overallProgress * 100)
    }
}
