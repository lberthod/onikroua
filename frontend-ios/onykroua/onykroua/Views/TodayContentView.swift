import SwiftUI
import SwiftData

struct TodayContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var env: AppEnvironment
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Query private var userProgressEntries: [UserProgress]
    
    @State private var showProfile = false
    @State private var dailySessionService: DailySessionService?
    @State private var learningPathManager: LearningPathManager?
    @State private var recommendationEngine: RecommendationEngine?
    @State private var mission: Mission?
    @State private var recommendedAction: RecommendedAction = .explore
    @State private var showReviewSession = false
    @State private var showLearningPath = false
    @State private var showVocabulary = false
    @State private var showConjugation = false
    @State private var showPracticeHub = false
    @State private var showFeed = false
    @State private var showConversation = false
    @State private var showStatistics = false
    @State private var showQuiz = false
    @State private var showEmoji = false
    @State private var showGrammar = false
    @State private var showPhonetic = false
    @State private var showGeminiLive = false
    @State private var showAchievements = false
    @State private var reviewMode: ReviewSessionView.ReviewMode = .standard
    
    private var userProgress: UserProgress? {
        userProgressEntries.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    if let mission = mission, !mission.isCompleted {
                        HeroMissionCard(mission: mission, onStart: { self.startMission() })
                    } else {
                        HeroActionCard(action: recommendedAction, onStart: { self.handleAction() })
                    }
                    
                    if let progress = userProgress {
                        CompactProgressSection(progress: progress)
                    }
                    
                    if env.reviewSystem.getDueItemsCount() > 0 {
                        ReviewReminderCard(
                            dueCount: env.reviewSystem.getDueItemsCount(),
                            onTap: {
                                reviewMode = .standard
                                showReviewSession = true
                            }
                        )
                    }
                    
                    quickAccessSection
                    
                    learningCategoriesSection
                    
                    practiceToolsSection
                    
                    if let progress = userProgress {
                        MotivationSection(progress: progress)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showReviewSession) {
                NavigationStack {
                    ReviewSessionView(reviewSystem: env.reviewSystem)
                }
            }
            .navigationDestination(isPresented: $showLearningPath) {
                LearningPathView()
            }
            .navigationDestination(isPresented: $showVocabulary) {
                VocabularyView_Enhanced()
            }
            .navigationDestination(isPresented: $showConjugation) {
                ConjugationView()
            }
            .navigationDestination(isPresented: $showPracticeHub) {
                PracticeHubView(language: "it")
            }
            .navigationDestination(isPresented: $showFeed) {
                FeedView()
            }
            .navigationDestination(isPresented: $showConversation) {
                ConversationView()
            }
            .navigationDestination(isPresented: $showStatistics) {
                InsightsView()
            }
            .navigationDestination(isPresented: $showQuiz) {
                QuizSelectionView(language: "it")
            }
            .navigationDestination(isPresented: $showEmoji) {
                EmojiView_Enhanced()
            }
            .navigationDestination(isPresented: $showGrammar) {
                GrammarView()
            }
            .navigationDestination(isPresented: $showPhonetic) {
                PhoneticView()
            }
            .navigationDestination(isPresented: $showGeminiLive) {
                GeminiLiveView()
            }
            .navigationDestination(isPresented: $showAchievements) {
                AchievementsView()
            }
            .onAppear {
                setupServices()
                loadDailyContent()
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingMessage)
                    .font(.title)
                    .fontWeight(.bold)
                Text(firebaseManager.userEmail ?? "Prêt à apprendre?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { showProfile = true }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    if let progress = userProgress {
                        Text(progress.level.icon)
                            .font(.caption)
                            .offset(x: 5, y: -5)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Buongiorno!"
        case 12..<18: return "Buon pomeriggio!"
        default: return "Buonasera!"
        }
    }
    
    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accès rapide")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickAccessButton(icon: "target", title: "Mon Parcours", color: .red) {
                        showLearningPath = true
                    }
                    QuickAccessButton(icon: "book.fill", title: "Vocabulaire", color: .green) {
                        showVocabulary = true
                    }
                    QuickAccessButton(icon: "book.closed.fill", title: "Conjugaison", color: .blue) {
                        showConjugation = true
                    }
                    QuickAccessButton(icon: "flame.fill", title: "Feed", color: .orange) {
                        showFeed = true
                    }
                    QuickAccessButton(icon: "trophy.fill", title: "Succès", color: .yellow) {
                        showAchievements = true
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var learningCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Catégories d'apprentissage")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                DashboardCategoryButton(icon: "face.smiling.fill", title: "Emoji", color: Color.orange) {
                    showEmoji = true
                }
                DashboardCategoryButton(icon: "message.fill", title: "Conversation", color: Color.purple) {
                    showConversation = true
                }
                DashboardCategoryButton(icon: "text.alignleft", title: "Grammaire", color: Color.red) {
                    showGrammar = true
                }
                DashboardCategoryButton(icon: "speaker.wave.3.fill", title: "Phonétique", color: Color.pink) {
                    showPhonetic = true
                }
                                DashboardCategoryButton(icon: "flame.fill", title: "Feed", color: Color.yellow) {
                    showFeed = true
                }
                                DashboardCategoryButton(icon: "book.closed.fill", title: "Conjugaison", color: Color.green) {
                    showConjugation = true
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var practiceToolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Outils de pratique")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                PracticeToolCard(
                    icon: "gamecontroller.fill",
                    title: "Quiz Interactif",
                    subtitle: "Teste tes connaissances",
                    color: .blue
                ) {
                    showQuiz = true
                }
                
                PracticeToolCard(
                    icon: "brain.head.profile",
                    title: "Hub de Pratique",
                    subtitle: "Flashcards, exercices et plus",
                    color: .green
                ) {
                    showPracticeHub = true
                }
                
                PracticeToolCard(
                    icon: "mic.fill",
                    title: "Gemini Live",
                    subtitle: "Conversation avec l'IA",
                    color: .indigo
                ) {
                    showGeminiLive = true
                }
                
                PracticeToolCard(
                    icon: "chart.bar.fill",
                    title: "Statistiques",
                    subtitle: "Analyse tes progrès",
                    color: .cyan
                ) {
                    showStatistics = true
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func setupServices() {
        if dailySessionService == nil {
            dailySessionService = DailySessionService(modelContext: modelContext)
            learningPathManager = LearningPathManager(modelContext: modelContext)
            recommendationEngine = RecommendationEngine(
                modelContext: modelContext,
                reviewSystem: env.reviewSystem
            )
        }
    }
    
    private func loadDailyContent() {
        guard let progress = userProgress,
              let sessionService = dailySessionService,
              let pathManager = learningPathManager,
              let recEngine = recommendationEngine else {
            return
        }
        
        pathManager.initializeLearningPath(
            userId: progress.id.uuidString,
            userLevel: progress.level
        )
        
        sessionService.startNewDay(
            userProgress: progress,
            reviewSystem: env.reviewSystem,
            learningPathManager: pathManager
        )
        
        mission = sessionService.todayMission
        
        recommendedAction = recEngine.getNextBestAction(
            dailySessionService: sessionService,
            learningPathManager: pathManager
        )
    }
    
    private func startMission() {
        guard let mission = mission else { return }
        
        switch mission.type {
        case .review:
            reviewMode = .standard
            showReviewSession = true
        case .newLesson:
            showLearningPath = true
        default:
            showPracticeHub = true
        }
    }
    
    private func handleAction() {
        switch recommendedAction {
        case .urgentReview, .dailyMission:
            reviewMode = .intensive
            showReviewSession = true
        case .continueLesson:
            showLearningPath = true
        case .reinforceArea:
            showPracticeHub = true
        case .explore:
            showVocabulary = true
        }
    }
}


struct QuickAccessCard: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 30))
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(width: 120, height: 100)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct QuickAccessButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(color)
                    .cornerRadius(12)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 90)
        }
        .buttonStyle(.plain)
    }
}

struct DashboardCategoryButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct PracticeToolCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(color)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
