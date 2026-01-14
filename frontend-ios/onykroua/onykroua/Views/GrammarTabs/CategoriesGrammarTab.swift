import SwiftUI

struct CategoriesGrammarTab: View {
    let language: String
    @State private var selectedCategory: GrammarCategory?
    
    private var dataManager = GrammarDataManager.shared
    
    init(language: String) {
        self.language = language
    }
    
    private var categories: [GrammarCategory] {
        dataManager.getCategories().filter { $0.id != "all" }
    }
    
    private var rulesForSelectedCategory: [GrammarRule] {
        guard let category = selectedCategory else { return [] }
        let allRules = dataManager.getGrammarRules(language: language)
        return allRules.filter { $0.category == category.id }
    }
    
    var body: some View {
        if let selected = selectedCategory {
            GrammarCategoryDetailView(
                category: selected,
                rules: rulesForSelectedCategory,
                onBack: { selectedCategory = nil }
            )
        } else {
            GrammarCategoryGridView(
                categories: categories,
                onSelect: { selectedCategory = $0 }
            )
        }
    }
}

struct GrammarCategoryGridView: View {
    let categories: [GrammarCategory]
    let onSelect: (GrammarCategory) -> Void
    
    init(categories: [GrammarCategory], onSelect: @escaping (GrammarCategory) -> Void) {
        self.categories = categories
        self.onSelect = onSelect
    }
    
    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(categories) { category in
                    GrammarCategoryCardButton(category: category, action: { onSelect(category) })
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct GrammarCategoryCardButton: View {
    let category: GrammarCategory
    let action: () -> Void
    
    init(category: GrammarCategory, action: @escaping () -> Void) {
        self.category = category
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(category.icon)
                    .font(.system(size: 48))
                
                Text(category.label)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: Color(hex: category.color).opacity(0.2), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: category.color).opacity(0.3), lineWidth: 2)
            )
        }
    }
}

struct GrammarCategoryDetailView: View {
    let category: GrammarCategory
    let rules: [GrammarRule]
    let onBack: () -> Void
    
    init(category: GrammarCategory, rules: [GrammarRule], onBack: @escaping () -> Void) {
        self.category = category
        self.rules = rules
        self.onBack = onBack
    }
    
    private var dataManager = GrammarDataManager.shared
    
    private var groupedRules: [GrammarGroup] {
        dataManager.groupRules(rules)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            GrammarCategoryDetailHeader(category: category, onBack: onBack, ruleCount: rules.count)
            
            Divider()
            
            if rules.isEmpty {
                GrammarEmptyStateView()
            } else {
                GrammarRulesListView(groups: groupedRules)
            }
        }
    }
}

struct GrammarCategoryDetailHeader: View {
    let category: GrammarCategory
    let onBack: () -> Void
    let ruleCount: Int
    
    init(category: GrammarCategory, onBack: @escaping () -> Void, ruleCount: Int) {
        self.category = category
        self.onBack = onBack
        self.ruleCount = ruleCount
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            Text(category.icon)
                .font(.title)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.label)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("\(ruleCount) règle\(ruleCount > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(hex: category.color).opacity(0.1))
    }
}
