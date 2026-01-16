import SwiftUI
import SwiftData

struct LearningPathView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgressEntries: [UserProgress]
    
    @State private var learningPathManager: LearningPathManager?
    @State private var selectedChapter: Chapter?
    
    private var userProgress: UserProgress? {
        userProgressEntries.first
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let progress = userProgress, let manager = learningPathManager {
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
            }
            .padding()
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
    
    private func setupLearningPath() {
        guard let progress = userProgress else { return }
        
        if learningPathManager == nil {
            let manager = LearningPathManager(modelContext: modelContext)
            manager.initializeLearningPath(
                userId: progress.id.uuidString,
                userLevel: progress.level
            )
            learningPathManager = manager
        }
    }
}
