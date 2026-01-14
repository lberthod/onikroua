import SwiftUI

// MARK: - Reusable Card Components

struct CardView<Content: View>: View {
    let content: Content
    var backgroundColor: Color = Color(.systemBackground)
    var cornerRadius: CGFloat = AppConstants.UI.cornerRadius
    var shadow: Bool = true
    
    init(
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = AppConstants.UI.cornerRadius,
        shadow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.content = content()
    }
    
    var body: some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .if(shadow) { view in
                view.shadow(
                    color: .black.opacity(AppConstants.UI.cardShadowOpacity),
                    radius: AppConstants.UI.cardShadowRadius,
                    x: 0,
                    y: 2
                )
            }
    }
}

// MARK: - Language Selector

struct LanguageSelector: View {
    @Binding var selectedLanguage: String
    let languages: [(code: String, flag: String, name: String)]
    
    init(selectedLanguage: Binding<String>) {
        self._selectedLanguage = selectedLanguage
        self.languages = [
            (code: "it", flag: "🇮🇹", name: "Italien"),
            (code: "es", flag: "🇪🇸", name: "Espagnol")
        ]
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(languages, id: \.code) { language in
                Button(action: {
                    withAnimation(.spring(response: AppConstants.Animation.springResponse, dampingFraction: AppConstants.Animation.springDamping)) {
                        selectedLanguage = language.code
                    }
                }) {
                    HStack(spacing: 6) {
                        Text(language.flag)
                            .font(.title3)
                        if selectedLanguage == language.code {
                            Text(language.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        selectedLanguage == language.code
                            ? Color.blue
                            : Color(.systemGray6)
                    )
                    .foregroundColor(
                        selectedLanguage == language.code
                            ? .white
                            : .primary
                    )
                    .cornerRadius(20)
                }
            }
        }
    }
}

// MARK: - Empty State View
// Note: EmptyStateView a été déplacé vers Views/Components/EmptyStateView.swift
// pour une meilleure organisation et plus de fonctionnalités

// MARK: - Loading View

struct LoadingView: View {
    var message: String = "Chargement..."
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Badge View

struct BadgeView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(10)
    }
}

// MARK: - Difficulty Badge

struct DifficultyBadge: View {
    let difficulty: String
    
    private var color: Color {
        switch difficulty.lowercased() {
        case "débutant": return Color(hex: "#27AE60")
        case "intermédiaire": return Color(hex: "#F39C12")
        case "avancé": return Color(hex: "#E74C3C")
        default: return Color(hex: "#95A5A6")
        }
    }
    
    var body: some View {
        BadgeView(text: difficulty.capitalized, color: color)
    }
}

// MARK: - Section Header

struct SectionHeaderView: View {
    let title: String
    let icon: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        title: String,
        icon: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                if let icon = icon {
                    Text(icon)
                        .font(.title3)
                }
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal, AppConstants.UI.padding)
        .padding(.vertical, 8)
    }
}

// MARK: - Conditional View Modifier

extension View {
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
