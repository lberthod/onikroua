import SwiftUI

public struct MatchingExerciseView: View {
    public let exercise: MatchingExercise
    public var onComplete: ((ExerciseSession) -> Void)?
    
    @State private var leftItems: [MatchingPair]
    @State private var rightItems: [String]
    @State private var selectedLeft: MatchingPair?
    @State private var selectedRight: String?
    @State private var matches: [UUID: String] = [:]
    @State private var incorrectMatches: Set<UUID> = []
    @State private var session = ExerciseSession(type: .matching)
    @State private var showResults = false
    @Environment(\.dismiss) private var dismiss
    
    init(exercise: MatchingExercise) {
        self.exercise = exercise
        _leftItems = State(initialValue: exercise.pairs)
        _rightItems = State(initialValue: exercise.pairs.map { $0.right }.shuffled())
    }
    
    public init(exercise: MatchingExercise, onComplete: ((ExerciseSession) -> Void)? = nil) {
        self.exercise = exercise
        self.onComplete = onComplete
        
        _leftItems = State(initialValue: exercise.pairs.shuffled())
        _rightItems = State(initialValue: exercise.pairs.map { $0.right }.shuffled())
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                if showResults {
                    ExerciseResultsView(session: session, totalExercises: exercise.pairs.count) {
                        dismiss()
                    }
                } else {
                    exerciseContent
                }
            }
            .navigationTitle("🔗 Associations")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var exerciseContent: some View {
        VStack(spacing: 0) {
            headerSection
            
            ScrollView {
                VStack(spacing: 24) {
                    instructionCard
                    
                    matchingGrid
                    
                    if allMatched {
                        completeButton
                    }
                }
                .padding()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(exercise.title)
                .font(.headline)
            
            HStack {
                Text("\(matches.count) / \(exercise.pairs.count) associations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(exercise.difficulty.icon)
                    .font(.title3)
            }
            
            ProgressView(value: Double(matches.count), total: Double(exercise.pairs.count))
                .tint(.purple)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var instructionCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "link")
                .font(.title2)
                .foregroundColor(.purple)
            
            Text("Associe chaque élément de gauche avec celui de droite")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple.opacity(0.1))
        )
    }
    
    private var matchingGrid: some View {
        HStack(spacing: 16) {
            VStack(spacing: 12) {
                ForEach(leftItems) { pair in
                    LeftMatchButton(
                        pair: pair,
                        isSelected: selectedLeft?.id == pair.id,
                        isMatched: matches[pair.id] != nil,
                        isIncorrect: incorrectMatches.contains(pair.id),
                        action: { selectLeft(pair) }
                    )
                }
            }
            
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(width: 2)
            
            VStack(spacing: 12) {
                ForEach(rightItems, id: \.self) { item in
                    RightMatchButton(
                        text: item,
                        isSelected: selectedRight == item,
                        isMatched: matches.values.contains(item),
                        action: { selectRight(item) }
                    )
                }
            }
        }
    }
    
    private var completeButton: some View {
        Button(action: checkMatches) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Vérifier les associations")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    private var allMatched: Bool {
        return matches.count == exercise.pairs.count
    }
    
    private func selectLeft(_ pair: MatchingPair) {
        guard matches[pair.id] == nil else { return }
        
        if selectedLeft?.id == pair.id {
            selectedLeft = nil
        } else {
            selectedLeft = pair
            checkForMatch()
        }
    }
    
    private func selectRight(_ item: String) {
        guard !matches.values.contains(item) else { return }
        
        if selectedRight == item {
            selectedRight = nil
        } else {
            selectedRight = item
            checkForMatch()
        }
    }
    
    private func checkForMatch() {
        guard let left = selectedLeft, let right = selectedRight else { return }
        
        matches[left.id] = right
        
        selectedLeft = nil
        selectedRight = nil
    }
    
    private func checkMatches() {
        var correctCount = 0
        var incorrectCount = 0
        incorrectMatches.removeAll()
        
        for pair in exercise.pairs {
            if let matched = matches[pair.id] {
                if matched == pair.right {
                    correctCount += 1
                    session.recordAnswer(isCorrect: true)
                } else {
                    incorrectCount += 1
                    session.recordAnswer(isCorrect: false)
                    incorrectMatches.insert(pair.id)
                }
            }
        }
        
        if incorrectMatches.isEmpty {
            session.complete()
            withAnimation {
                showResults = true
            }
        } else {
            withAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    for id in incorrectMatches {
                        matches.removeValue(forKey: id)
                    }
                    incorrectMatches.removeAll()
                }
            }
        }
    }
}

struct LeftMatchButton: View {
    let pair: MatchingPair
    let isSelected: Bool
    let isMatched: Bool
    let isIncorrect: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(pair.left)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(isMatched ? .green : .primary)
                
                Spacer()
                
                if isMatched {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if isIncorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.2) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.purple : isIncorrect ? Color.red : Color(.systemGray4), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isMatched)
        .opacity(isMatched ? 0.6 : 1)
    }
}

struct RightMatchButton: View {
    let text: String
    let isSelected: Bool
    let isMatched: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isMatched {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                Text(text)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(isMatched ? .green : .primary)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.2) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.purple : Color(.systemGray4), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isMatched)
        .opacity(isMatched ? 0.6 : 1)
    }
}
