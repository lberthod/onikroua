import SwiftUI

struct PhoneticView: View {
    @EnvironmentObject var env: AppEnvironment
    
    let phoneticData = [
        PhoneticData(letter: "A E I O U", pronunciation: "Voyelles - prononciation claire", example: "amore, vero, vino"),
        PhoneticData(letter: "C + a/o/u", pronunciation: "[k] comme 'car'", example: "casa, come, cuore"),
        PhoneticData(letter: "C + e/i", pronunciation: "[tʃ] comme 'tchao'", example: "ciao, cena, città"),
        PhoneticData(letter: "CH", pronunciation: "[k] toujours dur", example: "perché, chiave"),
        PhoneticData(letter: "G + a/o/u", pronunciation: "[g] comme 'gare'", example: "gatto, gusto"),
        PhoneticData(letter: "G + e/i", pronunciation: "[dʒ] comme 'djinn'", example: "gelato, giorno"),
        PhoneticData(letter: "GH", pronunciation: "[g] toujours dur", example: "spaghetti, laghi"),
        PhoneticData(letter: "GL + i", pronunciation: "[ʎ] comme 'ail'", example: "famiglia, foglia"),
        PhoneticData(letter: "GN", pronunciation: "[ɲ] comme 'gn'", example: "gnocchi, bagno"),
        PhoneticData(letter: "SC + e/i", pronunciation: "[ʃ] comme 'ch'", example: "pesce, scienza"),
        PhoneticData(letter: "SC + a/o/u", pronunciation: "[sk] dur", example: "scala, scuola"),
        PhoneticData(letter: "Z/ZZ", pronunciation: "[ts] ou [dz]", example: "pizza, zio, grazie"),
        PhoneticData(letter: "R", pronunciation: "Roulé avec la langue", example: "Roma, rosso, treno"),
        PhoneticData(letter: "H", pronunciation: "Toujours muet", example: "ho, hai, hanno"),
        PhoneticData(letter: "Double", pronunciation: "Consonnes renforcées", example: "caffè, pizza, bella"),
        PhoneticData(letter: "Accent", pronunciation: "Généralement avant-dernière syllabe", example: "parLAre, caFFÈ, CIttà")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(phoneticData) { data in
                    PhoneticCard(data: data)
                }
            }
            .padding()
        }
        .navigationTitle("Phonétique")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct PhoneticData: Identifiable {
    let id = UUID()
    let letter: String
    let pronunciation: String
    let example: String
}

struct PhoneticCard: View {
    let data: PhoneticData
    @StateObject private var speechService = SpeechService()
    
    var body: some View {
        HStack(spacing: 16) {
            Text(data.letter)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.pink)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(data.pronunciation)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Ex: \(data.example)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { speechService.speak(data.example, language: "it-IT") }) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.pink)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        PhoneticView()
    }
}
