import SwiftUI
import SwiftData
import FirebaseCore

// MARK: - App Delegate for Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        print("✅ Firebase configured via AppDelegate")
        return true
    }
}

// MARK: - Main App

@main
struct onykrouaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appEnvironment = AppEnvironment.shared
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProgress.self,
            Achievement.self,
            OnboardingData.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ ModelContainer created successfully")
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(appEnvironment)
                .environmentObject(firebaseManager)
                .modelContainer(sharedModelContainer)
        }
    }
}

struct MainAppView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var onboardingEntries: [OnboardingData]
    @State private var forceRefresh = false
    
    var body: some View {
        Group {
            if shouldShowMainContent {
                EnhancedContentView()
            } else {
                OnboardingContainerView()
            }
        }
        .id(forceRefresh)
        .animation(.easeInOut, value: shouldShowMainContent)
        .onAppear {
            checkOnboardingStatus()
        }
    }
    
    private var shouldShowMainContent: Bool {
        if let firstEntry = onboardingEntries.first {
            print("📊 Onboarding entry found in SwiftData: completed = \(firstEntry.hasCompletedOnboarding)")
            return firstEntry.hasCompletedOnboarding
        }
        
        // Fallback sur UserDefaults si SwiftData échoue
        let userDefaultsCompleted = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if userDefaultsCompleted {
            print("📊 No SwiftData entry, but UserDefaults shows onboarding completed")
            return true
        }
        
        print("📊 No onboarding entry found in SwiftData or UserDefaults")
        return false
    }
    
    private func checkOnboardingStatus() {
        print("📊 Total onboarding entries: \(onboardingEntries.count)")
        if let entry = onboardingEntries.first {
            print("📊 First entry completed: \(entry.hasCompletedOnboarding)")
        }
    }
}
