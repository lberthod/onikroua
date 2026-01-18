import Foundation

// MARK: - Firebase DTOs (Data Transfer Objects)
// NOTE: UserProgressDTO, VocabWordDTO, and SessionDTO have been moved to Models/DTO/
// This file now contains only DTOs out of PR#1 scope

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

// MARK: - Helper Functions

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

private func toInt64(_ value: Any?) -> Int64? {
    if let int64 = value as? Int64 { return int64 }
    if let int = value as? Int { return Int64(int) }
    if let double = value as? Double { return Int64(double) }
    if let string = value as? String, let parsed = Int64(string) { return parsed }
    return nil
}
