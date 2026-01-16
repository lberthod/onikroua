import SwiftUI

struct PhoneticView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("📖 Explorer").tag(0)
                Text("🎯 Pratique").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color(.systemGroupedBackground))
            
            TabView(selection: $selectedTab) {
                PhoneticExplorerTab()
                    .tag(0)
                
                PhoneticPracticeTab()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Phonétique")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct PhoneticExplorerTab: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var searchText = ""
    @State private var selectedFilter: String? = nil
    
    let phoneticData = [
        PhoneticData(letter: "A E I O U", pronunciation: "Voyelles - prononciation claire", example: "amore, vero, vino", type: "voyelle"),
        PhoneticData(letter: "C + a/o/u", pronunciation: "[k] comme 'car'", example: "casa, come, cuore", type: "consonne"),
        PhoneticData(letter: "C + e/i", pronunciation: "[tʃ] comme 'tchao'", example: "ciao, cena, città", type: "consonne"),
        PhoneticData(letter: "CH", pronunciation: "[k] toujours dur", example: "perché, chiave", type: "consonne"),
        PhoneticData(letter: "G + a/o/u", pronunciation: "[g] comme 'gare'", example: "gatto, gusto", type: "consonne"),
        PhoneticData(letter: "G + e/i", pronunciation: "[dʒ] comme 'djinn'", example: "gelato, journo", type: "consonne"),
        PhoneticData(letter: "GH", pronunciation: "[g] toujours dur", example: "spaghetti, laghi", type: "consonne"),
        PhoneticData(letter: "GL + i", pronunciation: "[ʎ] comme 'ail'", example: "famiglia, foglia", type: "consonne"),
        PhoneticData(letter: "GN", pronunciation: "[ɲ] comme 'gn'", example: "gnocchi, bagno", type: "consonne"),
        PhoneticData(letter: "SC + e/i", pronunciation: "[ʃ] comme 'ch'", example: "pesce, scienza", type: "consonne"),
        PhoneticData(letter: "SC + a/o/u", pronunciation: "[sk] dur", example: "scala, scuola", type: "consonne"),
        PhoneticData(letter: "Z/ZZ", pronunciation: "[ts] ou [dz]", example: "pizza, zio, grazie", type: "consonne"),
        PhoneticData(letter: "R", pronunciation: "Roulé avec la langue", example: "Roma, rosso, treno", type: "consonne"),
        PhoneticData(letter: "H", pronunciation: "Toujours muet", example: "ho, hai, hanno", type: "consonne"),
        PhoneticData(letter: "Double", pronunciation: "Consonnes renforcées", example: "caffè, pizza, bella", type: "consonne"),
        PhoneticData(letter: "Accent", pronunciation: "Généralement avant-dernière syllabe", example: "parLAre, caFFÈ, CIttà", type: "accent")
    ]
    
    private var filteredData: [PhoneticData] {
        phoneticData.filter { item in
            let matchesSearch = searchText.isEmpty || 
                item.letter.localizedCaseInsensitiveContains(searchText) || 
                item.pronunciation.localizedCaseInsensitiveContains(searchText) || 
                item.example.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilter = selectedFilter == nil || item.type == selectedFilter
            
            return matchesSearch && matchesFilter
        }
    }
    
    private let chips: [ChipItem] = [
        .init(id: "voyelle", label: "Voyelles", icon: "a.circle"),
        .init(id: "consonne", label: "Consonnes", icon: "c.circle"),
        .init(id: "accent", label: "Accents", icon: "italic")
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: UI.Spacing.md, pinnedViews: [.sectionHeaders]) {
                Section {
                    if filteredData.isEmpty {
                        EmptyState(
                            title: "Aucun son trouvé",
                            message: "Essaie un autre filtre ou une autre recherche",
                            icon: "mouth"
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(filteredData) { data in
                            PhoneticCard(data: data)
                                .padding(.horizontal, UI.Spacing.lg)
                        }
                    }
                } header: {
                    StickyHeader(
                        title: "Explorer les sons",
                        subtitle: "Maîtrise la prononciation italienne",
                        searchText: $searchText,
                        chips: chips,
                        selectedChipId: selectedFilter,
                        onSelectChip: { selectedFilter = $0 },
                        countText: "\(filteredData.count) sons listés"
                    )
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct PhoneticData: Identifiable {
    let id = UUID()
    let letter: String
    let pronunciation: String
    let example: String
    let type: String // voyelle, consonne, accent
}

struct PhoneticCard: View {
    let data: PhoneticData
    @EnvironmentObject var env: AppEnvironment
    
    var body: some View {
        OnykrouaCard(isInteractive: true) {
            HStack(spacing: UI.Spacing.lg) {
                Text(data.letter)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.pink)
                    .cornerRadius(UI.Radius.r12)
                
                VStack(alignment: .leading, spacing: UI.Spacing.xs) {
                    Text(data.pronunciation)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Ex: \(data.example)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { env.speechService.speak(data.example, language: "it-IT") }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title3)
                        .foregroundColor(.pink)
                }
            }
            .padding(UI.Spacing.md)
        }
    }
}

struct PhoneticPracticeTab: View {
    var body: some View {
        ScrollView {
            VStack(spacing: UI.Spacing.lg) {
                PracticeModeCard(
                    title: "Dictée de sons",
                    subtitle: "Écoute et identifie le son correct",
                    icon: "ear",
                    color: .pink,
                    badge: "3 min"
                ) {
                    // Start practice
                }
                
                PracticeModeCard(
                    title: "Reconnaissance vocale",
                    subtitle: "Prononce les mots correctement",
                    icon: "mic.fill",
                    color: .indigo
                ) {
                    // Start mic practice
                }
            }
            .padding(UI.Spacing.lg)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationView {
        PhoneticView()
    }
}
