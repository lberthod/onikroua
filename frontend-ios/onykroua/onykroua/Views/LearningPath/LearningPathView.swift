import SwiftUI
import SwiftData

struct LearningPathView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgressEntries: [UserProgress]
    
    @State private var learningPathManager: LearningPathManager?
    @State private var selectedChapter: Chapter?
    @State private var isLoading = true
    
    private var userProgress: UserProgress? {
        userProgressEntries.first
    }
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Chargement de votre parcours...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let progress = userProgress, let manager = learningPathManager, !manager.chapters.isEmpty {
                contentView(progress: progress, manager: manager)
            } else {
                emptyStateView
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Mon Parcours")
        .onAppear {
            setupLearningPath()
        }
        .sheet(item: $selectedChapter) { chapter in
            if let manager = learningPathManager {
                ChapterDetailView(
                    chapter: chapter,
                    learningPath: manager.learningPath,
                    onLessonComplete: { lessonId, score in
                        manager.completeLesson(lessonId: lessonId, score: score)
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private func contentView(progress: UserProgress, manager: LearningPathManager) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                ProgressHeaderCard(overview: manager.getProgressOverview())
                
                ForEach(manager.chapters) { chapter in
                    ChapterCard(
                        chapter: chapter,
                        learningPath: manager.learningPath,
                        onTap: {
                            selectedChapter = chapter
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "map.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Bienvenue sur ton parcours !")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Ton parcours d'apprentissage personnalisé sera généré en fonction de ton niveau.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { setupLearningPath() }) {
                Text("Actualiser")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func setupLearningPath() {
        guard let progress = userProgress else { 
            isLoading = false
            return 
        }
        
        if learningPathManager == nil {
            let manager = LearningPathManager(modelContext: modelContext)
            manager.initializeLearningPath(
                userId: progress.id.uuidString,
                userLevel: progress.level
            )
            learningPathManager = manager
        }
        
        isLoading = false
    }
}
