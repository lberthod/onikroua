import SwiftUI
import AVFoundation

struct ConjugationView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedTab = 0
    @State private var currentLanguage = "it"
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("📖 Explorer").tag(0)
                Text("🗂️ Temps").tag(1)
                Text("🎯 Pratique").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color(.systemGroupedBackground))
            
            TabView(selection: $selectedTab) {
                ConjugationExplorerTab(language: currentLanguage)
                    .tag(0)
                
                ConjugationTensesTab(language: currentLanguage)
                    .tag(1)
                
                ConjugationPracticeTab(language: currentLanguage)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Conjugaison")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                LanguagePicker(currentLanguage: $currentLanguage)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct ConjugationExplorerTab: View {
    let language: String
    @EnvironmentObject var env: AppEnvironment
    @State private var searchText = ""
    @State private var selectedFilter: String? = nil
    
    private let grammarData = GrammarData()
    
    private var filteredVerbs: [Verb] {
        let allVerbs = grammarData.getVerbs(language: language)
        var filtered = allVerbs.filter { verb in
            searchText.isEmpty || 
            verb.verb.localizedCaseInsensitiveContains(searchText) || 
            verb.translation.localizedCaseInsensitiveContains(searchText)
        }
        
        if let filter = selectedFilter {
            filtered = filtered.filter { verb in
                let labels = getVerbLabels(verb.verb)
                switch filter {
                case "aux": return labels.contains("auxiliaire") || labels.contains("verbe clé")
                case "modal": return labels.contains("modal")
                case "movement": return labels.contains("mouvement")
                default: return true
                }
            }
        }
        
        return filtered
    }
    
    private let verbChips: [ChipItem] = [
        .init(id: "aux", label: "Auxiliaires", icon: "bolt.circle"),
        .init(id: "modal", label: "Modaux", icon: "questionmark.circle"),
        .init(id: "movement", label: "Mouvement", icon: "figure.walk")
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: UI.Spacing.md, pinnedViews: [.sectionHeaders]) {
                Section {
                    if filteredVerbs.isEmpty {
                        EmptyState(
                            title: "Aucun verbe trouvé",
                            message: "Essaie un autre filtre ou une autre recherche",
                            icon: "book.closed"
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(filteredVerbs, id: \.verb) { verb in
                            VerbCard(verb: verb)
                                .padding(.horizontal, UI.Spacing.lg)
                        }
                    }
                } header: {
                    StickyHeader(
                        title: "Explorer",
                        subtitle: "\(language == "it" ? "Italien" : "Espagnol")",
                        searchText: $searchText,
                        chips: verbChips,
                        selectedChipId: selectedFilter,
                        onSelectChip: { selectedFilter = $0 },
                        countText: "\(filteredVerbs.count) verbes trouvés"
                    )
                }
            }
        }
        .background(Color(.systemGroupedBackground))
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
}

struct ConjugationTensesTab: View {
    let language: String
    private let grammarData = GrammarData()
    @State private var searchText = ""
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: UI.Spacing.md, pinnedViews: [.sectionHeaders]) {
                Section {
                    let filteredTenses = grammarData.getTenses(language: language).filter {
                        searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
                    }
                    
                    if filteredTenses.isEmpty {
                        EmptyState(title: "Aucun temps trouvé", message: "Essayez une autre recherche", icon: "clock")
                            .padding(.top, 40)
                    } else {
                        ForEach(filteredTenses) { tense in
                            OnykrouaCard(isInteractive: true) {
                                VStack(alignment: .leading, spacing: UI.Spacing.sm) {
                                    Text(tense.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(tense.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                .padding(UI.Spacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, UI.Spacing.lg)
                        }
                    }
                } header: {
                    StickyHeader(
                        title: "Temps",
                        subtitle: "Maîtrisez les conjugaisons",
                        searchText: $searchText
                    )
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct VerbCard: View {
    let verb: Verb
    
    var body: some View {
        OnykrouaCard(isInteractive: true) {
            VStack(alignment: .leading, spacing: UI.Spacing.sm) {
                HStack {
                    Text(verb.verb)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(verb.translation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(UI.Spacing.md)
        }
    }
}

struct ConjugationPracticeTab: View {
    let language: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: UI.Spacing.lg) {
                PracticeModeCard(
                    title: "Quiz de Conjugaison",
                    subtitle: "Maîtrise les terminaisons",
                    icon: "pencil.and.outline",
                    color: .blue,
                    badge: "5 min"
                ) {
                    // Start quiz
                }
                
                PracticeModeCard(
                    title: "Verbes Irréguliers",
                    subtitle: "Pratique les formes spéciales",
                    icon: "exclamationmark.circle.fill",
                    color: .orange
                ) {
                    // Start irregular review
                }
                
                PracticeModeCard(
                    title: "Mix de Temps",
                    subtitle: "Passé, Présent, Futur",
                    icon: "clock.arrow.2.circlepath",
                    color: .purple
                ) {
                    // Start tenses mix
                }
            }
            .padding(UI.Spacing.lg)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationView {
        ConjugationView()
    }
}
