import SwiftUI

struct GrammarView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedTab = 0
    @State private var currentLanguage = "it"

    var body: some View {
        TabView(selection: $selectedTab) {
            GrammarExplorerTab(language: currentLanguage)
                .environmentObject(env)
                .tabItem {
                    Label("Explorer", systemImage: "magnifyingglass")
                }
                .tag(0)

            GrammarCategoriesTab(language: currentLanguage)
                .environmentObject(env)
                .tabItem {
                    Label("Catégories", systemImage: "square.grid.2x2.fill")
                }
                .tag(1)

            GrammarPracticeTab(language: currentLanguage)
                .environmentObject(env)
                .tabItem {
                    Label("Pratiquer", systemImage: "gamecontroller")
                }
                .tag(2)
        }
        .navigationTitle("📖 Grammaire")
    }
}

struct GrammarExplorerTab: View {
    let language: String
    @EnvironmentObject var env: AppEnvironment
    @State private var searchText = ""
    @State private var selectedLevel: String = "Tous"
    
    private var filteredRules: [GrammarRule] {
        var rules = env.grammarManager.getGrammarRules(language: language)
        
        if selectedLevel != "Tous" {
            rules = rules.filter { $0.difficulty == selectedLevel }
        }
        
        if !searchText.isEmpty {
            rules = rules.filter { 
                $0.rule.localizedCaseInsensitiveContains(searchText) || 
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return rules
    }
    
    private let levelChips: [String] = ["Tous", "A1-A2", "B1-B2", "C1-C2"]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: UI.Spacing.md) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher une règle...", text: $searchText)
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
                        ForEach(levelChips, id: \.self) { chip in
                            EmojiStyleFilterButton(
                                title: chip,
                                isSelected: selectedLevel == chip
                            ) {
                                selectedLevel = chip
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, UI.Spacing.md)
            .background(UI.Surface.background)
            
            ScrollView {
                if filteredRules.isEmpty {
                    EmptyState(
                        title: "Aucune règle trouvée",
                        message: "Essaie un autre filtre ou une autre recherche",
                        icon: "book.closed"
                    )
                    .padding(.top, UI.Spacing.huge)
                } else {
                    LazyVStack(spacing: UI.Spacing.md) {
                        ForEach(filteredRules) { rule in
                            GrammarRuleCard(rule: rule)
                                .padding(.horizontal, UI.Spacing.md)
                        }
                    }
                }
            }
            .background(UI.Surface.groupedBackground)
            
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.blue)
                Text("\(filteredRules.count) règles")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, UI.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(UI.Surface.background)
        }
    }
}

struct GrammarRuleCard: View {
    let rule: GrammarRule
    @State private var isExpanded = false
    
    var body: some View {
        EmojiStyleCard {
            VStack(alignment: .leading, spacing: UI.Spacing.sm) {
                HStack {
                    Text(rule.rule)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    
                    Text(rule.difficulty)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(getDifficultyColor(rule.difficulty).opacity(0.1))
                        .foregroundColor(getDifficultyColor(rule.difficulty))
                        .clipShape(Capsule())
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(rule.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(isExpanded ? nil : 2)
                
                if isExpanded {
                    if let example = rule.example, !example.isEmpty {
                        VStack(alignment: .leading, spacing: UI.Spacing.sm) {
                            HStack(alignment: .top) {
                                Image(systemName: "quote.bubble")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                                
                                VStack(alignment: .leading, spacing: UI.Spacing.xs) {
                                    Text(example)
                                        .font(.subheadline)
                                        .italic()
                                    
                                    if let translation = rule.translation {
                                        Text(translation)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.top, UI.Spacing.xs)
                    }
                }
            }
            .padding(UI.Spacing.md)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }
        }
    }
    
    private func getDifficultyColor(_ diff: String) -> Color {
        switch diff.lowercased() {
        case "débutant", "a1-a2": return .green
        case "intermédiaire", "b1-b2": return .orange
        case "avancé", "c1-c2": return .red
        default: return .blue
        }
    }
}

struct GrammarCategoriesTab: View {
    let language: String
    @EnvironmentObject var env: AppEnvironment
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: UI.Spacing.md) {
                ForEach(env.grammarManager.getCategories()) { category in
                    EmojiStyleCategoryRow {
                        VStack(spacing: UI.Spacing.md) {
                            Text(category.icon)
                                .font(.system(size: 40))
                            
                            Text(category.label)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                    }
                }
            }
            .padding(UI.Spacing.md)
        }
        .background(UI.Surface.groupedBackground)
    }
}

struct GrammarPracticeTab: View {
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
                    icon: "⚡",
                    title: "Quiz Rapide",
                    subtitle: "10 questions sur les règles de base",
                    color: .orange
                ) {
                    // Start quiz
                }
                
                EmojiStylePracticeButton(
                    icon: "🎯",
                    title: "Défis de Niveau",
                    subtitle: "Pratique ciblée par niveau CEFR",
                    color: .blue
                ) {
                    // Start level challenge
                }
                
                EmojiStylePracticeButton(
                    icon: "⚠️",
                    title: "Erreurs fréquentes",
                    subtitle: "Travaille tes points faibles",
                    color: .red
                ) {
                    // Start error review
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
        GrammarView()
    }
}
