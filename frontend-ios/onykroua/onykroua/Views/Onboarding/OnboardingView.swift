import SwiftUI

// MARK: - Onboarding Page Model

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @EnvironmentObject var env: AppEnvironment
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var currentPage = 0
    @State private var selectedLanguage: String = "it"
    @State private var showEmailSignIn = false
    @Binding var isPresented: Bool
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "🌍",
            title: "Bienvenue sur Onykroua",
            description: "Apprenez l'italien et l'espagnol de manière interactive et amusante",
            color: .blue
        ),
        OnboardingPage(
            icon: "🇮🇹",
            title: "15,000+ mots",
            description: "Vocabulaire riche organisé par catégories pour un apprentissage structuré",
            color: .green
        ),
        OnboardingPage(
            icon: "🎯",
            title: "Pratique interactive",
            description: "Conjugaisons, grammaire, et exercices pour progresser rapidement",
            color: .orange
        ),
        OnboardingPage(
            icon: "📊",
            title: "Suivez vos progrès",
            description: "XP, niveaux, et streaks quotidiens pour rester motivé",
            color: .purple
        ),
        OnboardingPage(
            icon: "🔊",
            title: "Prononciation native",
            description: "Écoutez la prononciation correcte de chaque mot et phrase",
            color: .red
        )
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button("Passer") {
                            completeOnboarding()
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                    }
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                    
                    // Language selection page
                    LanguageSelectionPage(selectedLanguage: $selectedLanguage)
                        .tag(pages.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Navigation buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count {
                        // Sign In with Apple button
                        SignInWithAppleButton {
                            completeOnboarding()
                        }
                        
                        // Email Sign In button
                        Button(action: { showEmailSignIn = true }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.title3)
                                Text("Continuer avec Email")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .cornerRadius(16)
                        }
                        
                        // Anonymous Sign In button
                        Button(action: signInAnonymously) {
                            HStack {
                                Image(systemName: "person.fill.questionmark")
                                    .font(.title3)
                                Text("Continuer en mode invité")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.gray)
                            .cornerRadius(16)
                        }
                        
                        // Skip button
                        Button(action: completeOnboarding) {
                            Text("Passer")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    } else {
                        // Next button
                        Button(action: nextPage) {
                            Text("Suivant")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(pages[currentPage].color)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInView()
                .environmentObject(firebaseManager)
        }
    }
    
    private func nextPage() {
        withAnimation(.spring()) {
            if currentPage < pages.count {
                currentPage += 1
            }
        }
    }
    
    private func completeOnboarding() {
        // Save that onboarding is completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Save selected language
        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
        
        withAnimation {
            isPresented = false
        }
    }
    
    private func signInAnonymously() {
        Task {
            do {
                try await firebaseManager.signInAnonymously()
                completeOnboarding()
            } catch {
                print("❌ Error signing in anonymously: \(error)")
                completeOnboarding()
            }
        }
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Text(page.icon)
                .font(.system(size: 120))
                .shadow(color: page.color.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal, 32)
            
            // Description
            Text(page.description)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Language Selection Page

struct LanguageSelectionPage: View {
    @Binding var selectedLanguage: String
    
    private let languages: [(code: String, name: String, flag: String, description: String)] = [
        ("it", "Italien", "🇮🇹", "15,000+ mots"),
        ("es", "Espagnol", "🇪🇸", "3,000+ mots")
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Title
            VStack(spacing: 12) {
                Text("🌍")
                    .font(.system(size: 80))
                
                Text("Choisissez votre langue")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("Vous pourrez en ajouter d'autres plus tard")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            // Language cards
            VStack(spacing: 16) {
                ForEach(languages, id: \.code) { language in
                    LanguageCard(
                        code: language.code,
                        name: language.name,
                        flag: language.flag,
                        description: language.description,
                        isSelected: selectedLanguage == language.code
                    ) {
                        withAnimation(.spring()) {
                            selectedLanguage = language.code
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Language Card

struct LanguageCard: View {
    let code: String
    let name: String
    let flag: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Flag
                Text(flag)
                    .font(.system(size: 48))
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isPresented: .constant(true))
    }
}
