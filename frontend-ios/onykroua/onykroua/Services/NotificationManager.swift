import Foundation
import UserNotifications
import SwiftUI

@Observable
final class NotificationManager {
    
    var isAuthorized: Bool = false
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                isAuthorized = granted
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    func scheduleDailyReminder(at hour: Int, minute: Int = 0) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🔥 Maintiens ton streak !"
        content.body = "C'est l'heure de pratiquer ton italien. Quelques minutes suffisent !"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            }
        }
    }
    
    func scheduleStreakWarning() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Attention à ton streak !"
        content.body = "Plus qu'une heure pour sauver ton streak de feu 🔥"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = 23
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "streak_warning",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling streak warning: \(error)")
            }
        }
    }
    
    func scheduleAchievementNotification(achievement: AchievementType) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🎉 Badge débloqué !"
        content.body = "\(achievement.icon) \(achievement.title) - +\(achievement.xpReward) XP"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "achievement_\(achievement.rawValue)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling achievement notification: \(error)")
            }
        }
    }
    
    func scheduleLevelUpNotification(level: CEFRLevel) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🎓 Niveau atteint !"
        content.body = "Félicitations ! Tu es maintenant niveau \(level.displayName)"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "level_up_\(level.rawValue)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling level up notification: \(error)")
            }
        }
    }
    
    func scheduleEncouragementNotification(message: String, delay: TimeInterval = 3600) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "💪 Continue comme ça !"
        content.body = message
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "encouragement_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling encouragement: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func resetBadgeCount() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
