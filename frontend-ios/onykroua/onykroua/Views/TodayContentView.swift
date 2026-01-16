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
    @State private var showReviewSession = false
    @State private var reviewMode: ReviewSessionView.ReviewMode = .standard
    
    private var userProgress: UserProgress? {
        userProgressEntries.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    if let sessionService = dailySessionService,
                       let mission = sessionService.todayMission,
                       !mission.isCompleted {
                        HeroMissionCard(mission: mission, onStart: { self.startMission() })
                    } else if let recEngine = recommendationEngine,
                              let pathManager = learningPathManager,
                              let sessionService = dailySessionService {
                        HeroActionCard(
                            action: recEngine.getNextBestAction(
                                dailySessionService: sessionService,
                                learningPathManager: pathManager
                            ),
                            onStart: { self.handleAction() }
                        )
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
                    
                    if let progress = userProgress {
                        MotivationSection(progress: progress)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showReviewSession) {
                NavigationView {
                    ReviewSessionView(
                        reviewSystem: env.reviewSystem
                    )
                }
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
    
    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accès rapide")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    if let pathManager = learningPathManager {
                        NavigationLink(destination: LearningPathView()) {
                            QuickAccessCard(icon: "🎯", title: "Mon Parcours")
                        }
                    }
                    
                    NavigationLink(destination: VocabularyView_Enhanced()) {
                        QuickAccessCard(icon: "📚", title: "Vocabulaire")
                    }
                    
                    NavigationLink(destination: ConjugationView()) {
                        QuickAccessCard(icon: "📖", title: "Conjugaison")
                    }
                    
                    NavigationLink(destination: FeedView()) {
                        QuickAccessCard(icon: "📱", title: "Feed")
                    }
                    
                    NavigationLink(destination: ConversationView()) {
                        QuickAccessCard(icon: "💬", title: "Conversation")
                    }
                    
                    NavigationLink(destination: AnalyticsView()) {
                        QuickAccessCard(icon: "📊", title: "Statistiques")
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Buongiorno!"
        case 12..<18: return "Buon pomeriggio!"
        default: return "Buonasera!"
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
              let pathManager = learningPathManager else {
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
    }
    
    private func startMission() {
        guard let mission = dailySessionService?.todayMission else { return }
        
        switch mission.type {
        case .review:
            reviewMode = .standard
            showReviewSession = true
        case .newLesson:
            break
        default:
            break
        }
    }
    
    private func handleAction() {
        guard let recEngine = recommendationEngine,
              let pathManager = learningPathManager,
              let sessionService = dailySessionService else {
            return
        }
        
        let action = recEngine.getNextBestAction(
            dailySessionService: sessionService,
            learningPathManager: pathManager
        )
        
        switch action {
        case .urgentReview, .dailyMission:
            reviewMode = .intensive
            showReviewSession = true
        case .continueLesson:
            break
        case .reinforceArea:
            break
        case .explore:
            break
        }
    }
}

struct AnalyticsView: View {
    var body: some View {
        Text("Statistiques (À venir)")
            .font(.title)
            .navigationTitle("Statistiques")
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
