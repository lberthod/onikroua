import SwiftUI

struct GrammarView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedTab = 0
    @State private var currentLanguage = "it"
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("📖 Explorer").tag(0)
                Text("🗂️ Catégories").tag(1)
                Text("🎯 Pratique").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color(.systemGroupedBackground))
            
            TabView(selection: $selectedTab) {
                GrammarExplorerTab(language: currentLanguage)
                    .tag(0)
                
                GrammarCategoriesTab(language: currentLanguage)
                    .tag(1)
                
                GrammarPracticeTab(language: currentLanguage)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Grammaire")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                LanguagePicker(currentLanguage: $currentLanguage)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct GrammarExplorerTab: View {
    let language: String
    @EnvironmentObject var env: AppEnvironment
    @State private var searchText = ""
    @State private var selectedLevel: String? = nil
    
    private var filteredRules: [GrammarRule] {
        var rules = env.grammarManager.getGrammarRules(language: language)
        
        if let level = selectedLevel {
            rules = rules.filter { $0.difficulty == level }
        }
        
        if !searchText.isEmpty {
            rules = rules.filter { 
                $0.rule.localizedCaseInsensitiveContains(searchText) || 
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return rules
    }
    
    private let levelChips: [ChipItem] = [
        .init(id: "débutant", label: "A1-A2", icon: "gauge.low"),
        .init(id: "intermédiaire", label: "B1-B2", icon: "gauge.medium"),
        .init(id: "avancé", label: "C1-C2", icon: "gauge.high")
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: UI.Spacing.md, pinnedViews: [.sectionHeaders]) {
                Section {
                    if filteredRules.isEmpty {
                        EmptyState(
                            title: "Aucune règle trouvée",
                            message: "Essaie un autre filtre ou une autre recherche",
                            icon: "book.closed"
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(filteredRules) { rule in
                            GrammarRuleCard(rule: rule)
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
                        countText: "\(filteredRules.count) règles trouvées"
                    )
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct GrammarRuleCard: View {
    let rule: GrammarRule
    @State private var isExpanded = false
    
    var body: some View {
        OnykrouaCard(isInteractive: true) {
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
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                Image(systemName: "quote.bubble")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                                
                                VStack(alignment: .leading, spacing: 2) {
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
        case "débutant": return .green
        case "intermédiaire": return .orange
        case "avancé": return .red
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
                    OnykrouaCard(isInteractive: true) {
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
            .padding(UI.Spacing.lg)
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct GrammarPracticeTab: View {
    let language: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: UI.Spacing.lg) {
                PracticeModeCard(
                    title: "Quiz Rapide",
                    subtitle: "10 questions sur les règles de base",
                    icon: "bolt.fill",
                    color: .orange,
                    badge: "3 min"
                ) {
                    // Start quiz
                }
                
                PracticeModeCard(
                    title: "Défis de Niveau",
                    subtitle: "Pratique ciblée par niveau CEFR",
                    icon: "target",
                    color: .blue
                ) {
                    // Start level challenge
                }
                
                PracticeModeCard(
                    title: "Erreurs fréquentes",
                    subtitle: "Travaille tes points faibles",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                ) {
                    // Start error review
                }
            }
            .padding(UI.Spacing.lg)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationView {
        GrammarView()
    }
}
