import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPage: Int = 0
    @State private var onboardingData = OnboardingData()
    @State private var forceDismiss: Bool = false
    @State private var isCompleting: Bool = false
    
    private let totalPages = 6
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    if currentPage > 0 {
                        Button(action: { skipOnboarding() }) {
                            Text("Passer")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                
                TabView(selection: $currentPage) {
                    WelcomeScreen(isPresented: $forceDismiss)
                        .tag(0)
                    
                    LanguageSelectionScreen(selectedLanguage: $onboardingData.selectedLanguage)
                        .tag(1)
                    
                    GoalSelectionScreen(selectedGoals: $onboardingData.selectedGoals)
                        .tag(2)
                    
                    LevelSelectionScreen(selectedLevel: $onboardingData.initialLevel)
                        .tag(3)
                    
                    RhythmSelectionScreen(dailyMinutes: $onboardingData.dailyGoalMinutes)
                        .tag(4)
                    
                    PermissionsScreen(
                        notificationsEnabled: $onboardingData.notificationsEnabled,
                        preferredTime: $onboardingData.preferredStudyTime,
                        onComplete: { completeOnboarding() }
                    )
                    .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                VStack(spacing: 20) {
                    OnboardingPageIndicator(currentPage: currentPage, totalPages: totalPages)
                        .padding(.top)
                    
                    if currentPage < totalPages - 1 {
                        Button(action: nextPage) {
                            HStack {
                                Text("Suivant")
                                    .font(.headline)
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!canProceed())
                        .opacity(canProceed() ? 1.0 : 0.5)
                        .padding(.horizontal)
                    }
                    
                    if currentPage > 0 {
                        Button(action: previousPage) {
                            Text("Retour")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .onChange(of: forceDismiss) { _, newValue in
            if newValue {
                skipOnboarding()
            }
        }
    }
    
    private func canProceed() -> Bool {
        switch currentPage {
        case 0: return true
        case 1: return !onboardingData.selectedLanguage.isEmpty
        case 2: return !onboardingData.selectedGoals.isEmpty
        case 3: return !onboardingData.initialLevel.isEmpty
        case 4: return onboardingData.dailyGoalMinutes > 0
        default: return true
        }
    }
    
    private func nextPage() {
        withAnimation {
            currentPage += 1
        }
    }
    
    private func previousPage() {
        withAnimation {
            currentPage -= 1
        }
    }
    
    private func skipOnboarding() {
        guard !isCompleting else {
            print("⚠️ Onboarding skip already in progress")
            return
        }
        
        isCompleting = true
        print("⏭️ Skipping onboarding...")
        
        // Essayer de nettoyer les anciennes entrées (peut échouer si la base est corrompue)
        do {
            try modelContext.delete(model: OnboardingData.self)
            print("🗑️ Cleaned old onboarding entries")
        } catch {
            print("⚠️ Error cleaning old entries (database may be corrupted): \(error)")
        }
        
        let data = OnboardingData()
        data.hasCompletedOnboarding = true
        data.completedAt = Date()
        modelContext.insert(data)
        print("✅ Default onboarding data created")
        
        // Créer une progression par défaut
        let progress = UserProgress()
        modelContext.insert(progress)
        print("✅ Default user progress created")
        
        do {
            try modelContext.save()
            print("✅ Onboarding skipped and data saved to SwiftData")
            
            // Aussi sauvegarder dans UserDefaults comme fallback
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            UserDefaults.standard.synchronize()
            print("✅ Onboarding status saved to UserDefaults as fallback")
            
        } catch {
            print("❌ SwiftData save failed: \(error.localizedDescription)")
            print("🔄 Using UserDefaults fallback due to database corruption")
            
            // FALLBACK: Utiliser UserDefaults si SwiftData échoue
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            UserDefaults.standard.set(Date(), forKey: "onboardingCompletedAt")
            UserDefaults.standard.synchronize()
            print("✅ Onboarding status saved to UserDefaults successfully")
        }
        
        // TOUJOURS fermer l'onboarding, peu importe si la sauvegarde a réussi
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("🔄 Force dismissing onboarding view")
            dismiss()
        }
    }
    
    private func completeOnboarding() {
        guard !isCompleting else {
            print("⚠️ Onboarding completion already in progress")
            return
        }
        
        isCompleting = true
        print("🚀 Starting onboarding completion...")
        
        // Essayer de nettoyer les anciennes entrées
        do {
            try modelContext.delete(model: OnboardingData.self)
            print("🗑️ Cleaned old onboarding entries")
        } catch {
            print("⚠️ Error cleaning old entries (database may be corrupted): \(error)")
        }
        
        // Préparer les données d'onboarding
        let data = onboardingData
        data.hasCompletedOnboarding = true
        data.completedAt = Date()
        modelContext.insert(data)
        print("✅ Onboarding data prepared: language=\(data.selectedLanguage), level=\(data.initialLevel)")
        
        // Créer la progression utilisateur
        let progress = UserProgress(currentLevel: data.initialLevel.isEmpty ? CEFRLevel.a1.rawValue : data.initialLevel)
        modelContext.insert(progress)
        print("✅ User progress created")
        
        // Sauvegarder
        do {
            try modelContext.save()
            print("✅ Onboarding data saved to SwiftData")
            
            // Aussi sauvegarder dans UserDefaults comme fallback
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            UserDefaults.standard.synchronize()
            print("✅ Onboarding status saved to UserDefaults as fallback")
            
        } catch {
            print("❌ SwiftData save failed: \(error.localizedDescription)")
            print("🔄 Using UserDefaults fallback due to database corruption")
            
            // FALLBACK: Utiliser UserDefaults si SwiftData échoue
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            UserDefaults.standard.set(Date(), forKey: "onboardingCompletedAt")
            UserDefaults.standard.synchronize()
            print("✅ Onboarding status saved to UserDefaults successfully")
        }
        
        // TOUJOURS fermer l'onboarding, peu importe si la sauvegarde a réussi
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("🔄 Force dismissing onboarding view")
            dismiss()
        }
    }
}

struct OnboardingPageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }
}
