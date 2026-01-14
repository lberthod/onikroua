import SwiftUI

struct RulesGrammarTab: View {
    let language: String
    @State private var searchText = ""
    @State private var selectedCategory = "all"
    @State private var selectedDifficulty = "all"
    
    private var dataManager = GrammarDataManager.shared
    
    init(language: String) {
        self.language = language
    }
    
    private var filteredRules: [GrammarRule] {
        let allRules = dataManager.getGrammarRules(language: language)
        return dataManager.filterRules(
            allRules,
            category: selectedCategory,
            difficulty: selectedDifficulty,
            searchQuery: searchText
        )
    }
    
    private var groupedRules: [GrammarGroup] {
        dataManager.groupRules(filteredRules)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            GrammarSearchBar(searchText: $searchText)
            
            Divider()
            
            GrammarFilterSection(
                selectedCategory: $selectedCategory,
                selectedDifficulty: $selectedDifficulty
            )
            
            Divider()
            
            if groupedRules.isEmpty {
                GrammarEmptyStateView()
            } else {
                GrammarRulesListView(groups: groupedRules)
            }
        }
    }
}

struct GrammarSearchBar: View {
    @Binding var searchText: String
    
    init(searchText: Binding<String>) {
        self._searchText = searchText
    }
    
    var body: some View {
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
        .padding()
        .background(Color(.systemBackground))
    }
}

struct GrammarFilterSection: View {
    @Binding var selectedCategory: String
    @Binding var selectedDifficulty: String
    
    init(selectedCategory: Binding<String>, selectedDifficulty: Binding<String>) {
        self._selectedCategory = selectedCategory
        self._selectedDifficulty = selectedDifficulty
    }
    
    private var dataManager = GrammarDataManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(dataManager.getCategories()) { category in
                        GrammarCategoryFilterButton(
                            category: category,
                            isSelected: selectedCategory == category.id,
                            action: { selectedCategory = category.id }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GrammarDifficulty.allCases, id: \.rawValue) { difficulty in
                        GrammarDifficultyFilterButton(
                            difficulty: difficulty,
                            isSelected: selectedDifficulty == difficulty.rawValue,
                            action: { selectedDifficulty = difficulty.rawValue }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
}

struct GrammarCategoryFilterButton: View {
    let category: GrammarCategory
    let isSelected: Bool
    let action: () -> Void
    
    init(category: GrammarCategory, isSelected: Bool, action: @escaping () -> Void) {
        self.category = category
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(category.icon)
                    .font(.caption)
                Text(category.label)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color(hex: category.color) : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct GrammarDifficultyFilterButton: View {
    let difficulty: GrammarDifficulty
    let isSelected: Bool
    let action: () -> Void
    
    init(difficulty: GrammarDifficulty, isSelected: Bool, action: @escaping () -> Void) {
        self.difficulty = difficulty
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(difficulty.label)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color(hex: difficulty.color) : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .secondary)
                .cornerRadius(16)
        }
    }
}

struct GrammarRulesListView: View {
    let groups: [GrammarGroup]
    
    init(groups: [GrammarGroup]) {
        self.groups = groups
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(groups) { group in
                    Section {
                        ForEach(group.rules) { rule in
                            GrammarRuleCard(rule: rule)
                        }
                    } header: {
                        GrammarGroupHeader(label: group.label)
                    }
                }
            }
        }
    }
}

struct GrammarGroupHeader: View {
    let label: String
    
    init(label: String) {
        self.label = label
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.blue.opacity(0.1))
    }
}

struct GrammarRuleCard: View {
    let rule: GrammarRule
    @State private var isExpanded = false
    
    init(rule: GrammarRule) {
        self.rule = rule
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(rule.rule)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    GrammarDifficultyBadge(difficulty: rule.difficulty)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if isExpanded {
                    Text(rule.content)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let example = rule.example, !example.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("💡 \(example)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.top, 4)
                    }
                    
                    if let translation = rule.translation, !translation.isEmpty {
                        HStack(spacing: 4) {
                            Text("ℹ️")
                                .font(.caption)
                            Text(translation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }
            
            Divider()
                .background(Color.black.opacity(0.05))
        }
    }
}

struct GrammarDifficultyBadge: View {
    let difficulty: String
    
    init(difficulty: String) {
        self.difficulty = difficulty
    }
    
    private var color: Color {
        switch difficulty {
        case "débutant": return Color(hex: "#27AE60")
        case "intermédiaire": return Color(hex: "#F39C12")
        case "avancé": return Color(hex: "#E74C3C")
        default: return Color(hex: "#95A5A6")
        }
    }
    
    var body: some View {
        Text(difficulty)
            .font(.system(size: 9))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(10)
    }
}

struct GrammarEmptyStateView: View {
    init() {}
    
    var body: some View {
        VStack(spacing: 8) {
            Text("🔍")
                .font(.system(size: 48))
            Text("Aucune règle trouvée")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}
