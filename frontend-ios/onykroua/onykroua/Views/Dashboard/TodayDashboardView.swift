import SwiftUI
import SwiftData

struct TodayDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var env: AppEnvironment
    @Query private var userProgressEntries: [UserProgress]
    
    @State private var dailySessionService: DailySessionService?
    @State private var learningPathManager: LearningPathManager?
    @State private var recommendationEngine: RecommendationEngine?
    @State private var mission: Mission?
    @State private var recommendedAction: RecommendedAction = .explore
    @State private var showReviewSession = false
    @State private var showLearningPath = false
    @State private var showVocabulary = false
    @State private var showPracticeHub = false
    @State private var showFeed = false
    @State private var showConversation = false
    @State private var showStatistics = false
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
                    
                    QuickAccessCarousel(
                        onFeed: { showFeed = true },
                        onConversation: { showConversation = true },
                        onStatistics: { showStatistics = true }
                    )
                    
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
                    
                    if let progress = userProgress {
                        MotivationSection(progress: progress)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
                AnalyticsView()
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
                Text("Prêt à apprendre?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("☀️")
                .font(.system(size: 40))
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
