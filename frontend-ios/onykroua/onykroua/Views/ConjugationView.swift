import SwiftUI
import AVFoundation

struct ConjugationView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedTab = 0
    @State private var currentLanguage = "it"

    var body: some View {
        TabView(selection: $selectedTab) {
            ConjugationExplorerTab(language: currentLanguage)
                .environmentObject(env)
                .tabItem {
                    Label("Explorer", systemImage: "magnifyingglass")
                }
                .tag(0)

            ConjugationTensesTab(language: currentLanguage)
                .environmentObject(env)
                .tabItem {
                    Label("Catégories", systemImage: "square.grid.2x2.fill")
                }
                .tag(1)

            ConjugationPracticeTab(language: currentLanguage)
                .environmentObject(env)
                .tabItem {
                    Label("Pratiquer", systemImage: "gamecontroller")
                }
                .tag(2)
        }
        .navigationTitle("📝 Conjugaison")
    }
}

struct ConjugationExplorerTab: View {
    let language: String
    @EnvironmentObject var env: AppEnvironment
    @State private var searchText = ""
    @State private var selectedFilter: String = "Tous"
    
    private let grammarData = GrammarData()
    
    private var filteredVerbs: [Verb] {
        let allVerbs = grammarData.getVerbs(language: language)
        var filtered = allVerbs.filter { verb in
            searchText.isEmpty || 
            verb.verb.localizedCaseInsensitiveContains(searchText) || 
            verb.translation.localizedCaseInsensitiveContains(searchText)
        }
        
        if selectedFilter != "Tous" {
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
        
        return filtered
    }
    
    private let verbChips: [String] = ["Tous", "Auxiliaires", "Modaux", "Mouvement"]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: UI.Spacing.md) {
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
                .padding(UI.Spacing.md)
                .background(UI.Surface.searchBackground)
                .cornerRadius(UI.Radius.r12)
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: UI.Spacing.md) {
                        ForEach(verbChips, id: \.self) { chip in
                            EmojiStyleFilterButton(
                                title: chip,
                                isSelected: selectedFilter == chip
                            ) {
                                selectedFilter = chip
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, UI.Spacing.md)
            .background(UI.Surface.background)
            
            ScrollView {
                if filteredVerbs.isEmpty {
                    EmptyState(
                        title: "Aucun verbe trouvé",
                        message: "Essaie un autre filtre ou une autre recherche",
                        icon: "book.closed"
                    )
                    .padding(.top, UI.Spacing.huge)
                } else {
                    LazyVStack(spacing: UI.Spacing.md) {
                        ForEach(filteredVerbs, id: \.verb) { verb in
                            VerbCard(verb: verb)
                                .padding(.horizontal, UI.Spacing.md)
                        }
                    }
                }
            }
            .background(UI.Surface.groupedBackground)
            
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.blue)
                Text("\(filteredVerbs.count) verbes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, UI.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(UI.Surface.background)
        }
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
            LazyVStack(spacing: UI.Spacing.lg) {
                ForEach(filteredTenses) { tense in
                    NavigationLink(destination: ConjugationTenseDetailView(tense: tense, language: language)) {
                        OnykrouaCategoryRow(
                            icon: .sfSymbol("clock"),
                            accent: .blue,
                            title: tense.name,
                            subtitle: tense.description,
                            countText: "Temps verbal"
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, UI.Spacing.lg)
            .padding(.top, UI.Spacing.md)
            .padding(.bottom, 96)
        }
        .background(UI.Surface.groupedBackground)
        .overlay(alignment: .top) {
            if !searchText.isEmpty {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Rechercher un temps...", text: $searchText)
                            .textFieldStyle(.plain)

                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(UI.Spacing.md)
                    .background(UI.Surface.searchBackground)
                    .cornerRadius(UI.Radius.r12)
                    .padding(.horizontal)
                    .padding(.vertical, UI.Spacing.md)
                    .background(UI.Surface.background)

                    Divider()
                        .opacity(0.35)
                }
            }
        }
    }

    private var filteredTenses: [TenseInfo] {
        grammarData.getTenses(language: language).filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}

struct ConjugationTenseDetailView: View {
    let tense: TenseInfo
    let language: String
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: UI.Spacing.lg) {
                // Description card
                OnykrouaCard {
                    VStack(alignment: .leading, spacing: UI.Spacing.md) {
                        HStack {
                            Image(systemName: "clock")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text(tense.name)
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.primary)
                        }

                        Text(tense.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                    }
                    .padding(UI.Spacing.lg)
                }
                .padding(.horizontal, UI.Spacing.lg)

                // Example card
                OnykrouaCard {
                    VStack(alignment: .leading, spacing: UI.Spacing.md) {
                        HStack {
                            Image(systemName: "quote.bubble")
                                .font(.title2)
                                .foregroundColor(.purple)
                            Text("Exemple")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.primary)

                            Spacer()

                            Button(action: {
                                env.speechService.speak(tense.example, language: language == "it" ? "it-IT" : "es-ES")
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                        }

                        Text(tense.example)
                            .font(.body)
                            .foregroundColor(.primary)
                            .italic()
                    }
                    .padding(UI.Spacing.lg)
                }
                .padding(.horizontal, UI.Spacing.lg)

                // Related verbs section
                SectionHeader(title: "Verbes fréquents")
                    .padding(.horizontal, UI.Spacing.lg)

                ForEach(getRelatedVerbs().prefix(5)) { verb in
                    VerbCard(verb: verb)
                        .padding(.horizontal, UI.Spacing.lg)
                }
            }
            .padding(.vertical, UI.Spacing.lg)
        }
        .background(UI.Surface.groupedBackground)
        .navigationTitle(tense.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func getRelatedVerbs() -> [Verb] {
        let grammarData = GrammarData()
        let allVerbs = grammarData.getVerbs(language: language)
        return allVerbs.shuffled()
    }
}

struct VerbCard: View {
    let verb: Verb
    
    var body: some View {
        EmojiStyleCard {
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
        VStack(spacing: UI.Spacing.xxl) {
            VStack(spacing: UI.Spacing.md) {
                Text("🎮 Mode Pratique")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choisis ton type d'entraînement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, UI.Spacing.huge)
            
            VStack(spacing: UI.Spacing.md) {
                EmojiStylePracticeButton(
                    icon: "✏️",
                    title: "Quiz de Conjugaison",
                    subtitle: "Maîtrise les terminaisons",
                    color: .blue
                ) {
                    // Start quiz
                }
                
                EmojiStylePracticeButton(
                    icon: "⚠️",
                    title: "Verbes Irréguliers",
                    subtitle: "Pratique les formes spéciales",
                    color: .orange
                ) {
                    // Start irregular review
                }
                
                EmojiStylePracticeButton(
                    icon: "🔄",
                    title: "Mix de Temps",
                    subtitle: "Passé, Présent, Futur",
                    color: .purple
                ) {
                    // Start tenses mix
                }
            }
            .padding(.horizontal, UI.Spacing.xxxl)
            
            Spacer()
            
            NavigationLink(destination: Text("Practice View")) {
                EmojiStyleCTAButton(
                    title: "Commencer",
                    icon: "play.fill"
                ) {
                    
                }
            }
            .padding(.horizontal, UI.Spacing.xxxl)
            .padding(.bottom, UI.Spacing.huge)
        }
        .background(UI.Surface.groupedBackground)
    }
}

#Preview {
    NavigationView {
        ConjugationView()
    }
}
