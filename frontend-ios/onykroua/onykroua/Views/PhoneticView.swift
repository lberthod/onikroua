import SwiftUI

struct PhoneticView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            PhoneticExplorerTab()
                .environmentObject(env)
                .tabItem {
                    Label("Explorer", systemImage: "magnifyingglass")
                }
                .tag(0)

            PhoneticCategoriesTab()
                .environmentObject(env)
                .tabItem {
                    Label("Catégories", systemImage: "square.grid.2x2.fill")
                }
                .tag(1)

            PhoneticPracticeTab()
                .environmentObject(env)
                .tabItem {
                    Label("Pratiquer", systemImage: "gamecontroller")
                }
                .tag(2)
        }
        .navigationTitle("🔊 Phonétique")
    }
}

struct PhoneticExplorerTab: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var searchText = ""
    @State private var selectedFilter: String = "Tous"
    
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
            
            let matchesFilter = selectedFilter == "Tous" || item.type == selectedFilter
            
            return matchesSearch && matchesFilter
        }
    }
    
    private let chips: [String] = ["Tous", "Voyelles", "Consonnes", "Accents"]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: UI.Spacing.md) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher un son...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(UI.Spacing.md)
                .background(UI.Surface.searchBackground)
                .cornerRadius(UI.Radius.r12)
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: UI.Spacing.md) {
                        ForEach(chips, id: \.self) { chip in
                            EmojiStyleFilterButton(
                                title: chip,
                                isSelected: selectedFilter == chip
                            ) {
                                selectedFilter = chip
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, UI.Spacing.md)
            .background(UI.Surface.background)
            
            ScrollView {
                if filteredData.isEmpty {
                    EmptyState(
                        title: "Aucun son trouvé",
                        message: "Essaie un autre filtre ou une autre recherche",
                        icon: "mouth"
                    )
                    .padding(.top, UI.Spacing.huge)
                } else {
                    LazyVStack(spacing: UI.Spacing.md) {
                        ForEach(filteredData) { data in
                            PhoneticCard(data: data)
                                .padding(.horizontal, UI.Spacing.md)
                        }
                    }
                }
            }
            .background(UI.Surface.groupedBackground)
            
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.blue)
                Text("\(filteredData.count) sons")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, UI.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(UI.Surface.background)
        }
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
        EmojiStyleCard {
            HStack(spacing: UI.Spacing.lg) {
                Text(data.letter)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.pink)
                    .cornerRadius(UI.Radius.r12)
                
                VStack(alignment: .leading, spacing: UI.Spacing.sm) {
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
        VStack(spacing: UI.Spacing.xxl) {
            VStack(spacing: UI.Spacing.md) {
                Text("🎮 Mode Pratique")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choisis ton type d'entraînement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, UI.Spacing.huge)
            
            VStack(spacing: UI.Spacing.md) {
                EmojiStylePracticeButton(
                    icon: "👂",
                    title: "Dictée de sons",
                    subtitle: "Écoute et identifie le son correct",
                    color: .pink
                ) {
                    // Start practice
                }

                EmojiStylePracticeButton(
                    icon: "🎤",
                    title: "Reconnaissance vocale",
                    subtitle: "Prononce les mots correctement",
                    color: .indigo
                ) {
                    // Start mic practice
                }
            }
            .padding(.horizontal, UI.Spacing.xxxl)
            
            Spacer()
            
            NavigationLink(destination: Text("Practice View")) {
                EmojiStyleCTAButton(
                    title: "Commencer",
                    icon: "play.fill"
                ) {
                    
                }
            }
            .padding(.horizontal, UI.Spacing.xxxl)
            .padding(.bottom, UI.Spacing.huge)
        }
        .background(UI.Surface.groupedBackground)
    }
}

struct PhoneticCategoriesTab: View {
    @EnvironmentObject var env: AppEnvironment

    let categories = [
        PhoneticCategory(id: "voyelles", name: "Voyelles", icon: "a.circle.fill", color: .blue, count: 5),
        PhoneticCategory(id: "consonnes", name: "Consonnes", icon: "c.circle.fill", color: .green, count: 10),
        PhoneticCategory(id: "accents", name: "Accents", icon: "italic", color: .orange, count: 2),
        PhoneticCategory(id: "doubles", name: "Doubles", icon: "textformat", color: .purple, count: 3),
        PhoneticCategory(id: "special", name: "Spéciaux", icon: "star.fill", color: .pink, count: 4)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: UI.Spacing.md) {
                ForEach(categories) { category in
                    EmojiStyleCategoryRow {
                        VStack(spacing: UI.Spacing.md) {
                            Image(systemName: category.icon)
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(category.color)
                                .cornerRadius(UI.Radius.r12)

                            VStack(spacing: UI.Spacing.sm) {
                                Text(category.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("\(category.count) sons")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(UI.Spacing.md)
        }
        .background(UI.Surface.groupedBackground)
    }
}

struct PhoneticCategory: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let count: Int
}

#Preview {
    NavigationView {
        PhoneticView()
    }
}
