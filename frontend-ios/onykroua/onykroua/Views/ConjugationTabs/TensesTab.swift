import SwiftUI

public struct TensesTab: View {
    public let grammarData: GrammarData
    public let language: String
    @ObservedObject var speechService: SpeechService
    
    public init(grammarData: GrammarData, language: String, speechService: SpeechService) {
        self.grammarData = grammarData
        self.language = language
        self.speechService = speechService
    }
    
    private var tenses: [TenseInfo] {
        grammarData.getTenses(language: language)
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(tenses) { tense in
                    TenseCard(tense: tense, speechService: speechService, language: language)
                }
            }
            .padding()
        }
    }
}

public struct TenseCard: View {
    let tense: TenseInfo
    @ObservedObject var speechService: SpeechService
    let language: String
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tense.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Temps verbal")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: { 
                    speechService.speak(tense.name, language: language == "it" ? "it-IT" : "es-ES")
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            
            Text(tense.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Exemple:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(tense.example)
                        .font(.body)
                        .foregroundColor(.primary)
                        .italic()
                }
                
                Spacer()
                
                Button(action: { 
                    speechService.speak(tense.example, language: language == "it" ? "it-IT" : "es-ES")
                }) {
                    Image(systemName: "speaker.wave.1.fill")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
