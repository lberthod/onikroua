import SwiftUI

struct FlashcardView: View {
    let deck: FlashcardDeck
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var offset = CGSize.zero
    @State private var session = ExerciseSession(type: .flashcard)
    @State private var showResults = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                if showResults {
                    FlashcardResultsView(session: session, totalCards: deck.cards.count) {
                        dismiss()
                    }
                } else {
                    flashcardContent
                }
            }
            .navigationTitle(deck.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(currentIndex + 1)/\(deck.cards.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var flashcardContent: some View {
        VStack(spacing: 24) {
            progressBar
            
            Spacer()
            
            cardView
            
            Spacer()
            
            if isFlipped {
                difficultyButtons
            } else {
                flipButton
            }
        }
        .padding()
    }
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Progression")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(session.correctCount) ✓ / \(session.incorrectCount) ✗")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            ProgressView(value: Double(currentIndex), total: Double(deck.cards.count))
                .tint(.blue)
        }
    }
    
    private var cardView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [deck.difficulty == .beginner ? Color.blue : deck.difficulty == .intermediate ? Color.green : Color.purple, Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.1)
            
            VStack(spacing: 20) {
                if !isFlipped {
                    frontContent
                } else {
                    backContent
                }
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: 400)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { gesture in
                    if abs(gesture.translation.width) > 100 {
                        if gesture.translation.width > 0 {
                            handleSwipeRight()
                        } else {
                            handleSwipeLeft()
                        }
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                        }
                    }
                }
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
        }
    }
    
    private var frontContent: some View {
        VStack(spacing: 16) {
            Text("🎴")
                .font(.system(size: 60))
            
            Text(currentCard?.front ?? "")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            
            if let category = currentCard?.category {
                Text(category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.blue.opacity(0.2)))
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text("Touche pour voir la réponse")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var backContent: some View {
        VStack(spacing: 16) {
            Text("✅")
                .font(.system(size: 40))
            
            Text(currentCard?.back ?? "")
                .font(.system(size: 28, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.green)
            
            if let example = currentCard?.example {
                Divider()
                    .padding(.vertical, 8)
                
                VStack(spacing: 8) {
                    Text("Exemple")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(example)
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .rotation3DEffect(
            .degrees(180),
            axis: (x: 0, y: 1, z: 0)
        )
    }
    
    private var flipButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isFlipped = true
            }
        }) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("Retourner la carte")
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
        HStack(spacing: 12) {
            DifficultyButton(
                title: "Difficile",
                icon: "xmark.circle.fill",
                color: .red,
                action: { handleDifficulty(false) }
            )
            
            DifficultyButton(
                title: "Facile",
                icon: "checkmark.circle.fill",
                color: .green,
                action: { handleDifficulty(true) }
            )
        }
    }
    
    private var currentCard: Flashcard? {
        guard currentIndex < deck.cards.count else { return nil }
        return deck.cards[currentIndex]
    }
    
    private func handleDifficulty(_ isCorrect: Bool) {
        session.recordAnswer(isCorrect: isCorrect)
        nextCard()
    }
    
    private func handleSwipeLeft() {
        withAnimation {
            offset = CGSize(width: -500, height: 0)
        }
        session.recordAnswer(isCorrect: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            nextCard()
            withAnimation {
                offset = .zero
            }
        }
    }
    
    private func handleSwipeRight() {
        withAnimation {
            offset = CGSize(width: 500, height: 0)
        }
        session.recordAnswer(isCorrect: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            nextCard()
            withAnimation {
                offset = .zero
            }
        }
    }
    
    private func nextCard() {
        currentIndex += 1
        isFlipped = false
        
        if currentIndex >= deck.cards.count {
            session.complete()
            withAnimation {
                showResults = true
            }
        }
    }
}

struct DifficultyButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(12)
        }
    }
}

struct FlashcardResultsView: View {
    let session: ExerciseSession
    let totalCards: Int
    let onDismiss: () -> Void
    
    var successRate: Int {
        Int(session.successRate)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                resultHeader
                
                statsSection
                
                actionButtons
            }
            .padding()
        }
    }
    
    private var resultHeader: some View {
        VStack(spacing: 16) {
            Text(successRate >= 80 ? "🎉" : successRate >= 60 ? "👏" : "💪")
                .font(.system(size: 80))
            
            Text(successRate >= 80 ? "Excellent !" : successRate >= 60 ? "Bien joué !" : "Continue !")
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(session.correctCount) / \(totalCards) cartes maîtrisées")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack {
                StatBox(
                    icon: "checkmark.circle.fill",
                    value: "\(session.correctCount)",
                    label: "Correctes",
                    color: .green
                )
                
                StatBox(
                    icon: "xmark.circle.fill",
                    value: "\(session.incorrectCount)",
                    label: "Incorrectes",
                    color: .red
                )
            }
            
            HStack {
                StatBox(
                    icon: "star.fill",
                    value: "+\(session.xpEarned)",
                    label: "XP gagnés",
                    color: .yellow
                )
                
                StatBox(
                    icon: "percent",
                    value: "\(successRate)%",
                    label: "Taux de réussite",
                    color: .blue
                )
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: onDismiss) {
                Text("Terminer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
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
