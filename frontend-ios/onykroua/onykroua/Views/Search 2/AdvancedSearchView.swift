import SwiftUI
import Combine

// MARK: - Search Filter

struct SearchFilter {
    var category: String?
    var gender: String?
    var hasExample: Bool?
    var isFavorite: Bool?
    var isLearned: Bool?
}

// MARK: - Advanced Search View

struct AdvancedSearchView: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.dismiss) var dismiss
    
    @State private var searchQuery: String = ""
    @State private var searchResults: [VocabWord] = []
    @State private var isSearching: Bool = false
    @State private var showFilters: Bool = false
    @State private var searchFilter = SearchFilter()
    @State private var searchHistory: [String] = []
    @State private var selectedLanguage: String = "it"
    
    @State private var cancellables = Set<AnyCancellable>()
    
    private let searchSubject = PassthroughSubject<String, Never>()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Active filters
                if hasActiveFilters {
                    activeFiltersBar
                }
                
                // Content
                if searchQuery.isEmpty {
                    searchSuggestions
                } else if isSearching {
                    LoadingSkeletonView()
                } else if searchResults.isEmpty {
                    EmptyStateView.noSearchResults(query: searchQuery)
                } else {
                    searchResultsList
                }
            }
            .navigationTitle("Recherche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFilters.toggle() }) {
                        Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(hasActiveFilters ? .blue : .primary)
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet(filter: $searchFilter, language: selectedLanguage)
            }
            .onAppear {
                setupSearch()
                loadSearchHistory()
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Rechercher un mot...", text: $searchQuery)
                .textFieldStyle(.plain)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: searchQuery) { newValue in
                    searchSubject.send(newValue)
                }
            
            if !searchQuery.isEmpty {
                Button(action: clearSearch) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Active Filters Bar
    
    private var activeFiltersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let category = searchFilter.category {
                    FilterChip(title: category) {
                        searchFilter.category = nil
                        performSearch()
                    }
                }
                
                if let gender = searchFilter.gender {
                    FilterChip(title: gender) {
                        searchFilter.gender = nil
                        performSearch()
                    }
                }
                
                if searchFilter.hasExample == true {
                    FilterChip(title: "Avec exemple") {
                        searchFilter.hasExample = nil
                        performSearch()
                    }
                }
                
                if searchFilter.isFavorite == true {
                    FilterChip(title: "Favoris") {
                        searchFilter.isFavorite = nil
                        performSearch()
                    }
                }
                
                if searchFilter.isLearned == true {
                    FilterChip(title: "Appris") {
                        searchFilter.isLearned = nil
                        performSearch()
                    }
                }
                
                Button(action: clearFilters) {
                    Text("Effacer tout")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.leading, 8)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Search Suggestions
    
    private var searchSuggestions: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !searchHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recherches récentes")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("Effacer") {
                                clearSearchHistory()
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                        
                        ForEach(searchHistory, id: \.self) { query in
                            Button(action: { searchQuery = query }) {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(.secondary)
                                    
                                    Text(query)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.left")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // Popular categories
                VStack(alignment: .leading, spacing: 12) {
                    Text("Catégories populaires")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                        ForEach(popularCategories, id: \.self) { category in
                            Button(action: {
                                searchFilter.category = category
                                performSearch()
                            }) {
                                HStack {
                                    Text(getCategoryIcon(category))
                                        .font(.title3)
                                    
                                    Text(category)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Search Results List
    
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(searchResults, id: \.word) { word in
                    SearchResultRow(
                        word: word,
                        query: searchQuery,
                        isFavorite: env.progressTracker.isFavorite(word.word),
                        onToggleFavorite: {
                            env.progressTracker.toggleFavorite(word.word)
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Methods
    
    private func setupSearch() {
        searchSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { query in
                performSearch()
            }
            .store(in: &cancellables)
    }
    
    private func performSearch() {
        guard !searchQuery.isEmpty || hasActiveFilters else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        // Add to search history
        if !searchQuery.isEmpty && !searchHistory.contains(searchQuery) {
            searchHistory.insert(searchQuery, at: 0)
            if searchHistory.count > 10 {
                searchHistory.removeLast()
            }
            saveSearchHistory()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var results = env.vocabularyManager.getAllWords(language: selectedLanguage)
            
            // Apply search query
            if !searchQuery.isEmpty {
                results = fuzzySearch(query: searchQuery, in: results)
            }
            
            // Apply filters
            results = applyFilters(to: results)
            
            searchResults = results
            isSearching = false
        }
    }
    
    private func fuzzySearch(query: String, in words: [VocabWord]) -> [VocabWord] {
        let normalized = query.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
        
        return words.filter { word in
            let wordNormalized = word.word.lowercased()
                .folding(options: .diacriticInsensitive, locale: .current)
            let translationNormalized = word.translation.lowercased()
                .folding(options: .diacriticInsensitive, locale: .current)
            
            return wordNormalized.contains(normalized) ||
                   translationNormalized.contains(normalized) ||
                   levenshteinDistance(wordNormalized, normalized) <= 2
        }
        .sorted { word1, word2 in
            let score1 = calculateRelevanceScore(word1, query: normalized)
            let score2 = calculateRelevanceScore(word2, query: normalized)
            return score1 > score2
        }
    }
    
    private func calculateRelevanceScore(_ word: VocabWord, query: String) -> Int {
        let wordNormalized = word.word.lowercased()
        
        if wordNormalized == query { return 100 }
        if wordNormalized.hasPrefix(query) { return 80 }
        if wordNormalized.contains(query) { return 60 }
        
        let distance = levenshteinDistance(wordNormalized, query)
        return max(0, 40 - distance * 10)
    }
    
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let m = s1.count
        let n = s2.count
        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }
        
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        
        for i in 1...m {
            for j in 1...n {
                let cost = s1Array[i-1] == s2Array[j-1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i-1][j] + 1,
                    matrix[i][j-1] + 1,
                    matrix[i-1][j-1] + cost
                )
            }
        }
        
        return matrix[m][n]
    }
    
    private func applyFilters(to words: [VocabWord]) -> [VocabWord] {
        var filtered = words
        
        if let category = searchFilter.category {
            filtered = filtered.filter { $0.category == category }
        }
        
        if let gender = searchFilter.gender {
            filtered = filtered.filter { $0.gender == gender }
        }
        
        if searchFilter.hasExample == true {
            filtered = filtered.filter { $0.example != nil && !$0.example!.isEmpty }
        }
        
        if searchFilter.isFavorite == true {
            filtered = filtered.filter { env.progressTracker.isFavorite($0.word) }
        }
        
        if searchFilter.isLearned == true {
            filtered = filtered.filter { env.progressTracker.wordsLearned.contains($0.word) }
        }
        
        return filtered
    }
    
    private func clearSearch() {
        searchQuery = ""
        searchResults = []
    }
    
    private func clearFilters() {
        searchFilter = SearchFilter()
        performSearch()
    }
    
    private var hasActiveFilters: Bool {
        searchFilter.category != nil ||
        searchFilter.gender != nil ||
        searchFilter.hasExample == true ||
        searchFilter.isFavorite == true ||
        searchFilter.isLearned == true
    }
    
    private var popularCategories: [String] {
        ["Nourriture", "Famille", "Voyage", "Temps", "Nature", "Corps"]
    }
    
    private func getCategoryIcon(_ category: String) -> String {
        switch category {
        case "Nourriture": return "🍕"
        case "Famille": return "👨‍👩‍👧"
        case "Voyage": return "✈️"
        case "Temps": return "⏰"
        case "Nature": return "🌳"
        case "Corps": return "🏃"
        default: return "📚"
        }
    }
    
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
    }
    
    private func saveSearchHistory() {
        UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
    }
    
    private func clearSearchHistory() {
        searchHistory = []
        UserDefaults.standard.removeObject(forKey: "searchHistory")
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(8)
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let word: VocabWord
    let query: String
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(highlightedText(word.word, query: query))
                    .font(.headline)
                
                Text(word.translation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let example = word.example {
                    Text(example)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.top, 4)
                }
            }
            
            Spacer()
            
            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func highlightedText(_ text: String, query: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        if let range = text.range(of: query, options: .caseInsensitive) {
            let nsRange = NSRange(range, in: text)
            if let attributedRange = Range(nsRange, in: attributedString) {
                attributedString[attributedRange].backgroundColor = .yellow.opacity(0.3)
                attributedString[attributedRange].foregroundColor = .primary
            }
        }
        
        return attributedString
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var filter: SearchFilter
    let language: String
    
    var body: some View {
        NavigationView {
            Form {
                Section("Genre") {
                    Picker("Genre", selection: $filter.gender) {
                        Text("Tous").tag(nil as String?)
                        Text("Masculin").tag("m" as String?)
                        Text("Féminin").tag("f" as String?)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Contenu") {
                    Toggle("Avec exemple", isOn: Binding(
                        get: { filter.hasExample ?? false },
                        set: { filter.hasExample = $0 ? true : nil }
                    ))
                }
                
                Section("Mes mots") {
                    Toggle("Favoris uniquement", isOn: Binding(
                        get: { filter.isFavorite ?? false },
                        set: { filter.isFavorite = $0 ? true : nil }
                    ))
                    
                    Toggle("Mots appris", isOn: Binding(
                        get: { filter.isLearned ?? false },
                        set: { filter.isLearned = $0 ? true : nil }
                    ))
                }
            }
            .navigationTitle("Filtres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Appliquer") {
                        dismiss()
                    }
                }
            }
        }
    }
}
