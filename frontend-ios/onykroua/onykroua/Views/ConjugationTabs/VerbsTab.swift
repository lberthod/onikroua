import SwiftUI

public struct VerbsTab: View {
    public let grammarData: GrammarData
    public let language: String
    @ObservedObject var speechService: SpeechService
    @Binding var searchText: String
    @Binding var selectedFilter: String
    @Binding var expandedVerbId: String?
    @Binding var selectedTense: String
    
    public init(grammarData: GrammarData, language: String, speechService: SpeechService, searchText: Binding<String>, selectedFilter: Binding<String>, expandedVerbId: Binding<String?>, selectedTense: Binding<String>) {
        self.grammarData = grammarData
        self.language = language
        self.speechService = speechService
        self._searchText = searchText
        self._selectedFilter = selectedFilter
        self._expandedVerbId = expandedVerbId
        self._selectedTense = selectedTense
    }
    
    private var verbs: [Verb] {
        grammarData.getVerbs(language: language)
    }
    
    private var filteredVerbs: [Verb] {
        var filtered = verbs.filter { verb in
            searchText.isEmpty || 
            verb.verb.localizedCaseInsensitiveContains(searchText) || 
            verb.translation.localizedCaseInsensitiveContains(searchText)
        }
        
        if selectedFilter != "all" {
            filtered = filtered.filter { verb in
                let labels = getVerbLabels(verb.verb)
                switch selectedFilter {
                case "aux": return labels.contains("auxiliaire") || labels.contains("verbe clé")
                case "modal": return labels.contains("modal")
                case "movement": return labels.contains("mouvement")
                default: return true
                }
            }
        }
        
        return filtered.sorted { $0.verb < $1.verb }
    }
    
    private func getVerbLabels(_ verb: String) -> [String] {
        let cleanVerb = verb.replacingOccurrences(of: " --", with: "").trimmingCharacters(in: .whitespaces)
        var labels: [String] = []
        
        if language == "it" {
            if ["essere", "avere"].contains(cleanVerb) { labels.append("auxiliaire") }
            if ["potere", "volere", "dovere"].contains(cleanVerb) { labels.append("modal") }
            if ["andare", "venire"].contains(cleanVerb) { labels.append("mouvement") }
        } else {
            if ["ser", "estar", "haber"].contains(cleanVerb) { labels.append("verbe clé") }
            if ["poder", "querer", "tener"].contains(cleanVerb) { labels.append("modal") }
            if ["ir", "venir"].contains(cleanVerb) { labels.append("mouvement") }
        }
        
        return labels
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Rechercher un verbe...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(title: "Tous", isSelected: selectedFilter == "all") {
                        selectedFilter = "all"
                    }
                    FilterChip(title: "Auxiliaires", isSelected: selectedFilter == "aux") {
                        selectedFilter = "aux"
                    }
                    FilterChip(title: "Modaux", isSelected: selectedFilter == "modal") {
                        selectedFilter = "modal"
                    }
                    FilterChip(title: "Mouvement", isSelected: selectedFilter == "movement") {
                        selectedFilter = "movement"
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // Verbs List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredVerbs) { verb in
                        VerbCard(
                            verb: verb,
                            isExpanded: expandedVerbId == verb.id,
                            selectedTense: $selectedTense,
                            speechService: speechService,
                            language: language
                        ) {
                            withAnimation(.spring()) {
                                expandedVerbId = expandedVerbId == verb.id ? nil : verb.id
                                if expandedVerbId == verb.id {
                                    selectedTense = verb.conjugations.keys.first ?? "Présent"
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

public struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

public struct VerbCard: View {
    let verb: Verb
    let isExpanded: Bool
    @Binding var selectedTense: String
    @ObservedObject var speechService: SpeechService
    let language: String
    let onTap: () -> Void
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(verb.verb)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("→ \(verb.translation)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 6) {
                            Text(verb.group)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                            
                            if verb.isIrregular {
                                Text("Irrégulier")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.1))
                                    .foregroundColor(.orange)
                                    .cornerRadius(6)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { 
                        speechService.speak(verb.verb, language: language == "it" ? "it-IT" : "es-ES")
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .buttonStyle(.plain)
            
            // Expanded Content
            if isExpanded {
                VStack(spacing: 12) {
                    // Tense Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(verb.conjugations.keys.sorted()), id: \.self) { tense in
                                Button(action: { 
                                    withAnimation(.easeInOut) { selectedTense = tense }
                                }) {
                                    Text(tense)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedTense == tense ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(selectedTense == tense ? .white : .primary)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Conjugation Table
                    if let conjugations = verb.conjugations[selectedTense] {
                        VStack(spacing: 8) {
                            ForEach(Array(conjugations.keys.sorted()), id: \.self) { pronoun in
                                if let conjugation = conjugations[pronoun] {
                                    ConjugationRow(
                                        pronoun: pronoun,
                                        conjugation: conjugation,
                                        speechService: speechService,
                                        language: language
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

public struct ConjugationRow: View {
    let pronoun: String
    let conjugation: String
    @ObservedObject var speechService: SpeechService
    let language: String
    
    public var body: some View {
        HStack {
            Text(pronoun)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(conjugation)
                .font(.title3)
                .fontWeight(.medium)
            
            Spacer()
            
            Button(action: { 
                speechService.speak("\(pronoun) \(conjugation)", language: language == "it" ? "it-IT" : "es-ES")
            }) {
                Image(systemName: "speaker.wave.1.fill")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}
