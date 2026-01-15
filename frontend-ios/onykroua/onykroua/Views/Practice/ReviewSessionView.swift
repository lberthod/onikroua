import SwiftUI
import SwiftData

struct ReviewSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reviewSystem: AdaptiveReviewSystem
    @State private var currentIndex = 0
    @State private var showAnswer = false
    @State private var reviewItems: [AdaptiveReviewSystem.ReviewItem]
    @State private var completedReviews = 0
    @State private var showResults = false
    
    init(reviewSystem: AdaptiveReviewSystem = AdaptiveReviewSystem.shared, targetCount: Int = 30) {
        _reviewSystem = State(initialValue: reviewSystem)
        _reviewItems = State(initialValue: reviewSystem.generateDailyReviewSession(targetCount: targetCount))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if showResults {
                    ReviewResultsView(
                        completedCount: completedReviews,
                        totalCount: reviewItems.count,
                        onDismiss: { dismiss() }
                    )
                } else {
                    reviewContent
                }
            }
            .navigationTitle("🔄 Révision")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Quitter") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(currentIndex + 1)/\(reviewItems.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var reviewContent: some View {
        VStack(spacing: 0) {
            progressHeader
            
            ScrollView {
                VStack(spacing: 24) {
                    if currentIndex < reviewItems.count {
                        reviewCard
                        
                        if showAnswer {
                            answerSection
                            difficultyButtons
                        } else {
                            showAnswerButton
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Progression")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(completedReviews) complétés")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: Double(currentIndex), total: Double(reviewItems.count))
                .tint(.purple)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var reviewCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text(currentItem?.type.rawValue ?? "")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(typeColor.opacity(0.2))
                    )
                    .foregroundColor(typeColor)
                
                Spacer()
                
                if let mastery = currentItem?.mastery {
                    Text(mastery.icon)
                        .font(.title3)
                }
            }
            
            Divider()
            
            VStack(spacing: 12) {
                Text("Question")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(currentItem?.content.question ?? "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            
            if let hint = currentItem?.content.hint, !showAnswer {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text("Indice: \(hint)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var answerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Réponse")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(currentItem?.content.answer ?? "")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let example = currentItem?.content.example {
                Divider()
                    .padding(.vertical, 4)
                
                HStack(spacing: 8) {
                    Image(systemName: "text.bubble.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(example)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            if let stats = currentItem {
                HStack(spacing: 16) {
                    StatLabel(
                        icon: "arrow.clockwise",
                        value: "\(stats.reviewCount)",
                        label: "Révisions"
                    )
                    
                    StatLabel(
                        icon: "percent",
                        value: "\(Int(stats.successRate * 100))%",
                        label: "Réussite"
                    )
                    
                    StatLabel(
                        icon: "calendar",
                        value: "\(stats.interval)j",
                        label: "Intervalle"
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
        )
    }
    
    private var showAnswerButton: some View {
        Button(action: {
            withAnimation {
                showAnswer = true
            }
        }) {
            HStack {
                Image(systemName: "eye.fill")
                Text("Voir la réponse")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    private var difficultyButtons: some View {
        VStack(spacing: 12) {
            Text("Comment as-tu trouvé cette révision ?")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                DifficultyButton(
                    difficulty: .veryHard,
                    label: "Très difficile",
                    icon: "😓",
                    action: { recordReview(wasCorrect: false, difficulty: .veryHard) }
                )
                
                DifficultyButton(
                    difficulty: .hard,
                    label: "Difficile",
                    icon: "😕",
                    action: { recordReview(wasCorrect: false, difficulty: .hard) }
                )
                
                DifficultyButton(
                    difficulty: .medium,
                    label: "Correct",
                    icon: "🙂",
                    action: { recordReview(wasCorrect: true, difficulty: .medium) }
                )
                
                DifficultyButton(
                    difficulty: .easy,
                    label: "Facile",
                    icon: "😊",
                    action: { recordReview(wasCorrect: true, difficulty: .easy) }
                )
                
                DifficultyButton(
                    difficulty: .veryEasy,
                    label: "Très facile",
                    icon: "😎",
                    action: { recordReview(wasCorrect: true, difficulty: .veryEasy) }
                )
            }
        }
    }
    
    private var currentItem: AdaptiveReviewSystem.ReviewItem? {
        guard currentIndex < reviewItems.count else { return nil }
        return reviewItems[currentIndex]
    }
    
    private var typeColor: Color {
        guard let type = currentItem?.type else { return .gray }
        switch type {
        case .vocabulary: return .blue
        case .conjugation: return .green
        case .grammar: return .purple
        case .conversation: return .orange
        }
    }
    
    private func recordReview(wasCorrect: Bool, difficulty: AdaptiveReviewSystem.ReviewItem.DifficultyLevel) {
        guard currentIndex < reviewItems.count else { return }
        
        reviewSystem.recordReview(
            item: &reviewItems[currentIndex],
            wasCorrect: wasCorrect,
            difficulty: difficulty
        )
        
        completedReviews += 1
        currentIndex += 1
        showAnswer = false
        
        if currentIndex >= reviewItems.count {
            withAnimation {
                showResults = true
            }
        }
    }
}

struct DifficultyButton: View {
    let difficulty: AdaptiveReviewSystem.ReviewItem.DifficultyLevel
    let label: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(icon)
                    .font(.title3)
                
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
            )
            .foregroundColor(.white)
        }
    }
    
    private var backgroundColor: Color {
        switch difficulty {
        case .veryHard: return .red
        case .hard: return .orange
        case .medium: return .yellow
        case .easy: return .green
        case .veryEasy: return .blue
        }
    }
}

struct StatLabel: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct ReviewResultsView: View {
    let completedCount: Int
    let totalCount: Int
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("🎉")
                        .font(.system(size: 80))
                    
                    Text("Session terminée !")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Tu as révisé \(completedCount) éléments")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ResultMetric(
                            icon: "checkmark.circle.fill",
                            value: "\(completedCount)",
                            label: "Révisés",
                            color: .green
                        )
                        
                        ResultMetric(
                            icon: "star.fill",
                            value: "+\(completedCount * 5)",
                            label: "XP",
                            color: .yellow
                        )
                    }
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text("💡 Conseil")
                            .font(.headline)
                        Spacer()
                    }
                    
                    Text("La répétition espacée est la clé de la mémorisation à long terme. Continue tes révisions quotidiennes !")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
                
                Button(action: onDismiss) {
                    Text("Terminer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

struct ResultMetric: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}
