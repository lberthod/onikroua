import SwiftUI
import SwiftData

struct VocabularyView_Enhanced: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var env: AppEnvironment

    @State private var selectedTab = 0
    @State private var currentLanguage = "it"
    @State private var gamificationManager: GamificationManager?

    var body: some View {
        TabView(selection: $selectedTab) {
            VocabularyExplorerTab(language: currentLanguage, gamificationManager: gamificationManager)
                .tabItem {
                    Label("Dictionnaire", systemImage: "book.fill")
                }
                .tag(0)

            Text("Apprentissage View") // TODO: Implement Learning Tab
                .tabItem {
                    Label("Apprentissage", systemImage: "graduationcap.fill")
                }
                .tag(1)

            CategoriesTab(language: currentLanguage)
                .tabItem {
                    Label("Catégories", systemImage: "square.grid.2x2.fill")
                }
                .tag(2)

            VocabularyPracticeTab(language: currentLanguage)
                .tabItem {
                    Label("Pratiquer", systemImage: "gamecontroller.fill")
                }
                .tag(3)
        }
        .navigationTitle("📚 Vocabulaire")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                LanguagePicker(currentLanguage: $currentLanguage)
            }
        }
        .onAppear {
            env.vocabularyManager.loadVocabularyAsync(language: currentLanguage)
            if gamificationManager == nil {
                gamificationManager = GamificationManager(modelContext: modelContext)
            }
        }
        .onChange(of: currentLanguage) { _, newLanguage in
            env.vocabularyManager.loadVocabularyAsync(language: newLanguage)
        }
    }
}

// MARK: - Vocabulary Explorer Tab

struct VocabularyExplorerTab: View {
    let language: String
    let gamificationManager: GamificationManager?

    @EnvironmentObject var env: AppEnvironment
    @State private var searchText = ""
    @State private var selectedLevel: String? = nil

    private var filteredWords: [VocabularyWord] {
        var words = env.vocabularyManager.getAllWords(language: language)

        if let level = selectedLevel {
            words = words.filter { getCEFRLevel(for: $0).rawValue == level }
        }

        if !searchText.isEmpty {
            words = words.filter {
                $0.word.localizedCaseInsensitiveContains(searchText) ||
                $0.translation.localizedCaseInsensitiveContains(searchText)
            }
        }

        return words.sorted { $0.word.localizedCaseInsensitiveCompare($1.word) == .orderedAscending }
    }

