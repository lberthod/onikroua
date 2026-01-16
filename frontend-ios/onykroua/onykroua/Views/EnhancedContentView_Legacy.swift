import SwiftUI
import SwiftData

struct EnhancedContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var env: AppEnvironment
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    @State private var showProfile = false
    @State private var gamificationManager: GamificationManager?
    @State private var analyticsService: AnalyticsService?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    OfflineBanner(networkMonitor: env.networkMonitor)
                    SyncStatusView(syncManager: env.syncManager, networkMonitor: env.networkMonitor)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            headerSection
                            
                            if let manager = gamificationManager, let progress = manager.currentProgress {
                                progressSection(manager: manager, progress: progress)
                            }
                            
                            continuelearningSection
                            categoriesSection
                            practiceSection
                            achievementsPreviewSection
                        }
                        .padding(.bottom, 20)
                    }
                }
                .navigationTitle("")
                .navigationBarHidden(true)
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                
                if let manager = gamificationManager {
                    gamificationOverlays(manager: manager)
                }
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .onAppear {
            if gamificationManager == nil {
                gamificationManager = GamificationManager(modelContext: modelContext)
                analyticsService = AnalyticsService(modelContext: modelContext)
            }
            gamificationManager?.updateStreak()
            gamificationManager?.checkTimeBasedAchievements()
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ciao!")
                    .font(.title)
                    .fontWeight(.bold)
                Text(firebaseManager.userEmail ?? firebaseManager.userId ?? "Invité")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { showProfile = true }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    if let manager = gamificationManager, let progress = manager.currentProgress {
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
    
    private func progressSection(manager: GamificationManager, progress: UserProgress) -> some View {
        VStack(spacing: 16) {
            XPProgressBar(
                currentXP: progress.currentXP,
                xpRequired: progress.level.xpRequired,
                level: progress.level
            )
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                streakMiniCard(streak: progress.streak)
                
                xpMiniCard(totalXP: progress.totalXP)
                
                wordsMiniCard(wordsLearned: progress.wordsLearned)
            }
            .padding(.horizontal)
        }
    }
    
    private func streakMiniCard(streak: Int) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Text("🔥")
                    .font(.title2)
                Text("\(streak)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            Text("Streak")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func xpMiniCard(totalXP: Int) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
                Text("\(totalXP)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("XP Total")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func wordsMiniCard(wordsLearned: Int) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "book.fill")
                    .font(.title3)
                    .foregroundColor(.green)
                Text("\(wordsLearned)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("Mots")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var continuelearningSection: some View {
        VStack(spacing: 16) {
            Text("Continuer l'apprentissage")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            NavigationLink(destination: FeedView()) {
                EnhancedContinueCard()
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var categoriesSection: some View {
        VStack(spacing: 16) {
            Text("Catégories")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                NavigationLink(destination: ConjugationView()) {
                    EnhancedCategoryCard(icon: "book.fill", title: "Conjugaison", color: .blue)
                }
                
                NavigationLink(destination: VocabularyView_Enhanced()) {
                    EnhancedCategoryCard(icon: "text.book.closed.fill", title: "Vocabulaire", color: .green)
                }
                
                NavigationLink(destination: EmojiView_Enhanced()) {
                    EnhancedCategoryCard(icon: "face.smiling.fill", title: "Emoji", color: .orange)
                }
                
                NavigationLink(destination: ConversationView()) {
                    EnhancedCategoryCard(icon: "message.fill", title: "Conversation", color: .purple)
                }
                
                NavigationLink(destination: GrammarView()) {
                    EnhancedCategoryCard(icon: "text.alignleft", title: "Grammaire", color: .red)
                }
                
                NavigationLink(destination: PhoneticView()) {
                    EnhancedCategoryCard(icon: "speaker.wave.3.fill", title: "Phonétique", color: .pink)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var practiceSection: some View {
        VStack(spacing: 16) {
            Text("Pratique")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            NavigationLink(destination: GeminiLiveView()) {
                EnhancedPracticeCard(
                    icon: "mic.fill",
                    title: "Gemini Live",
                    subtitle: "Conversation avec l'IA",
                    color: .indigo
                )
            }
        }
    }
    
    private var achievementsPreviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🏆 Badges")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: AchievementsView()) {
                    Text("Voir tout")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            if let manager = gamificationManager {
                let recentAchievements = manager.getUnlockedAchievements()
                    .sorted { ($0.unlockedDate ?? Date.distantPast) > ($1.unlockedDate ?? Date.distantPast) }
                    .prefix(3)
                
                if recentAchievements.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "trophy")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("Commence à apprendre pour débloquer des badges!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(recentAchievements)) { achievement in
                                CompactAchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private func gamificationOverlays(manager: GamificationManager) -> some View {
        ZStack {
            if manager.showXPAnimation {
                XPGainAnimationView(
                    xpAmount: manager.lastXPGained,
                    isShowing: Binding(
                        get: { manager.showXPAnimation },
                        set: { manager.showXPAnimation = $0 }
                    )
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            if manager.showLevelUpModal, let progress = manager.currentProgress {
                LevelUpModalView(
                    newLevel: progress.level,
                    isShowing: Binding(
                        get: { manager.showLevelUpModal },
                        set: { manager.showLevelUpModal = $0 }
                    )
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            if manager.showAchievementModal, let achievement = manager.lastUnlockedAchievement {
                AchievementUnlockedModalView(
                    achievement: achievement,
                    isShowing: Binding(
                        get: { manager.showAchievementModal },
                        set: { manager.showAchievementModal = $0 }
                    )
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

struct CompactAchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Text(achievement.achievementType.icon)
                .font(.system(size: 32))
            
            Text(achievement.achievementType.title)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if let date = achievement.unlockedDate {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 100)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(achievement.achievementType.rarity.color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.achievementType.rarity.color, lineWidth: 2)
        )
    }
}

struct EnhancedContinueCard: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "book.pages.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Feed Éducatif")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Découvre du contenu quotidien")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct EnhancedCategoryCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct EnhancedPracticeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
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
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }
}
