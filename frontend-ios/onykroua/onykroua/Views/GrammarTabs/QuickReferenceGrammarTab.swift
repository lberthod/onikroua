import SwiftUI

struct QuickReferenceGrammarTab: View {
    let language: String
    
    private var dataManager = GrammarDataManager.shared
    
    init(language: String) {
        self.language = language
    }
    
    private var essentialRules: [GrammarRule] {
        let allRules = dataManager.getGrammarRules(language: language)
        return allRules.filter { $0.difficulty == "débutant" }.prefix(20).map { $0 }
    }
    
    private var quickTips: [GrammarQuickTip] {
        if language == "it" {
            return italianQuickTips
        } else {
            return spanishQuickTips
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GrammarQuickTipsSection(tips: quickTips)
                
                Divider()
                    .padding(.horizontal)
                
                GrammarEssentialRulesSection(rules: essentialRules)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct GrammarQuickTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let content: String
}

struct GrammarQuickTipsSection: View {
    let tips: [GrammarQuickTip]
    
    init(tips: [GrammarQuickTip]) {
        self.tips = tips
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 Aide-mémoire")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 4)
            
            ForEach(tips) { tip in
                GrammarQuickTipCard(tip: tip)
            }
        }
    }
}

struct GrammarQuickTipCard: View {
    let tip: GrammarQuickTip
    
    init(tip: GrammarQuickTip) {
        self.tip = tip
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(tip.icon)
                    .font(.title3)
                
                Text(tip.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Text(tip.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct GrammarEssentialRulesSection: View {
    let rules: [GrammarRule]
    
    init(rules: [GrammarRule]) {
        self.rules = rules
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📚 Règles essentielles")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 4)
            
            ForEach(rules) { rule in
                GrammarCompactRuleCard(rule: rule)
            }
        }
    }
}

struct GrammarCompactRuleCard: View {
    let rule: GrammarRule
    
    init(rule: GrammarRule) {
        self.rule = rule
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(rule.rule)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(rule.content.components(separatedBy: "\n").first ?? rule.content)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

private let italianQuickTips: [GrammarQuickTip] = [
    GrammarQuickTip(
        icon: "📰",
        title: "Articles définis",
        content: "IL/I pour masculin normal, LO/GLI devant s+consonne/z/gn. LA/L'/LE pour féminin."
    ),
    GrammarQuickTip(
        icon: "⚡",
        title: "Présent des verbes",
        content: "-ARE: -o, -i, -a, -iamo, -ate, -ano\n-ERE: -o, -i, -e, -iamo, -ete, -ono\n-IRE: -o, -i, -e, -iamo, -ite, -ono"
    ),
    GrammarQuickTip(
        icon: "✨",
        title: "Accord des adjectifs",
        content: "Masculin -o → Féminin -a. Pluriel: -i (masc), -e (fém). Adjectifs en -e invariables au masculin/féminin."
    ),
    GrammarQuickTip(
        icon: "🔗",
        title: "Prépositions articulées",
        content: "Préposition + article = contraction obligatoire. Ex: a + il = al, di + la = della, in + i = nei"
    ),
    GrammarQuickTip(
        icon: "👤",
        title: "Pronoms sujets",
        content: "Souvent omis en italien car la terminaison du verbe indique la personne. Utilisés pour l'emphase."
    )
]

private let spanishQuickTips: [GrammarQuickTip] = [
    GrammarQuickTip(
        icon: "📰",
        title: "Articles définis",
        content: "EL/LOS (masculin), LA/LAS (féminin). Plus simple qu'en italien, seulement 4 formes."
    ),
    GrammarQuickTip(
        icon: "⚡",
        title: "Présent des verbes",
        content: "-AR: -o, -as, -a, -amos, -áis, -an\n-ER: -o, -es, -e, -emos, -éis, -en\n-IR: -o, -es, -e, -imos, -ís, -en"
    ),
    GrammarQuickTip(
        icon: "✨",
        title: "Accord des adjectifs",
        content: "Masculin -o → Féminin -a. Pluriel: +s ou +es. Adjectifs en -e invariables au masculin/féminin."
    ),
    GrammarQuickTip(
        icon: "🎯",
        title: "Ser vs Estar",
        content: "SER = caractéristique permanente, identité. ESTAR = état temporaire, localisation."
    ),
    GrammarQuickTip(
        icon: "👤",
        title: "Pronoms sujets",
        content: "Yo, tú, él/ella, nosotros, vosotros, ellos. Souvent omis comme en italien."
    )
]
