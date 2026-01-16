import SwiftUI
import SwiftData

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(UserDefaults.Keys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @State private var isLoading = true
    @State private var showLevelAssessment = false
    @State private var gamificationManager: GamificationManager?
    
    var body: some View {
        ZStack {
            if isLoading {
                SplashScreenView()
            } else if !hasCompletedOnboarding {
                OnboardingFlowView(onComplete: {
                    hasCompletedOnboarding = true
                    showLevelAssessment = true
                })
            } else if showLevelAssessment {
                LevelAssessmentView(onComplete: { level in
                    gamificationManager?.setInitialLevel(level)
                    showLevelAssessment = false
                })
            } else {
                MainTabView()
            }
        }
        .onAppear {
            setupApp()
        }
    }
    
    private func setupApp() {
        gamificationManager = GamificationManager(modelContext: modelContext)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isLoading = false
            }
        }
    }
}

// MARK: - Splash Screen

struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("🗣️")
                    .font(.system(size: 100))
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("Onikroua")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text("Apprends l'italien facilement")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Onboarding Flow

struct OnboardingFlowView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    @State private var shouldDismiss = false
    @State private var selectedLanguage = "it"
    @State private var selectedGoals: [String] = []
    @State private var selectedLevel = CEFRLevel.a1.rawValue
    @State private var dailyMinutes = 10
    
    var body: some View {
        TabView(selection: $currentPage) {
            WelcomeScreenWrapper(onNext: { currentPage += 1 })
                .tag(0)
            
            LanguageSelectionScreenWrapper(selectedLanguage: $selectedLanguage, onNext: { currentPage += 1 })
                .tag(1)
            
            GoalsScreenWrapper(selectedGoals: $selectedGoals, onNext: { currentPage += 1 })
                .tag(2)
            
            LevelScreenWrapper(selectedLevel: $selectedLevel, onNext: { currentPage += 1 })
                .tag(3)
            
            RhythmScreenWrapper(dailyMinutes: $dailyMinutes, onNext: { currentPage += 1 })
                .tag(4)
            
            PermissionsScreenWrapper(onComplete: onComplete)
                .tag(5)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

// MARK: - Onboarding Screen Wrappers

struct WelcomeScreenWrapper: View {
    let onNext: () -> Void
    @State private var isPresented = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("🇮🇹")
                .font(.system(size: 100))
            
            VStack(spacing: 12) {
                Text("Bienvenue sur Onykroua")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text("Apprendre l'italien avec l'IA")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                OnboardingFeatureRow(icon: "book.fill", text: "15,000+ mots", color: .blue)
                OnboardingFeatureRow(icon: "mic.fill", text: "Tuteur IA vocal", color: .purple)
                OnboardingFeatureRow(icon: "gamecontroller.fill", text: "Gamification addictive", color: .orange)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Commencer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct LanguageSelectionScreenWrapper: View {
    @Binding var selectedLanguage: String
    let onNext: () -> Void
    
    var body: some View {
        LanguageSelectionScreen(selectedLanguage: $selectedLanguage)
        Button(action: onNext) {
            Text("Continuer")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
        .padding(.horizontal, 40)
    }
}

struct GoalsScreenWrapper: View {
    @Binding var selectedGoals: [String]
    let onNext: () -> Void
    
    var body: some View {
        VStack {
            GoalSelectionScreen(selectedGoals: $selectedGoals)
            Button(action: onNext) {
                Text("Continuer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedGoals.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            .disabled(selectedGoals.isEmpty)
            .padding(.horizontal, 40)
        }
    }
}

struct LevelScreenWrapper: View {
    @Binding var selectedLevel: String
    let onNext: () -> Void
    
    var body: some View {
        VStack {
            LevelSelectionScreen(selectedLevel: $selectedLevel)
            Button(action: onNext) {
                Text("Continuer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
    }
}

struct RhythmScreenWrapper: View {
    @Binding var dailyMinutes: Int
    let onNext: () -> Void
    
    var body: some View {
        VStack {
            RhythmSelectionScreen(dailyMinutes: $dailyMinutes)
            Button(action: onNext) {
                Text("Continuer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
    }
}

struct PermissionsScreenWrapper: View {
    let onComplete: () -> Void
    @State private var notificationsEnabled = false
    @State private var preferredTime: Date?
    
    var body: some View {
        PermissionsScreen(
            notificationsEnabled: $notificationsEnabled,
            preferredTime: $preferredTime,
            onComplete: onComplete
        )
    }
}

// MARK: - Level Assessment View

public struct LevelAssessmentView: View {
    public let onComplete: (CEFRLevel) -> Void
    @Environment(\.modelContext) private var modelContext
    @State private var assessmentService: LevelAssessmentService?
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [String] = []
    @State private var showResults = false
    @State private var assessedLevel: CEFRLevel = .a1
    
    public init(onComplete: @escaping (CEFRLevel) -> Void) {
        self.onComplete = onComplete
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                if showResults {
                    resultsView
                } else {
                    assessmentContent
                }
            }
            .navigationTitle("Évaluation de Niveau")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setupAssessment()
            }
        }
    }
    
    private var assessmentContent: some View {
        VStack(spacing: 24) {
            progressHeader
            
            ScrollView {
                VStack(spacing: 24) {
                    if let question = currentQuestion {
                        questionCard(question)
                        optionsGrid(question)
                    }
                    
                    nextButton
                }
                .padding()
            }
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Question \(currentQuestionIndex + 1)/\(totalQuestions)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            ProgressView(value: Double(currentQuestionIndex), total: Double(totalQuestions))
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func questionCard(_ question: LevelAssessmentService.AssessmentQuestion) -> some View {
        VStack(spacing: 16) {
            Text(question.question)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            if let context = question.context {
                Text(context)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
    
    private func optionsGrid(_ question: LevelAssessmentService.AssessmentQuestion) -> some View {
        VStack(spacing: 12) {
            ForEach(question.options, id: \.self) { option in
                Button(action: { selectAnswer(option) }) {
                    HStack {
                        Text(option)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedAnswers.indices.contains(currentQuestionIndex),
                           selectedAnswers[currentQuestionIndex] == option {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedAnswers.indices.contains(currentQuestionIndex) && selectedAnswers[currentQuestionIndex] == option ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var nextButton: some View {
        Button(action: nextQuestion) {
            Text(currentQuestionIndex < totalQuestions - 1 ? "Suivant" : "Terminer")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
        .disabled(!selectedAnswers.indices.contains(currentQuestionIndex))
        .opacity(selectedAnswers.indices.contains(currentQuestionIndex) ? 1 : 0.5)
    }
    
    private var resultsView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                Text("🎯")
                    .font(.system(size: 80))
                
                Text("Évaluation Terminée")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    Text("Ton niveau estimé")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(assessedLevel.displayName)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text(assessedLevel.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                )
            }
            
            Spacer()
            
            Button(action: { onComplete(assessedLevel) }) {
                Text("Commencer l'Apprentissage")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding()
        }
    }
    
    private var currentQuestion: LevelAssessmentService.AssessmentQuestion? {
        assessmentService?.questions[safe: currentQuestionIndex]
    }
    
    private var totalQuestions: Int {
        assessmentService?.questions.count ?? 10
    }
    
    private func setupAssessment() {
        assessmentService = LevelAssessmentService(modelContext: modelContext)
    }
    
    private func selectAnswer(_ answer: String) {
        if selectedAnswers.indices.contains(currentQuestionIndex) {
            selectedAnswers[currentQuestionIndex] = answer
        } else {
            while selectedAnswers.count <= currentQuestionIndex {
                selectedAnswers.append("")
            }
            selectedAnswers[currentQuestionIndex] = answer
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < totalQuestions - 1 {
            currentQuestionIndex += 1
        } else {
            calculateLevel()
        }
    }
    
    private func calculateLevel() {
        guard let service = assessmentService else { return }
        
        var correctCount = 0
        for (index, question) in service.questions.enumerated() {
            if selectedAnswers.indices.contains(index),
               selectedAnswers[index] == question.correctAnswer {
                correctCount += 1
            }
        }
        
        let percentage = Double(correctCount) / Double(totalQuestions)
        
        switch percentage {
        case 0.9...1.0:
            assessedLevel = .c2
        case 0.75..<0.9:
            assessedLevel = .c1
        case 0.6..<0.75:
            assessedLevel = .b2
        case 0.45..<0.6:
            assessedLevel = .b1
        case 0.3..<0.45:
            assessedLevel = .a2
        default:
            assessedLevel = .a1
        }
        
        withAnimation {
            showResults = true
        }
    }
}
