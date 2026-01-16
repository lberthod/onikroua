import SwiftUI

public struct ProgressHeaderCard: View {
    public let overview: ProgressOverview
    
    public init(overview: ProgressOverview) {
        self.overview = overview
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Niveau actuel")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(overview.currentLevel.displayName)
                        .font(.title2.bold())
                }
                Spacer()
                Text(overview.currentLevel.icon)
                    .font(.system(size: 40))
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Progression globale")
                        .font(.caption.bold())
                    Spacer()
                    Text("\(overview.progressPercentage)%")
                        .font(.caption)
                }
                ProgressView(value: overview.overallProgress)
                    .tint(overview.currentLevel.color)
            }
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(overview.lessonsCompleted)")
                        .font(.headline)
                    Text("Leçons")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider().frame(height: 20)
                
                VStack {
                    Text("\(overview.chaptersCompleted)")
                        .font(.headline)
                    Text("Chapitres")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider().frame(height: 20)
                
                VStack {
                    Text("\(overview.estimatedTimeToNextLevel)h")
                        .font(.headline)
                    Text("Restant")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

public struct ChapterCard: View {
    public let chapter: Chapter
    public let learningPath: LearningPath?
    public let onTap: () -> Void
    
    public init(chapter: Chapter, learningPath: LearningPath?, onTap: @escaping () -> Void) {
        self.chapter = chapter
        self.learningPath = learningPath
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(chapter.icon)
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(chapter.title)
                            .font(.headline)
                        Text(chapter.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if let path = learningPath, chapter.isCompleted(learningPath: path) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if let path = learningPath, !chapter.isUnlocked(learningPath: path) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.secondary)
                    }
                }
                
                if let path = learningPath {
                    let progress = chapter.progress(learningPath: path)
                    ProgressView(value: progress)
                        .tint(.blue)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(learningPath.map { !chapter.isUnlocked(learningPath: $0) } ?? true)
    }
}

public struct ChapterDetailView: View {
    public let chapter: Chapter
    public let learningPath: LearningPath?
    public let onLessonComplete: (String, Double) -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(chapter: Chapter, learningPath: LearningPath?, onLessonComplete: @escaping (String, Double) -> Void) {
        self.chapter = chapter
        self.learningPath = learningPath
        self.onLessonComplete = onLessonComplete
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(chapter.title)
                            .font(.title2.bold())
                        Text(chapter.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Leçons") {
                    ForEach(chapter.lessons) { lesson in
                        HStack {
                            Text(lesson.type.icon)
                                .font(.title2)
                                .frame(width: 40)
                            
                            VStack(alignment: .leading) {
                                Text(lesson.title)
                                    .font(.headline)
                                Text("\(lesson.estimatedDuration) min • \(lesson.xpReward) XP")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if let path = learningPath, path.isLessonCompleted(lesson.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else if let path = learningPath, !lesson.isUnlocked(learningPath: path) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.secondary)
                            } else {
                                Button("Start") {
                                    // Simulation de complétion pour le test
                                    onLessonComplete(lesson.id, 1.0)
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Chapitre \(chapter.order + 1)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}
