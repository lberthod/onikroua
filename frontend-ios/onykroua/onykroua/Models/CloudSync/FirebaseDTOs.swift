import Foundation

// MARK: - Firebase DTOs (Data Transfer Objects)

struct UserMetaDTO: Codable {
    let schemaVersion: Int
    let createdAt: Int64
    let lastLoginAt: Int64
    let activeDeviceId: String?
    let updatedAt: Int64
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "schemaVersion": schemaVersion,
            "createdAt": createdAt,
            "lastLoginAt": lastLoginAt,
            "updatedAt": updatedAt
        ]
        if let deviceId = activeDeviceId {
            dict["activeDeviceId"] = deviceId
        }
        return dict
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> UserMetaDTO? {
        guard let schemaVersion = dict["schemaVersion"] as? Int,
              let createdAt = dict["createdAt"] as? Int64,
              let lastLoginAt = dict["lastLoginAt"] as? Int64,
              let updatedAt = dict["updatedAt"] as? Int64 else {
            return nil
        }
        return UserMetaDTO(
            schemaVersion: schemaVersion,
            createdAt: createdAt,
            lastLoginAt: lastLoginAt,
            activeDeviceId: dict["activeDeviceId"] as? String,
            updatedAt: updatedAt
        )
    }
}

struct UserProgressDTO: Codable {
    let level: Int
    let xp: Int
    let streakDays: Int
    let longestStreak: Int
    let lastStudyAt: Int64
    let wordsLearned: Int
    let wordsReviewed: Int
    let lessonsCompleted: Int
    let quizzesCompleted: Int
    let quizzesCorrect: Int
    let conversationsCompleted: Int
    let grammarRulesLearned: Int
    let verbsLearned: Int
    let studyTimeMinutes: Int
    let sessionsCompleted: Int
    let updatedAt: Int64
    
    func toDictionary() -> [String: Any] {
        return [
            "level": level,
            "xp": xp,
            "streakDays": streakDays,
            "longestStreak": longestStreak,
            "lastStudyAt": lastStudyAt,
            "wordsLearned": wordsLearned,
            "wordsReviewed": wordsReviewed,
            "lessonsCompleted": lessonsCompleted,
            "quizzesCompleted": quizzesCompleted,
            "quizzesCorrect": quizzesCorrect,
            "conversationsCompleted": conversationsCompleted,
            "grammarRulesLearned": grammarRulesLearned,
            "verbsLearned": verbsLearned,
            "studyTimeMinutes": studyTimeMinutes,
            "sessionsCompleted": sessionsCompleted,
            "updatedAt": updatedAt
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> UserProgressDTO? {
        guard let level = dict["level"] as? Int,
              let xp = dict["xp"] as? Int,
              let streakDays = dict["streakDays"] as? Int,
              let longestStreak = dict["longestStreak"] as? Int,
              let lastStudyAt = dict["lastStudyAt"] as? Int64,
              let wordsLearned = dict["wordsLearned"] as? Int,
              let wordsReviewed = dict["wordsReviewed"] as? Int,
              let lessonsCompleted = dict["lessonsCompleted"] as? Int,
              let quizzesCompleted = dict["quizzesCompleted"] as? Int,
              let quizzesCorrect = dict["quizzesCorrect"] as? Int,
              let conversationsCompleted = dict["conversationsCompleted"] as? Int,
              let grammarRulesLearned = dict["grammarRulesLearned"] as? Int,
              let verbsLearned = dict["verbsLearned"] as? Int,
              let studyTimeMinutes = dict["studyTimeMinutes"] as? Int,
              let sessionsCompleted = dict["sessionsCompleted"] as? Int,
              let updatedAt = dict["updatedAt"] as? Int64 else {
            return nil
        }
        return UserProgressDTO(
            level: level,
            xp: xp,
            streakDays: streakDays,
            longestStreak: longestStreak,
            lastStudyAt: lastStudyAt,
            wordsLearned: wordsLearned,
            wordsReviewed: wordsReviewed,
            lessonsCompleted: lessonsCompleted,
            quizzesCompleted: quizzesCompleted,
            quizzesCorrect: quizzesCorrect,
            conversationsCompleted: conversationsCompleted,
            grammarRulesLearned: grammarRulesLearned,
            verbsLearned: verbsLearned,
            studyTimeMinutes: studyTimeMinutes,
            sessionsCompleted: sessionsCompleted,
            updatedAt: updatedAt
        )
    }
}

struct VocabWordDTO: Codable {
    let wordId: String
    let status: String
    let strength: Int
    let lastSeenAt: Int64
    let reviewCount: Int
    let correctCount: Int
    let updatedAt: Int64
    
    func toDictionary() -> [String: Any] {
        return [
            "status": status,
            "strength": strength,
            "lastSeenAt": lastSeenAt,
            "reviewCount": reviewCount,
            "correctCount": correctCount,
            "updatedAt": updatedAt
        ]
    }
    
    static func fromDictionary(wordId: String, _ dict: [String: Any]) -> VocabWordDTO? {
        guard let status = dict["status"] as? String,
              let strength = dict["strength"] as? Int,
              let lastSeenAt = dict["lastSeenAt"] as? Int64,
              let reviewCount = dict["reviewCount"] as? Int,
              let correctCount = dict["correctCount"] as? Int,
              let updatedAt = dict["updatedAt"] as? Int64 else {
            return nil
        }
        return VocabWordDTO(
            wordId: wordId,
            status: status,
            strength: strength,
            lastSeenAt: lastSeenAt,
            reviewCount: reviewCount,
            correctCount: correctCount,
            updatedAt: updatedAt
        )
    }
}

struct AchievementDTO: Codable {
    let achievementId: String
    let unlocked: Bool
    let unlockedAt: Int64?
    let progress: Int
    let updatedAt: Int64
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "unlocked": unlocked,
            "progress": progress,
            "updatedAt": updatedAt
        ]
        if let unlockedAt = unlockedAt {
            dict["unlockedAt"] = unlockedAt
        }
        return dict
    }
    
