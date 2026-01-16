import SwiftUI
import SwiftData
import AVFoundation

struct EmojiView_Enhanced: View {
    @EnvironmentObject var env: AppEnvironment
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var gamificationManager: GamificationManager?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            EmojiDictionaryView()
                .environmentObject(env)
                .tabItem {
                    Label("Tous", systemImage: "book.fill")
                }
                .tag(0)
            
            EmojiCategoriesView()
                .environmentObject(env)
                .tabItem {
                    Label("Catégories", systemImage: "square.grid.2x2.fill")
                }
                .tag(1)
            
            EmojiPracticeView(gamificationManager: $gamificationManager)
                .environmentObject(env)
                .tabItem {
                    Label("Pratiquer", systemImage: "gamecontroller.fill")
                }
                .tag(2)
        }
        .navigationTitle("😊 Emoji")
        .onAppear {
            if gamificationManager == nil {
                gamificationManager = GamificationManager(modelContext: modelContext)
            }
        }
    }
}

// MARK: - Mode Dictionnaire (Tous)

struct EmojiDictionaryView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var searchText = ""
    @State private var selectedCategoryFilter: String = "Tous"
    
    let emojiCategories = EmojiDataSource.getAllCategories()
    
    var allEmojis: [EmojiWordModel] {
        emojiCategories.flatMap { $0.items }
    }
    
    var filteredEmojis: [EmojiWordModel] {
        var result = allEmojis
        
        if selectedCategoryFilter != "Tous" {
            result = emojiCategories.first { $0.name == selectedCategoryFilter }?.items ?? []
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.italian.localizedCaseInsensitiveContains(searchText) ||
                $0.french.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher un emoji...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "Tous", isSelected: selectedCategoryFilter == "Tous") {
                            selectedCategoryFilter = "Tous"
                        }
                        
                        ForEach(emojiCategories) { category in
                            FilterButton(title: category.name, isSelected: selectedCategoryFilter == category.name) {
                                selectedCategoryFilter = category.name
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(filteredEmojis) { emoji in
                        EmojiDictionaryCard(emoji: emoji, speechService: env.speechService)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.blue)
                Text("\(filteredEmojis.count) emojis")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct EmojiDictionaryCard: View {
    let emoji: EmojiWordModel
    @ObservedObject var speechService: SpeechService
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 8) {
            Text(emoji.emoji)
                .font(.system(size: 48))
            
            Text(emoji.italian)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            
            Text(emoji.french)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            Image(systemName: "speaker.wave.2.fill")
                .font(.caption2)
                .foregroundColor(.blue.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            isPressed = true
            speechService.speak(emoji.italian, language: "it-IT")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        }
    }
}

// MARK: - Mode Catégories

struct EmojiCategoriesView: View {
    @EnvironmentObject var env: AppEnvironment
    let emojiCategories = EmojiDataSource.getAllCategories()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(emojiCategories) { category in
                    NavigationLink(destination: EmojiCategoryDetailView(category: category).environmentObject(env)) {
                        CategoryRow(category: category)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct CategoryRow: View {
    let category: EmojiCategoryModel
    
    var body: some View {
        HStack(spacing: 16) {
            Text(category.icon)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(category.items.count) emojis")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct EmojiCategoryDetailView: View {
    @EnvironmentObject var env: AppEnvironment
    let category: EmojiCategoryModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(category.items) { emoji in
                    EmojiDictionaryCard(emoji: emoji, speechService: env.speechService)
                }
            }
            .padding()
        }
        .navigationTitle(category.name)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Mode Pratique

struct EmojiPracticeView: View {
    @EnvironmentObject var env: AppEnvironment
    @Binding var gamificationManager: GamificationManager?
    @State private var selectedMode: PracticeMode = .emojiToWord
    
    enum PracticeMode {
        case emojiToWord
        case wordToEmoji
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Text("🎮 Mode Pratique")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choisis ton type d'entraînement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            VStack(spacing: 16) {
                PracticeModeButton(
                    icon: "😊",
                    title: "Emoji → Mots",
                    subtitle: "Trouve le bon mot",
                    color: .blue
                ) {
                    selectedMode = .emojiToWord
                }
                
                PracticeModeButton(
                    icon: "🎧",
                    title: "Mot → Emojis",
                    subtitle: "Écoute et trouve l'emoji",
                    color: .purple
                ) {
                    selectedMode = .wordToEmoji
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            NavigationLink(destination: EmojiQuizView(mode: selectedMode, gamificationManager: gamificationManager).environmentObject(env)) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Commencer")
                        .fontWeight(.semibold)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct PracticeModeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(icon)
                    .font(.system(size: 48))
                    .frame(width: 70, height: 70)
                    .background(color.opacity(0.1))
                    .cornerRadius(16)
                
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
                    .foregroundColor(color)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quiz View

struct EmojiQuizView: View {
    @EnvironmentObject var env: AppEnvironment
    @Environment(\.dismiss) var dismiss
    let mode: EmojiPracticeView.PracticeMode
    let gamificationManager: GamificationManager?
    
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var questions: [EmojiQuizQuestion] = []
    @State private var selectedAnswer: Int? = nil
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showCompletion = false
    
    let totalQuestions = 10
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                quizHeader
                
                if !showCompletion && currentQuestionIndex < questions.count {
                    VStack(spacing: 32) {
                        Spacer()
                        
                        questionView
                        
                        answersGrid
                        
                        Spacer()
                        
                        if showResult {
                            nextButton
                        }
                    }
                    .padding()
                }
            }
            
            if showCompletion {
                CompletionView(
                    score: score,
                    total: totalQuestions,
                    onRestart: restartQuiz,
                    onDismiss: { dismiss() }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            generateQuestions()
        }
    }
    
    private var quizHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Question \(currentQuestionIndex + 1)/\(totalQuestions)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(score)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            
            ProgressView(value: Double(currentQuestionIndex), total: Double(totalQuestions))
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private var questionView: some View {
        if let question = questions[safe: currentQuestionIndex] {
            VStack(spacing: 16) {
                if mode == .emojiToWord {
                    Text(question.emoji)
                        .font(.system(size: 100))
                    
                    Text("Quel est le mot en italien ?")
                        .font(.headline)
                        .foregroundColor(.secondary)
                } else {
                    VStack(spacing: 12) {
                        Text(question.word)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Button(action: {
                            env.speechService.speak(question.word, language: "it-IT")
                        }) {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                Text("Écouter")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(20)
                        }
                        
                        Text("Quel est l'emoji correspondant ?")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
        }
    }
    
    private var answersGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            if let question = questions[safe: currentQuestionIndex] {
                ForEach(0..<4, id: \.self) { index in
                    answerButton(answer: question.options[index], index: index, correctIndex: question.correctIndex)
                }
            }
        }
    }
    
    private func answerButton(answer: String, index: Int, correctIndex: Int) -> some View {
        Button(action: {
            guard !showResult else { return }
            selectedAnswer = index
            isCorrect = index == correctIndex
            showResult = true
            
            if isCorrect {
                score += 10
                gamificationManager?.awardXP(10, for: "Emoji Quiz")
            }
        }) {
            Text(answer)
                .font(mode == .emojiToWord ? .title3 : .system(size: 60))
                .fontWeight(mode == .emojiToWord ? .semibold : .regular)
                .foregroundColor(buttonColor(index: index, correctIndex: correctIndex))
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(buttonBackground(index: index, correctIndex: correctIndex))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(buttonBorderColor(index: index, correctIndex: correctIndex), lineWidth: 3)
                )
        }
        .disabled(showResult)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showResult)
    }
    
    private func buttonColor(index: Int, correctIndex: Int) -> Color {
        if !showResult { return .primary }
        if index == correctIndex { return .white }
        if index == selectedAnswer { return .white }
        return .primary
    }
    
    private func buttonBackground(index: Int, correctIndex: Int) -> Color {
        if !showResult { return Color(.systemBackground) }
        if index == correctIndex { return .green }
        if index == selectedAnswer { return .red }
        return Color(.systemBackground)
    }
    
    private func buttonBorderColor(index: Int, correctIndex: Int) -> Color {
        if !showResult { return Color.clear }
        if index == correctIndex { return .green }
        if index == selectedAnswer { return .red }
        return Color.clear
    }
    
    private var nextButton: some View {
        Button(action: nextQuestion) {
            HStack {
                Text(currentQuestionIndex < totalQuestions - 1 ? "Suivant" : "Terminer")
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.blue)
            .cornerRadius(16)
        }
    }
    
    private func generateQuestions() {
        let allEmojis = EmojiDataSource.getAllCategories().flatMap { $0.items }
        let shuffled = allEmojis.shuffled()
        
        questions = shuffled.prefix(totalQuestions).map { emoji in
            let correctAnswer = mode == .emojiToWord ? emoji.italian : emoji.emoji
            let wrongAnswers = allEmojis
                .filter { $0.id != emoji.id }
                .shuffled()
                .prefix(3)
                .map { mode == .emojiToWord ? $0.italian : $0.emoji }
            
            var options = wrongAnswers + [correctAnswer]
            options.shuffle()
            
            return EmojiQuizQuestion(
                emoji: emoji.emoji,
                word: emoji.italian,
                correctAnswer: correctAnswer,
                options: options,
                correctIndex: options.firstIndex(of: correctAnswer) ?? 0
            )
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < totalQuestions - 1 {
            withAnimation {
                currentQuestionIndex += 1
                selectedAnswer = nil
                showResult = false
                isCorrect = false
            }
        } else {
            showCompletion = true
        }
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showResult = false
        isCorrect = false
        showCompletion = false
        generateQuestions()
    }
}

struct EmojiQuizQuestion {
    let emoji: String
    let word: String
    let correctAnswer: String
    let options: [String]
    let correctIndex: Int
}

struct CompletionView: View {
    let score: Int
    let total: Int
    let onRestart: () -> Void
    let onDismiss: () -> Void
    
    var percentage: Int {
        Int((Double(score) / Double(total * 10)) * 100)
    }
    
    var performanceMessage: String {
        switch percentage {
        case 90...100: return "Perfetto! 🏆"
        case 70..<90: return "Molto bene! 🌟"
        case 50..<70: return "Bene! 👍"
        default: return "Continua così! 💪"
        }
    }
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text(performanceMessage)
                    .font(.system(size: 40, weight: .bold))
                
                Text("\(percentage)%")
                    .font(.system(size: 80, weight: .heavy))
                    .foregroundColor(.blue)
                
                Text("\(score) / \(total * 10) points")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                Button(action: onRestart) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Recommencer")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(16)
                }
                
                Button(action: onDismiss) {
                    Text("Retour au menu")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack {
        EmojiView_Enhanced()
            .environmentObject(AppEnvironment.shared)
    }
}
