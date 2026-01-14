import SwiftUI

struct ContentView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var userEmail: String = "utilisateur@onykroua.com"
    @State private var showProfile = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Offline banner
                OfflineBanner(networkMonitor: env.networkMonitor)
                
                // Sync status
                SyncStatusView(syncManager: env.syncManager, networkMonitor: env.networkMonitor)
                
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ciao!")
                                .font(.title)
                                .fontWeight(.bold)
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { showProfile = true }) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    VStack(spacing: 16) {
                        Text("Continuer l'apprentissage")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: FeedView()) {
                            ContinueCard()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    VStack(spacing: 16) {
                        Text("Catégories")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            NavigationLink(destination: ConjugationView()) {
                                CategoryCard(icon: "book.fill", title: "Conjugaison", color: .blue)
                            }
                            
                            NavigationLink(destination: VocabularyView()) {
                                CategoryCard(icon: "text.book.closed.fill", title: "Vocabulaire", color: .green)
                            }
                            
                            NavigationLink(destination: EmojiView()) {
                                CategoryCard(icon: "face.smiling.fill", title: "Emoji", color: .orange)
                            }
                            
                            NavigationLink(destination: ConversationView()) {
                                CategoryCard(icon: "message.fill", title: "Conversation", color: .purple)
                            }
                            
                            NavigationLink(destination: GrammarView()) {
                                CategoryCard(icon: "text.alignleft", title: "Grammaire", color: .red)
                            }
                            
                            NavigationLink(destination: PhoneticView()) {
                                CategoryCard(icon: "speaker.wave.3.fill", title: "Phonétique", color: .pink)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 16) {
                        Text("Pratique")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: GeminiLiveView()) {
                            PracticeCard(
                                icon: "mic.fill",
                                title: "Gemini Live",
                                subtitle: "Conversation avec l'IA",
                                color: .indigo
                            )
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Version footer
                    VStack(spacing: 4) {
                        Text("onykroua")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("Version 1.1 (8)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                }
            }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
}

struct ContinueCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Révision quotidienne")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("10 mots à réviser")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct CategoryCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.white)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [color, color.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct PracticeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
