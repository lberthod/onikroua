import SwiftUI

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 72, weight: .thin))
                .foregroundColor(.secondary)
            
            // Title
            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            // Description
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            // Action button (optional)
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State Types

extension EmptyStateView {
    // No words learned yet
    static var noWordsLearned: EmptyStateView {
        EmptyStateView(
            icon: "book.closed",
            title: "Aucun mot appris",
            description: "Commencez à apprendre des mots pour les voir apparaître ici",
            actionTitle: "Explorer le vocabulaire",
            action: nil
        )
    }
    
    // No favorites
    static var noFavorites: EmptyStateView {
        EmptyStateView(
            icon: "heart",
            title: "Aucun favori",
            description: "Marquez vos mots préférés en appuyant sur ❤️ pour les retrouver facilement",
            actionTitle: "Découvrir des mots",
            action: nil
        )
    }
    
    // No search results
    static func noSearchResults(query: String) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "Aucun résultat",
            description: "Aucun mot ne correspond à \"\(query)\". Essayez une autre recherche.",
            actionTitle: "Effacer la recherche",
            action: nil
        )
    }
    
    // No internet connection
    static var noConnection: EmptyStateView {
        EmptyStateView(
            icon: "wifi.slash",
            title: "Hors ligne",
            description: "Vous êtes en mode hors ligne. Certaines fonctionnalités peuvent être limitées.",
            actionTitle: "Réessayer",
            action: nil
        )
    }
    
    // Error state
    static func error(message: String) -> EmptyStateView {
        EmptyStateView(
            icon: "exclamationmark.triangle",
            title: "Une erreur s'est produite",
            description: message,
            actionTitle: "Réessayer",
            action: nil
        )
    }
    
    // No feed items
    static var noFeedItems: EmptyStateView {
        EmptyStateView(
            icon: "newspaper",
            title: "Aucun contenu",
            description: "Chargez plus de contenu pour continuer votre apprentissage",
            actionTitle: "Rafraîchir",
            action: nil
        )
    }
    
    // No grammar rules
    static var noGrammarRules: EmptyStateView {
        EmptyStateView(
            icon: "book.pages",
            title: "Aucune règle",
            description: "Aucune règle de grammaire disponible pour cette catégorie",
            actionTitle: nil,
            action: nil
        )
    }
    
    // Loading state
    static var loading: EmptyStateView {
        EmptyStateView(
            icon: "arrow.clockwise",
            title: "Chargement...",
            description: "Veuillez patienter pendant le chargement des données",
            actionTitle: nil,
            action: nil
        )
    }
}

// MARK: - Loading Skeleton View

struct LoadingSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { _ in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 16)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 150, height: 12)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .opacity(isAnimating ? 0.5 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Preview

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmptyStateView.noWordsLearned
            EmptyStateView.noFavorites
            EmptyStateView.noSearchResults(query: "test")
            EmptyStateView.noConnection
            LoadingSkeletonView()
        }
    }
}
