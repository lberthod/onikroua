import SwiftUI

public struct RulesTab: View {
    public let grammarData: GrammarData
    public let language: String
    @ObservedObject var speechService: SpeechService
    @State private var selectedCategory = "Groupes"
    
    public init(grammarData: GrammarData, language: String, speechService: SpeechService) {
        self.grammarData = grammarData
        self.language = language
        self.speechService = speechService
    }
    
    private var rules: [GrammarRule] {
        grammarData.getGrammarRules(language: language)
    }
    
    private var categories: [String] {
        Array(Set(rules.map { $0.category })).sorted()
    }
    
    private var filteredRules: [GrammarRule] {
        rules.filter { $0.category == selectedCategory }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Category Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: { 
                            withAnimation(.spring()) { selectedCategory = category }
                        }) {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.blue : Color(.systemGray6))
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // Rules List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredRules) { rule in
                        RuleCard(rule: rule, speechService: speechService)
                    }
                }
                .padding()
            }
        }
    }
}

public struct RuleCard: View {
    let rule: GrammarRule
    @ObservedObject var speechService: SpeechService
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(rule.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(rule.category)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: { 
                    speechService.speak(rule.title, language: rule.title.contains("ser") || rule.title.contains("estar") ? "es-ES" : "it-IT")
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            
            Text(rule.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            if !rule.examples.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Exemples:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(rule.examples, id: \.self) { example in
                        HStack {
                            Text("• \(example)")
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: { 
                                speechService.speak(example, language: example.contains("Soy") || example.contains("Estoy") ? "es-ES" : "it-IT")
                            }) {
                                Image(systemName: "speaker.wave.1.fill")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
