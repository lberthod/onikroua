import SwiftUI
import SwiftData

struct VocabularyView_Enhanced: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var env: AppEnvironment
    
    @State private var selectedTab = 0
    @State private var currentLanguage = "it"
    @State private var showAdvancedSearch = false
    @State private var selectedLevelFilter: CEFRLevel? = nil
    @State private var showOnlyMastered = false
    @State private var showOnlyToReview = false
    @State private var gamificationManager: GamificationManager?
    
    private var totalWords: Int {
        env.vocabularyManager.getAllWords(language: currentLanguage).count
    }
    
    private var filteredWords: [VocabularyWord] {
        var words = env.vocabularyManager.getAllWords(language: currentLanguage)
        
        if let levelFilter = selectedLevelFilter {
            words = words.filter { getCEFRLevel(for: $0) == levelFilter }
        }
        
        return words
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                levelFilterBar
                
                Picker("", selection: $selectedTab) {
                    Text("📖 Dictionnaire").tag(0)
                    Text("🎓 Apprentissage").tag(1)
                    Text("🗂️ Catégories").tag(2)
                    Text("🎯 Pratique").tag(3)
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $selectedTab) {
                    EnhancedDictionaryTab(
                        language: currentLanguage,
                        words: filteredWords,
                        gamificationManager: gamificationManager
                    )
                    .tag(0)
                    
                    VocabularyLearnedTab(language: currentLanguage)
                        .tag(1)
                    
                    CategoriesTab(language: currentLanguage)
                        .tag(2)
                    
                    VocabularyPracticeTab(language: currentLanguage)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("📚 Vocabulaire (\(filteredWords.count))")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { currentLanguage = "it" }) {
                            Label("Italien", systemImage: currentLanguage == "it" ? "checkmark" : "")
                        }
                        Button(action: { currentLanguage = "es" }) {
                            Label("Espagnol", systemImage: currentLanguage == "es" ? "checkmark" : "")
                        }
                    } label: {
                        Text(currentLanguage == "it" ? "🇮🇹" : "🇪🇸")
                            .font(.title2)
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            
            LoadingOverlay(isLoading: env.vocabularyManager.isLoading, message: "Chargement du vocabulaire...")
            
            ErrorOverlay(errorManager: env.errorManager)
        }
        .onAppear {
            env.vocabularyManager.ensureLoaded(language: currentLanguage)
            if gamificationManager == nil {
                gamificationManager = GamificationManager(modelContext: modelContext)
            }
        }
        .onChange(of: currentLanguage) { _, newLanguage in
            env.vocabularyManager.ensureLoaded(language: newLanguage)
        }
    }
    
    private var levelFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                LevelFilterButton(
                    level: nil,
                    isSelected: selectedLevelFilter == nil,
                    action: { selectedLevelFilter = nil }
                )
                
                ForEach(CEFRLevel.allCases) { level in
                    LevelFilterButton(
                        level: level,
                        isSelected: selectedLevelFilter == level,
                        action: { selectedLevelFilter = level }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGray6))
    }
    
    private func getCEFRLevel(for word: VocabularyWord) -> CEFRLevel {
        let wordIndex = env.vocabularyManager.getAllWords(language: currentLanguage)
            .firstIndex(where: { $0.word == word.word }) ?? 0
        
        let totalWords = env.vocabularyManager.getAllWords(language: currentLanguage).count
        let percentage = Double(wordIndex) / Double(totalWords)
        
        switch percentage {
        case 0..<0.15: return .a1
        case 0.15..<0.35: return .a2
        case 0.35..<0.55: return .b1
        case 0.55..<0.75: return .b2
        case 0.75..<0.90: return .c1
        default: return .c2
        }
    }
}

struct LevelFilterButton: View {
    let level: CEFRLevel?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let level = level {
                    Text(level.icon)
                        .font(.caption)
                    Text(level.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                } else {
                    Text("Tous")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? (level?.color ?? .blue) : Color(.systemBackground))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct EnhancedDictionaryTab: View {
    let language: String
    let words: [VocabularyWord]
    let gamificationManager: GamificationManager?
    
    @EnvironmentObject var env: AppEnvironment
    @State private var searchText = ""
    
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
            SearchBar(text: $searchText)
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
                        env.speechService.speak(word.word, language: "it-IT")
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
    }
}

struct WordDetailView: View {
    let word: VocabularyWord
    @Binding var isLearned: Bool
    let gamificationManager: GamificationManager?
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var env: AppEnvironment
    
    var body: some View {
        NavigationStack {
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
                            env.speechService.speak(word.word, language: "it-IT")
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
                            Image(systemName: "folder.fill")
                                .foregroundColor(.orange)
                            Text("Catégorie: \(category)")
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
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
                        dismiss()
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
                }
                .padding()
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
