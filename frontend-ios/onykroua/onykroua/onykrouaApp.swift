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
            OnboardingData.self,
            LearningPath.self,
            DailySession.self,
            CachedUserProgress.self,
            CachedVocabWord.self,
            CachedAchievement.self,
            CachedSession.self,
            SyncOutboxItem.self,
            SyncMetadata.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ ModelContainer created successfully with sync cache schemas")
            
            Task { @MainActor in
                CloudSyncEngine.shared.configure(with: container)
                LearnedWordsManager.shared.configure(with: container)
                GamificationSyncManager.shared.configure(with: container)
                print("✅ CloudSyncEngine, LearnedWordsManager & GamificationSyncManager configured with ModelContainer")
            }
            
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
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Query private var onboardingEntries: [OnboardingData]
    @State private var forceRefresh = false
    
    var body: some View {
        Group {
            if !shouldShowMainContent {
                OnboardingContainerView()
            } else if !firebaseManager.isSignedIn {
                AuthSelectionView()
            } else {
                TodayContentView()
            }
        }
        .id(forceRefresh)
        .animation(.easeInOut, value: shouldShowMainContent)
        .animation(.easeInOut, value: firebaseManager.isSignedIn)
        .onAppear {
            checkOnboardingStatus()
        }
    }
    
    private var shouldShowMainContent: Bool {
        if let firstEntry = onboardingEntries.first {
            return firstEntry.hasCompletedOnboarding
        }
        return UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    private func checkOnboardingStatus() {
        print("📊 Auth State: \(firebaseManager.isSignedIn ? "Signed In" : "Signed Out")")
    }
}

struct AuthSelectionView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var showEmailSignIn = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("Connectez-vous")
                        .font(.largeTitle.bold())
                    Text("Synchronisez vos progrès sur tous vos appareils")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    SignInWithAppleButton {
                        // Action déjà gérée dans le bouton
                    }
                    
                    SignInWithGoogleButton {
                        // Action déjà gérée dans le bouton
                    }
                    
                    Button(action: { showEmailSignIn = true }) {
                        Label("Continuer avec Email", systemImage: "envelope.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                    
                    Button(action: {
                        Task {
                            try? await firebaseManager.signInAnonymously()
                        }
                    }) {
                        Label("Continuer en invité", systemImage: "person.fill.questionmark")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .sheet(isPresented: $showEmailSignIn) {
                EmailSignInView()
                    .environmentObject(firebaseManager)
            }
        }
    }
}
