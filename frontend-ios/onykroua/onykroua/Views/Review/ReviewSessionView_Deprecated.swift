import SwiftUI
import SwiftData

struct ReviewSessionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var reviewSystem: AdaptiveReviewSystem
    
    @State private var currentIndex = 0
    @State private var showAnswer = false
    @State private var sessionItems: [AdaptiveReviewSystem.ReviewItem] = []
    @State private var correctCount = 0
    @State private var incorrectCount = 0
    @State private var startTime = Date()
    @State private var sessionCompleted = false
    @State private var selectedDifficulty: AdaptiveReviewSystem.ReviewItem.DifficultyLevel?
    
    let mode: ReviewMode
    
    enum ReviewMode {
        case quick
        case standard
        case intensive
        case custom(Int)
        
        var itemCount: Int {
            switch self {
            case .quick: return 10
            case .standard: return 20
            case .intensive: return 50
            case .custom(let count): return count
            }
        }
        
        var title: String {
            switch self {
            case .quick: return "Révision Rapide"
            case .standard: return "Révision Standard"
            case .intensive: return "Révision Intensive"
            case .custom: return "Révision Personnalisée"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if sessionCompleted {
                SessionSummaryView(
                    itemsReviewed: sessionItems.count,
                    correctAnswers: correctCount,
                    incorrectAnswers: incorrectCount,
                    duration: Int(Date().timeIntervalSince(startTime)),
                    onDismiss: { dismiss() }
                )
            } else {
                reviewContent
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Quitter") {
                    dismiss()
                }
            }
        }
        .onAppear {
            loadReviewItems()
        }
    }
    
    private var reviewContent: some View {
        VStack(spacing: 0) {
            progressHeader
            
            Spacer()
            
            if currentIndex < sessionItems.count {
                let item = sessionItems[currentIndex]
                
                FlashcardView(
                    item: item,
                    showAnswer: $showAnswer
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            }
            
            Spacer()
            
            actionButtons
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text(mode.title)
                    .font(.headline)
                Spacer()
                Text("\(currentIndex + 1) / \(sessionItems.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top)
            
            ProgressView(value: Double(currentIndex) / Double(max(sessionItems.count, 1)))
                .tint(.blue)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(correctCount)")
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("\(incorrectCount)")
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.secondary)
                    Text(timeElapsedString)
                }
            }
            .font(.caption)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            if !showAnswer {
                Button(action: { withAnimation { showAnswer = true } }) {
                    Text("Révéler la réponse")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    Text("Comment était cette carte ?")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        DifficultyButton(
                            title: "❌",
                            subtitle: "Difficile",
                            color: .red,
                            difficulty: .hard,
                            action: { self.handleDifficulty($0) }
                        )
                        
                        DifficultyButton(
                            title: "⚠️",
                            subtitle: "Moyen",
                            color: .orange,
                            difficulty: .medium,
                            action: { self.handleDifficulty($0) }
                        )
                        
                        DifficultyButton(
                            title: "✅",
                            subtitle: "Facile",
                            color: .green,
                            difficulty: .easy,
                            action: { self.handleDifficulty($0) }
                        )
                    }
                }
                .padding()
            }
        }
        .padding(.bottom)
    }
    
    private var timeElapsedString: String {
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func loadReviewItems() {
        sessionItems = reviewSystem.getDueItems(limit: mode.itemCount)
        if sessionItems.isEmpty {
            sessionItems = reviewSystem.getNewItems(limit: min(mode.itemCount, 10))
        }
    }
    
    private func handleDifficulty(_ difficulty: AdaptiveReviewSystem.ReviewItem.DifficultyLevel) {
        guard currentIndex < sessionItems.count else { return }
        
        var item = sessionItems[currentIndex]
        let wasCorrect = difficulty == .easy || difficulty == .medium
        
        if wasCorrect {
            correctCount += 1
        } else {
            incorrectCount += 1
        }
        
        reviewSystem.recordReview(item: &item, wasCorrect: wasCorrect, difficulty: difficulty)
        
        withAnimation {
            showAnswer = false
            
            if currentIndex < sessionItems.count - 1 {
                currentIndex += 1
            } else {
                sessionCompleted = true
            }
        }
    }
}
