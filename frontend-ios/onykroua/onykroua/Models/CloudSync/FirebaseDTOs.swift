import Foundation

// MARK: - Firebase DTOs (Data Transfer Objects)

// Helper to convert Any to Int64 (handles Int, Double, String)
private func toInt64(_ value: Any?) -> Int64? {
    if let int64 = value as? Int64 { return int64 }
    if let int = value as? Int { return Int64(int) }
    if let double = value as? Double { return Int64(double) }
    if let string = value as? String, let parsed = Int64(string) { return parsed }
    return nil
}

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
        guard let schemaVersion = dict["schemaVersion"] as? Int else { return nil }
        
        guard let createdAtValue = toInt64(dict["createdAt"]),
              let lastLoginAtValue = toInt64(dict["lastLoginAt"]),
              let updatedAtValue = toInt64(dict["updatedAt"]) else {
            return nil
        }
        
        return UserMetaDTO(
            schemaVersion: schemaVersion,
            createdAt: createdAtValue,
            lastLoginAt: lastLoginAtValue,
            activeDeviceId: dict["activeDeviceId"] as? String,
            updatedAt: updatedAtValue
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
        let levelValue = dict["level"] as? Int
        let xpValue = dict["xp"] as? Int
        let streakDaysValue = dict["streakDays"] as? Int
        let longestStreakValue = dict["longestStreak"] as? Int
        let lastStudyAtValue = toInt64(dict["lastStudyAt"])
        let wordsLearnedValue = dict["wordsLearned"] as? Int
        let wordsReviewedValue = dict["wordsReviewed"] as? Int
        let lessonsCompletedValue = dict["lessonsCompleted"] as? Int
        let quizzesCompletedValue = dict["quizzesCompleted"] as? Int
        let quizzesCorrectValue = dict["quizzesCorrect"] as? Int
        let conversationsCompletedValue = dict["conversationsCompleted"] as? Int
        let grammarRulesLearnedValue = dict["grammarRulesLearned"] as? Int
        let verbsLearnedValue = dict["verbsLearned"] as? Int
        let studyTimeMinutesValue = dict["studyTimeMinutes"] as? Int
        let sessionsCompletedValue = dict["sessionsCompleted"] as? Int
        let updatedAtValue = toInt64(dict["updatedAt"])
        
        guard let level = levelValue,
              let xp = xpValue,
              let streakDays = streakDaysValue,
              let longestStreak = longestStreakValue,
              let lastStudyAt = lastStudyAtValue,
              let wordsLearned = wordsLearnedValue,
              let wordsReviewed = wordsReviewedValue,
              let lessonsCompleted = lessonsCompletedValue,
              let quizzesCompleted = quizzesCompletedValue,
              let quizzesCorrect = quizzesCorrectValue,
              let conversationsCompleted = conversationsCompletedValue,
              let grammarRulesLearned = grammarRulesLearnedValue,
              let verbsLearned = verbsLearnedValue,
              let studyTimeMinutes = studyTimeMinutesValue,
              let sessionsCompleted = sessionsCompletedValue,
              let updatedAt = updatedAtValue else {
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
        let statusValue = dict["status"] as? String
        let strengthValue = dict["strength"] as? Int
        let lastSeenAtValue = toInt64(dict["lastSeenAt"])
        let reviewCountValue = dict["reviewCount"] as? Int
        let correctCountValue = dict["correctCount"] as? Int
        let updatedAtValue = toInt64(dict["updatedAt"])
        
        guard let status = statusValue,
              let strength = strengthValue,
              let lastSeenAt = lastSeenAtValue,
              let reviewCount = reviewCountValue,
              let correctCount = correctCountValue,
              let updatedAt = updatedAtValue else {
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
        let unlockedValue = dict["unlocked"] as? Bool
        let progressValue = dict["progress"] as? Int
        let updatedAtValue = toInt64(dict["updatedAt"])
        let unlockedAtValue = toInt64(dict["unlockedAt"])
        
        guard let unlocked = unlockedValue,
              let progress = progressValue,
              let updatedAt = updatedAtValue else {
            return nil
        }
        return AchievementDTO(
            achievementId: achievementId,
            unlocked: unlocked,
            unlockedAt: unlockedAtValue,
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
        let startedAtValue = toInt64(dict["startedAt"])
        let endedAtValue = toInt64(dict["endedAt"])
        let itemsCountValue = dict["itemsCount"] as? Int
        let correctCountValue = dict["correctCount"] as? Int
        let xpGainedValue = dict["xpGained"] as? Int
        let activityTypeValue = dict["activityType"] as? String
        let updatedAtValue = toInt64(dict["updatedAt"])
        
        guard let startedAt = startedAtValue,
              let endedAt = endedAtValue,
              let itemsCount = itemsCountValue,
              let correctCount = correctCountValue,
              let xpGained = xpGainedValue,
              let activityType = activityTypeValue,
              let updatedAt = updatedAtValue else {
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
        let xpValue = dict["xp"] as? Int
        let levelValue = dict["level"] as? Int
        let usernameValue = dict["username"] as? String
        let updatedAtValue = toInt64(dict["updatedAt"])
        
        guard let xp = xpValue,
              let level = levelValue,
              let username = usernameValue,
              let updatedAt = updatedAtValue else {
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
