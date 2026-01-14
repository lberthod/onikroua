import SwiftUI

struct GrammarView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedTab = 0
    @State private var currentLanguage = "it"
    
    private var totalRules: Int {
        env.grammarManager.getGrammarRules(language: currentLanguage).count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("📚 Règles").tag(0)
                Text("🗂️ Catégories").tag(1)
                Text("⚡ Aide-mémoire").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                RulesGrammarTab(language: currentLanguage)
                    .tag(0)
                
                CategoriesGrammarTab(language: currentLanguage)
                    .tag(1)
                
                QuickReferenceGrammarTab(language: currentLanguage)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("📖 Grammaire (\(totalRules))")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { currentLanguage = "it" }) {
                        Label("Italien", systemImage: currentLanguage == "it" ? "checkmark" : "")
                    }
                    Button(action: { currentLanguage = "es" }) {
                        Label("Espagnol", systemImage: currentLanguage == "es" ? "checkmark" : "")
                    }
                } label: {
                    Text(currentLanguage == "it" ? "🇮🇹" : "🇪🇸")
                        .font(.title2)
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    NavigationView {
        GrammarView()
    }
}
