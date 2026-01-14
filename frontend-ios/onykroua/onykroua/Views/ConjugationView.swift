import SwiftUI
import AVFoundation

struct ConjugationView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedTab = 0
    @State private var selectedVerb = "essere"
    @State private var selectedTense = "Présent"
    @State private var showingQuiz = false
    @State private var searchText = ""
    @State private var selectedFilter = "all"
    @State private var expandedVerbId: String? = nil
    @State private var currentLanguage = "it"
    
    let grammarData = GrammarData()
    
    private var filteredVerbs: [Verb] {
        let allVerbs = grammarData.getVerbs(language: currentLanguage)
        var filtered = allVerbs.filter { verb in
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
        
        return filtered
    }
    
    private func getVerbLabels(_ verb: String) -> [String] {
        let cleanVerb = verb.replacingOccurrences(of: " --", with: "").trimmingCharacters(in: .whitespaces)
        var labels: [String] = []
        
        if currentLanguage == "it" {
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
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("📚 Règles").tag(0)
                Text("✏️ Verbes").tag(1)
                Text("⏰ Temps").tag(2)
                Text("🎮 Pratique").tag(3)
                Text("➕ Plus").tag(4)
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                RulesTab(grammarData: grammarData, language: currentLanguage)
                    .tag(0)
                VerbsTab(
                    grammarData: grammarData,
                    language: currentLanguage,
                    searchText: $searchText,
                    selectedFilter: $selectedFilter,
                    expandedVerbId: $expandedVerbId,
                    selectedTense: $selectedTense
                )
                .tag(1)
                TensesTab(grammarData: grammarData, language: currentLanguage)
                    .tag(2)
                PracticeTab(grammarData: grammarData, language: currentLanguage)
                    .tag(3)
                MoreTab(grammarData: grammarData, language: currentLanguage)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("📖 Conjugaison & Grammaire")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    NavigationView {
        ConjugationView()
    }
}