    private let levelChips: [ChipItem] = [
        .init(id: "A1", label: "A1", icon: "gauge.low"),
        .init(id: "A2", label: "A2", icon: "gauge.medium"),
        .init(id: "B1", label: "B1", icon: "gauge.high"),
        .init(id: "B2", label: "B2", icon: "speedometer"),
        .init(id: "C1", label: "C1", icon: "chart.bar.fill"),
        .init(id: "C2", label: "C2", icon: "star.fill")
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: UI.Spacing.md, pinnedViews: [.sectionHeaders]) {
                Section {
                    if filteredWords.isEmpty {
                        EmptyState(
                            title: "Aucun mot trouvé",
                            message: "Essaie un autre filtre ou une autre recherche",
                            icon: "book.closed"
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(filteredWords, id: \.word) { word in
                            EnhancedDictionaryRow(
                                word: word,
                                gamificationManager: gamificationManager
                            )
                            .padding(.horizontal, UI.Spacing.lg)
                        }
                    }
                } header: {
                    StickyHeader(
                        title: "Explorer",
                        subtitle: "\(language == "it" ? "Italien" : "Espagnol")",
                        searchText: $searchText,
                        chips: levelChips,
                        selectedChipId: selectedLevel,
                        onSelectChip: { selectedLevel = $0 },
                        countText: "\(filteredWords.count) mots trouvés",
                        trailingAction: HeaderAction(icon: "shuffle") {
                            // Action shuffle déjà gérée dans l'ancien code ou à simplifier
                        }
                    )
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private func getCEFRLevel(for word: VocabularyWord) -> CEFRLevel {
        let words = env.vocabularyManager.getAllWords(language: language)
        let wordIndex = words.firstIndex(where: { $0.word == word.word }) ?? 0
        let percentage = Double(wordIndex) / Double(max(1, words.count))

        if percentage < 0.15 { return .a1 }
        if percentage < 0.35 { return .a2 }
        if percentage < 0.55 { return .b1 }
        if percentage < 0.75 { return .b2 }
        if percentage < 0.90 { return .c1 }
        return .c2
    }
}

struct EnhancedDictionaryTab: View {
    let language: String
    let words: [VocabularyWord]
    let gamificationManager: GamificationManager?
    
    @EnvironmentObject var env: AppEnvironment
    @State private var searchText = ""
    @State private var randomWord: VocabularyWord? = nil
    @State private var showRandomDetail = false
    @State private var isRandomWordLearned = false
    
    private var uniqueSortedWords: [VocabularyWord] {
        // Obtenir tous les mots, supprimer les doublons par texte de mot, et trier A-Z
        let allWords = words
        var seenWords = Set<String>()
        var uniqueWords = [VocabularyWord]()
        
        for word in allWords {
            let normalizedWord = word.word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if !seenWords.contains(normalizedWord) {
                seenWords.insert(normalizedWord)
                uniqueWords.append(word)
            }
        }
        
        return uniqueWords.sorted { $0.word.lowercased() < $1.word.lowercased() }
    }
    
    private var searchResults: [VocabularyWord] {
        let baseWords = uniqueSortedWords
        if searchText.isEmpty {
            return baseWords
        } else {
            return baseWords.filter { word in
                word.word.localizedCaseInsensitiveContains(searchText) ||
                word.translation.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                SearchBar(text: $searchText)
                
                Button(action: {
                    if let word = uniqueSortedWords.randomElement() {
                        randomWord = word
                        // Calculer l'état isLearned pour le mot aléatoire
                        let safeWord = word.word.replacingOccurrences(of: ".", with: "_")
                            .replacingOccurrences(of: "$", with: "_")
                            .replacingOccurrences(of: "#", with: "_")
                            .replacingOccurrences(of: "[", with: "_")
                            .replacingOccurrences(of: "]", with: "_")
                            .replacingOccurrences(of: "/", with: "_")
                        
                        let safeTranslation = word.translation.replacingOccurrences(of: ".", with: "_")
                            .replacingOccurrences(of: "$", with: "_")
                            .replacingOccurrences(of: "#", with: "_")
                            .replacingOccurrences(of: "[", with: "_")
                            .replacingOccurrences(of: "]", with: "_")
                            .replacingOccurrences(of: "/", with: "_")
                        
                        let wordId = "\(safeWord)_\(safeTranslation)"
                        isRandomWordLearned = env.learnedWordsManager.isWordLearned(wordId: wordId)
                        showRandomDetail = true
                    }
                }) {
                    Image(systemName: "shuffle")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            if searchResults.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(searchResults, id: \.word) { word in
                            EnhancedDictionaryRow(
                                word: word,
                                gamificationManager: gamificationManager
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showRandomDetail) {
            if let word = randomWord {
                WordDetailView(
                    word: word,
                    isLearned: $isRandomWordLearned,
                    gamificationManager: gamificationManager,
                    onNextRandom: {
                        if let nextWord = uniqueSortedWords.randomElement() {
                            randomWord = nextWord
                            
                            // Calculer l'état isLearned pour le nouveau mot
                            let safeWord = nextWord.word.replacingOccurrences(of: ".", with: "_")
                                .replacingOccurrences(of: "$", with: "_")
                                .replacingOccurrences(of: "#", with: "_")
                                .replacingOccurrences(of: "[", with: "_")
                                .replacingOccurrences(of: "]", with: "_")
                                .replacingOccurrences(of: "/", with: "_")
                            
                            let safeTranslation = nextWord.translation.replacingOccurrences(of: ".", with: "_")
                                .replacingOccurrences(of: "$", with: "_")
                                .replacingOccurrences(of: "#", with: "_")
                                .replacingOccurrences(of: "[", with: "_")
                                .replacingOccurrences(of: "]", with: "_")
                                .replacingOccurrences(of: "/", with: "_")
                            
                            let wordId = "\(safeWord)_\(safeTranslation)"
                            isRandomWordLearned = env.learnedWordsManager.isWordLearned(wordId: wordId)
                        }
                    }
                )
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Aucun mot trouvé")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if !searchText.isEmpty {
                Text("Essaie un autre terme de recherche")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EnhancedDictionaryRow: View {
    let word: VocabularyWord
    let gamificationManager: GamificationManager?
    
    @EnvironmentObject var env: AppEnvironment
    @State private var isLearned = false
    @State private var showDetail = false
    
    private func updateLearnedState() {
        let safeWord = word.word.replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "$", with: "_")
            .replacingOccurrences(of: "#", with: "_")
            .replacingOccurrences(of: "[", with: "_")
            .replacingOccurrences(of: "]", with: "_")
            .replacingOccurrences(of: "/", with: "_")
        
        let safeTranslation = word.translation.replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "$", with: "_")
            .replacingOccurrences(of: "#", with: "_")
            .replacingOccurrences(of: "[", with: "_")
            .replacingOccurrences(of: "]", with: "_")
            .replacingOccurrences(of: "/", with: "_")
        
        let wordId = "\(safeWord)_\(safeTranslation)"
        isLearned = env.learnedWordsManager.isWordLearned(wordId: wordId)
    }
    
    private func formatForSpeech(_ text: String) -> String {
        let pattern = "^(.+?)\\s*\\((il|la|lo|l'|i|le|gli)\\)$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
            if let motRange = Range(match.range(at: 1), in: text),
               let detRange = Range(match.range(at: 2), in: text) {
                let mot = String(text[motRange]).trimmingCharacters(in: .whitespaces)
                let determinant = String(text[detRange])
                return "\(determinant) \(mot)"
            }
        }
        return text
    }
    
    var body: some View {
        Button(action: { showDetail = true }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        if let icon = word.categoryIcon {
                            Text(icon)
                                .font(.caption)
                        }
                        
                        Text(word.word)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if isLearned {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(word.translation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let example = word.example, !example.isEmpty {
                        Text(example)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { 
                        let speechText = formatForSpeech(word.word)
                        env.speechService.speak(speechText, language: "it-IT")
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        let newLearnedState = !isLearned
                        
                        // Calcul manuel de l'ID Firebase
                        let safeWord = word.word.replacingOccurrences(of: ".", with: "_")
                            .replacingOccurrences(of: "$", with: "_")
                            .replacingOccurrences(of: "#", with: "_")
                            .replacingOccurrences(of: "[", with: "_")
                            .replacingOccurrences(of: "]", with: "_")
                            .replacingOccurrences(of: "/", with: "_")
                        
                        let safeTranslation = word.translation.replacingOccurrences(of: ".", with: "_")
                            .replacingOccurrences(of: "$", with: "_")
                            .replacingOccurrences(of: "#", with: "_")
                            .replacingOccurrences(of: "[", with: "_")
                            .replacingOccurrences(of: "]", with: "_")
                            .replacingOccurrences(of: "/", with: "_")
                        
                        let wordId = "\(safeWord)_\(safeTranslation)"
                        
                        Task {
                            if newLearnedState {
                                gamificationManager?.recordWordLearned()
                                await env.learnedWordsManager.markWordAsLearned(
                                    wordId: wordId,
                                    word: word.word,
                                    translation: word.translation
                                )
                            } else {
                                await env.learnedWordsManager.unmarkWordAsLearned(
                                    wordId: wordId,
                                    word: word.word
                                )
                            }
                            isLearned = newLearnedState
                        }
                    }) {
                        Image(systemName: isLearned ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(isLearned ? .green : .gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            WordDetailView(word: word, isLearned: $isLearned, gamificationManager: gamificationManager)
        }
        .onAppear {
            updateLearnedState()
        }
        .onChange(of: env.learnedWordsManager.learnedWordIds) { _, _ in
            updateLearnedState()
        }
    }
}

struct WordDetailView: View {
    @State var word: VocabularyWord
    @Binding var isLearned: Bool
    let gamificationManager: GamificationManager?
    var onNextRandom: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var env: AppEnvironment
    
    private func formatForSpeech(_ text: String) -> String {
        let pattern = "^(.+?)\\s*\\((il|la|lo|l'|i|le|gli)\\)$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
            if let motRange = Range(match.range(at: 1), in: text),
               let detRange = Range(match.range(at: 2), in: text) {
                let mot = String(text[motRange]).trimmingCharacters(in: .whitespaces)
                let determinant = String(text[detRange])
                return "\(determinant) \(mot)"
            }
        }
        return text
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            if let icon = word.categoryIcon {
                                Text(icon)
                                    .font(.system(size: 60))
                            }
                            
                            Text(word.word)
                                .font(.system(size: 36, weight: .bold))
                            
                            Button(action: {
                                let speechText = formatForSpeech(word.word)
                                env.speechService.speak(speechText, language: "it-IT")
                            }) {
                                HStack {
                                    Image(systemName: "speaker.wave.2.fill")
                                    Text("Écouter")
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Traduction", systemImage: "text.bubble")
                                .font(.headline)
                            
                            Text(word.translation)
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        if let example = word.example, !example.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label("Exemple", systemImage: "quote.bubble")
                                        .font(.headline)
                                    Spacer()
                                    Button(action: {
                                        env.speechService.speak(example, language: "it-IT")
                                    }) {
                                        Image(systemName: "speaker.wave.2.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                Text(example)
                                    .font(.body)
                                    .italic()
                                
                                if let exampleTranslation = word.exampleTranslation, !exampleTranslation.isEmpty {
                                    Text(exampleTranslation)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        if let category = word.category {
                            HStack {
                                Label("Catégorie", systemImage: "tag")
                                    .font(.headline)
                                Spacer()
                                Text(category)
                                    .font(.subheadline)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                
                // Barre d'actions fixe en bas
                VStack(spacing: 12) {
                    Button(action: {
                        let newLearnedState = !isLearned
                        
                        let safeWord = word.word.replacingOccurrences(of: ".", with: "_")
                            .replacingOccurrences(of: "$", with: "_")
                            .replacingOccurrences(of: "#", with: "_")
                            .replacingOccurrences(of: "[", with: "_")
                            .replacingOccurrences(of: "]", with: "_")
                            .replacingOccurrences(of: "/", with: "_")
                        
                        let safeTranslation = word.translation.replacingOccurrences(of: ".", with: "_")
                            .replacingOccurrences(of: "$", with: "_")
                            .replacingOccurrences(of: "#", with: "_")
                            .replacingOccurrences(of: "[", with: "_")
                            .replacingOccurrences(of: "]", with: "_")
                            .replacingOccurrences(of: "/", with: "_")
                        
                        let wordId = "\(safeWord)_\(safeTranslation)"
                        
                        Task {
                            if newLearnedState {
                                gamificationManager?.recordWordLearned()
                                await env.learnedWordsManager.markWordAsLearned(
                                    wordId: wordId,
                                    word: word.word,
                                    translation: word.translation
                                )
                            } else {
                                await env.learnedWordsManager.unmarkWordAsLearned(
                                    wordId: wordId,
                                    word: word.word
                                )
                            }
                            isLearned = newLearnedState
                        }
                    }) {
                        HStack {
                            Image(systemName: isLearned ? "checkmark.circle.fill" : "book.fill")
                            Text(isLearned ? "Ajouté à l'Apprentissage" : "Ajouter à l'Apprentissage")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLearned ? Color.green : Color.blue)
                        .cornerRadius(12)
                    }
                    
                    if let onNext = onNextRandom {
                        Button(action: onNext) {
                            HStack {
                                Image(systemName: "shuffle")
                                Text("Mot aléatoire suivant")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
            }
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Rechercher un mot...", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}