    static func fromDictionary(achievementId: String, _ dict: [String: Any]) -> AchievementDTO? {
        guard let unlocked = dict["unlocked"] as? Bool,
              let progress = dict["progress"] as? Int,
              let updatedAt = dict["updatedAt"] as? Int64 else {
            return nil
        }
        return AchievementDTO(
            achievementId: achievementId,
            unlocked: unlocked,
            unlockedAt: dict["unlockedAt"] as? Int64,
            progress: progress,
            updatedAt: updatedAt
        )
    }
}

struct SessionDTO: Codable {
    let sessionId: String
    let startedAt: Int64
    let endedAt: Int64
    let itemsCount: Int
    let correctCount: Int
    let xpGained: Int
    let activityType: String
    let updatedAt: Int64
    
    func toDictionary() -> [String: Any] {
        return [
            "startedAt": startedAt,
            "endedAt": endedAt,
            "itemsCount": itemsCount,
            "correctCount": correctCount,
            "xpGained": xpGained,
            "activityType": activityType,
            "updatedAt": updatedAt
        ]
    }
    
    static func fromDictionary(sessionId: String, _ dict: [String: Any]) -> SessionDTO? {
        guard let startedAt = dict["startedAt"] as? Int64,
              let endedAt = dict["endedAt"] as? Int64,
              let itemsCount = dict["itemsCount"] as? Int,
              let correctCount = dict["correctCount"] as? Int,
              let xpGained = dict["xpGained"] as? Int,
              let activityType = dict["activityType"] as? String,
              let updatedAt = dict["updatedAt"] as? Int64 else {
            return nil
        }
        return SessionDTO(
            sessionId: sessionId,
            startedAt: startedAt,
            endedAt: endedAt,
            itemsCount: itemsCount,
            correctCount: correctCount,
            xpGained: xpGained,
            activityType: activityType,
            updatedAt: updatedAt
        )
    }
}

struct LeaderboardEntryDTO: Codable {
    let uid: String
    let xp: Int
    let level: Int
    let username: String
    let updatedAt: Int64
    
    func toDictionary() -> [String: Any] {
        return [
            "xp": xp,
            "level": level,
            "username": username,
            "updatedAt": updatedAt
        ]
    }
    
    static func fromDictionary(uid: String, _ dict: [String: Any]) -> LeaderboardEntryDTO? {
        guard let xp = dict["xp"] as? Int,
              let level = dict["level"] as? Int,
              let username = dict["username"] as? String,
              let updatedAt = dict["updatedAt"] as? Int64 else {
            return nil
        }
        return LeaderboardEntryDTO(
            uid: uid,
            xp: xp,
            level: level,
            username: username,
            updatedAt: updatedAt
        )
    }
}

extension Date {
    static func fromMilliseconds(_ ms: Int64) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(ms) / 1000.0)
    }
    
    func toMilliseconds() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

func safeFirebaseKey(_ key: String) -> String {
    return key
        .replacingOccurrences(of: ".", with: "_")
        .replacingOccurrences(of: "$", with: "_")
        .replacingOccurrences(of: "#", with: "_")
        .replacingOccurrences(of: "[", with: "_")
        .replacingOccurrences(of: "]", with: "_")
        .replacingOccurrences(of: "/", with: "_")
        .lowercased()
}
