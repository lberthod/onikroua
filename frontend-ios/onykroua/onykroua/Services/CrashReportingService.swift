import Foundation
import os.log

// MARK: - Crash Reporting Service
// Note: This is a native implementation. For production, consider adding Firebase Crashlytics.
// To add Firebase: pod 'Firebase/Crashlytics' or Swift Package Manager

class CrashReportingService {
    static let shared = CrashReportingService()
    
    private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "onykroua", category: "CrashReporting")
    private var errorLog: [ErrorEntry] = []
    
    struct ErrorEntry {
        let timestamp: Date
        let message: String
        let context: [String: Any]
        let severity: Severity
    }
    
    enum Severity: String {
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case fatal = "FATAL"
    }
    
    private init() {}
    
    // MARK: - Initialization
    
    func configure() {
        print("✅ Native crash reporting configured")
        print("💡 For production: Add Firebase Crashlytics via CocoaPods or SPM")
    }
    
    // MARK: - Error Reporting
    
    func reportError(_ error: Error, context: [String: Any]? = nil) {
        let entry = ErrorEntry(
            timestamp: Date(),
            message: error.localizedDescription,
            context: context ?? [:],
            severity: .error
        )
        
        errorLog.append(entry)
        
        // Log to system console
        os_log(.error, log: logger, "Error: %{public}@", error.localizedDescription)
        
        // Keep only last 100 errors
        if errorLog.count > 100 {
            errorLog.removeFirst()
        }
        
        print("🔥 Error reported: \(error.localizedDescription)")
        if let ctx = context {
            print("   Context: \(ctx)")
        }
    }
    
    func reportCustomError(message: String, context: [String: Any]? = nil) {
        let entry = ErrorEntry(
            timestamp: Date(),
            message: message,
            context: context ?? [:],
            severity: .error
        )
        
        errorLog.append(entry)
        
        os_log(.error, log: logger, "Custom error: %{public}@", message)
        
        if errorLog.count > 100 {
            errorLog.removeFirst()
        }
        
        print("🔥 Custom error reported: \(message)")
    }
    
    // MARK: - User Information
    
    private var userId: String?
    private var userProperties: [String: String] = [:]
    private var customValues: [String: Any] = [:]
    
    func setUserId(_ userId: String) {
        self.userId = userId
        os_log(.info, log: logger, "User ID set: %{public}@", userId)
        print("👤 User ID set: \(userId)")
    }
    
    func setUserProperty(_ value: String, forKey key: String) {
        userProperties[key] = value
        os_log(.info, log: logger, "User property: %{public}@ = %{public}@", key, value)
        print("🏷️ User property set: \(key) = \(value)")
    }
    
    // MARK: - Custom Keys
    
    func setCustomValue(_ value: Any, forKey key: String) {
        customValues[key] = value
        os_log(.info, log: logger, "Custom value: %{public}@", key)
        print("🔑 Custom value set: \(key) = \(value)")
    }
    
    // MARK: - Logging
    
    func log(_ message: String) {
        os_log(.info, log: logger, "%{public}@", message)
        print("📝 Logged: \(message)")
    }
    
    // MARK: - Debug Methods
    
    func testCrash() {
        #if DEBUG
        print("⚠️ Test crash disabled in native implementation")
        print("💡 Add Firebase Crashlytics for crash testing")
        #endif
    }
    
    func testException() {
        #if DEBUG
        let testError = NSError(
            domain: "OnykrouaApp",
            code: 999,
            userInfo: [NSLocalizedDescriptionKey: "Test exception"]
        )
        reportError(testError, context: ["test": true])
        print("💥 Test exception logged")
        #endif
    }
    
    // MARK: - Error Log Access
    
    func getRecentErrors(limit: Int = 20) -> [ErrorEntry] {
        return Array(errorLog.suffix(limit))
    }
    
    func clearErrorLog() {
        errorLog.removeAll()
        print("🗑️ Error log cleared")
    }
    
    func exportErrorLog() -> String {
        var output = "# Error Log Export\n"
        output += "Generated: \(Date())\n\n"
        
        if let userId = userId {
            output += "User ID: \(userId)\n"
        }
        
        output += "\n## Errors (\(errorLog.count))\n\n"
        
        for entry in errorLog {
            output += "### [\(entry.severity.rawValue)] \(entry.timestamp)\n"
            output += "Message: \(entry.message)\n"
            if !entry.context.isEmpty {
                output += "Context: \(entry.context)\n"
            }
            output += "\n"
        }
        
        return output
    }
}

// MARK: - Error Manager Integration

extension ErrorManager {
    func reportToCrashlytics() {
        if let error = currentError {
            CrashReportingService.shared.reportError(error, context: [
                "hasRetryAction": hasRetryAction,
                "showError": showError
            ])
        }
    }
}

// MARK: - App Environment Integration

extension AppEnvironment {
    func setupCrashReporting() {
        CrashReportingService.shared.configure()
        
        // Set user info - using default user ID for now
        CrashReportingService.shared.setUserId("default_user")
        
        // Set app version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            CrashReportingService.shared.setCustomValue(version, forKey: "app_version")
        }
        
        // Set build number
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            CrashReportingService.shared.setCustomValue(build, forKey: "build_number")
        }
        
        // Set user stats
        CrashReportingService.shared.setCustomValue(progressTracker.totalXP, forKey: "total_xp")
        CrashReportingService.shared.setCustomValue(progressTracker.wordsLearned.count, forKey: "words_learned")
        
        print("✅ Crash reporting integrated with AppEnvironment")
    }
}
