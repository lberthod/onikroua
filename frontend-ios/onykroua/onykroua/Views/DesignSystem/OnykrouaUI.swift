import SwiftUI

// MARK: - Design Tokens (Based on EmojiView_Enhanced.swift golden standard)

enum UI {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let huge: CGFloat = 40
    }
    
    enum Radius {
        static let r12: CGFloat = 12
        static let r16: CGFloat = 16
        static let r20: CGFloat = 20
    }
    
    enum Size {
        static let chipHeight: CGFloat = 34
        static let searchHeight: CGFloat = 44
        static let cardHeight: CGFloat = 140
        static let categoryIconSize: CGFloat = 60
        static let practiceIconSize: CGFloat = 70
        static let buttonHeight: CGFloat = 56
        static let headerTopPadding: CGFloat = 8
    }
    
    enum Shadow {
        static let card: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
            color: Color.black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 2
        )
        
        static let button: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
            color: Color.blue.opacity(0.3),
            radius: 10,
            x: 0,
            y: 5
        )
    }
    
    enum Surface {
        static let background = Color(.systemBackground)
        static let searchBackground = Color(.systemGray6)
        static let groupedBackground = Color(.systemGroupedBackground)
    }
}

// MARK: - Models

struct ChipItem: Identifiable, Equatable {
    let id: String
    let label: String
    var icon: String? = nil
    var badge: String? = nil
}

struct HeaderAction {
    let icon: String
    let action: () -> Void
}

// MARK: - Emoji-Style Components (Golden Standard)

struct OnykrouaCategoryRow: View {
    public enum IconStyle {
        case sfSymbol(String)
        case emoji(String)
    }

    let icon: IconStyle
    let accent: Color
    let title: String
    let subtitle: String?
    let countText: String?

    public init(
        icon: IconStyle,
        accent: Color = .accentColor,
        title: String,
        subtitle: String? = nil,
        countText: String? = nil
    ) {
        self.icon = icon
        self.accent = accent
        self.title = title
        self.subtitle = subtitle
        self.countText = countText
    }

    public var body: some View {
        HStack(spacing: UI.Spacing.lg) {
            // Icon tile (Emoji style)
            ZStack {
                RoundedRectangle(cornerRadius: UI.Radius.r12, style: .continuous)
                    .fill(accent.opacity(0.14))

                switch icon {
                case .sfSymbol(let name):
                    Image(systemName: name)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(accent)
                case .emoji(let emoji):
                    Text(emoji)
                        .font(.system(size: 28))
                }
            }
            .frame(width: UI.Size.categoryIconSize, height: UI.Size.categoryIconSize)

            // Texts
            VStack(alignment: .leading, spacing: UI.Spacing.xs) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let countText, !countText.isEmpty {
                    Text(countText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: UI.Spacing.sm)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(UI.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: UI.Radius.r16, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: UI.Radius.r16, style: .continuous)
                .stroke(Color(.separator).opacity(0.20), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: UI.Radius.r16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabelText)
    }

    private var accessibilityLabelText: String {
        var parts: [String] = [title]
        if let subtitle { parts.append(subtitle) }
        if let countText { parts.append(countText) }
        return parts.joined(separator: ", ")
    }
}

struct EmojiStyleFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, UI.Spacing.lg)
                .padding(.vertical, UI.Spacing.sm)
                .background(isSelected ? Color.blue : UI.Surface.searchBackground)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(UI.Radius.r20)
        }
    }
}

struct EmojiStyleCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(UI.Surface.background)
            .cornerRadius(UI.Radius.r12)
            .shadow(
                color: UI.Shadow.card.color,
                radius: UI.Shadow.card.radius,
                x: UI.Shadow.card.x,
                y: UI.Shadow.card.y
            )
    }
}

struct EmojiStyleCategoryRow<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(UI.Surface.background)
            .cornerRadius(UI.Radius.r16)
            .shadow(
                color: UI.Shadow.card.color,
                radius: UI.Shadow.card.radius,
                x: UI.Shadow.card.x,
                y: UI.Shadow.card.y
            )
    }
}

struct EmojiStylePracticeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: UI.Spacing.lg) {
                Text(icon)
                    .font(.system(size: 48))
                    .frame(width: UI.Size.practiceIconSize, height: UI.Size.practiceIconSize)
                    .background(color.opacity(0.1))
                    .cornerRadius(UI.Radius.r16)
                
                VStack(alignment: .leading, spacing: UI.Spacing.sm) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(color)
            }
            .padding()
            .background(UI.Surface.background)
            .cornerRadius(UI.Radius.r16)
            .shadow(
                color: UI.Shadow.card.color,
                radius: UI.Shadow.card.radius,
                x: UI.Shadow.card.x,
                y: UI.Shadow.card.y
            )
        }
        .buttonStyle(.plain)
    }
}

struct EmojiStyleCTAButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: UI.Size.buttonHeight)
            .background(
                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(UI.Radius.r16)
            .shadow(
                color: UI.Shadow.button.color,
                radius: UI.Shadow.button.radius,
                x: UI.Shadow.button.x,
                y: UI.Shadow.button.y
            )
        }
    }
}

// MARK: - Components

struct OnykrouaCard<Content: View>: View {
    let radius: CGFloat
    let isInteractive: Bool
    let content: Content
    
    init(radius: CGFloat = UI.Radius.r16, isInteractive: Bool = false, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.isInteractive = isInteractive
        self.content = content()
    }
    
    var body: some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(radius)
            .shadow(color: isInteractive ? Color.black.opacity(0.05) : Color.clear, radius: 8, x: 0, y: 2)
    }
}

struct StickyHeader: View {
    let title: String
    var subtitle: String? = nil
    @Binding var searchText: String
    var chips: [ChipItem] = []
    var selectedChipId: String? = nil
    var onSelectChip: ((String?) -> Void)? = nil
    var countText: String? = nil
    var trailingAction: HeaderAction? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: UI.Spacing.md) {
            // Title row
            HStack(alignment: .firstTextBaseline, spacing: UI.Spacing.md) {
                VStack(alignment: .leading, spacing: UI.Spacing.xs) {
                    Text(title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)

                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if let trailingAction {
                    Button(action: trailingAction.action) {
                        Image(systemName: trailingAction.icon)
                            .font(.headline.weight(.semibold))
                            .frame(width: 40, height: 40)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: UI.Radius.r12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            // Search
            HStack(spacing: UI.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Rechercher…", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, UI.Spacing.md)
            .frame(height: UI.Size.searchHeight)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: UI.Radius.r16, style: .continuous))

            // Chips
            if !chips.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: UI.Spacing.sm) {
                        ForEach(chips) { chip in
                            ChipButton(
                                label: chip.label,
                                icon: chip.icon,
                                badge: chip.badge,
                                isSelected: chip.id == selectedChipId
                            ) {
                                if selectedChipId == chip.id {
                                    onSelectChip?(nil)
                                } else {
                                    onSelectChip?(chip.id)
                                }
                            }
                        }
                    }
                    .padding(.vertical, UI.Spacing.xs)
                }
            }

            // Count
            if let countText {
                Text(countText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, UI.Spacing.lg)
        .padding(.top, UI.Size.headerTopPadding)
        .padding(.bottom, UI.Spacing.md)
        .background(Color(.systemGroupedBackground))
        .overlay(
            Divider()
                .opacity(0.35),
            alignment: .bottom
        )
    }
}

struct ChipButton: View {
    let label: String
    let icon: String?
    let badge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: UI.Spacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                }

                Text(label)
                    .font(.subheadline.weight(.semibold))

                if let badge {
                    Text(badge)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(Capsule())
                }
            }
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .padding(.horizontal, UI.Spacing.md)
            .frame(height: UI.Size.chipHeight)
            .background(
                RoundedRectangle(cornerRadius: UI.Radius.r12, style: .continuous)
                    .fill(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

struct PrimaryCTAButton: View {
    let title: String
    var icon: String? = nil
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: UI.Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: UI.Size.buttonHeight)
            .background(isDisabled ? Color.gray : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(UI.Radius.r16)
        }
        .disabled(isDisabled)
        .buttonStyle(.plain)
    }
}

struct EmptyState: View {
    let title: String
    let message: String
    var icon: String = "sparkles"
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: UI.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: UI.Spacing.sm) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .padding(.horizontal, UI.Spacing.xl)
                        .padding(.vertical, UI.Spacing.md)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(UI.Radius.r12)
                }
            }
        }
        .padding(UI.Spacing.xxl)
        .frame(maxWidth: .infinity)
    }
}

struct SectionHeader: View {
    let title: String
    var trailing: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            if let trailing, let action {
                Button(action: action) {
                    Text(trailing)
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding(.horizontal, UI.Spacing.lg)
    }
}

struct PracticeModeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var badge: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: UI.Spacing.lg) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .cornerRadius(UI.Radius.r12)
                
                VStack(alignment: .leading, spacing: UI.Spacing.xs) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let badge {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)
            }
            .padding(UI.Spacing.md)
            .background(Color(.systemBackground))
            .cornerRadius(UI.Radius.r16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct LanguagePicker: View {
    @Binding var currentLanguage: String

    var body: some View {
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

// MARK: - Module Components

struct ModuleTopBar: View {
    let title: String
    var icon: String? = nil
    var showBackButton: Bool = false
    var onBack: (() -> Void)? = nil
    var trailingAction: HeaderAction? = nil

    var body: some View {
        HStack(spacing: UI.Spacing.md) {
            if showBackButton, let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            } else {
                Spacer()
                    .frame(width: 40)
            }

            Spacer()

            HStack(spacing: UI.Spacing.sm) {
                if let icon {
                    Text(icon)
                        .font(.title2)
                }
                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            Spacer()

            if let trailingAction {
                Button(action: trailingAction.action) {
                    Image(systemName: trailingAction.icon)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            } else {
                Spacer()
                    .frame(width: 40)
            }
        }
        .padding(.horizontal, UI.Spacing.lg)
        .padding(.vertical, UI.Spacing.md)
        .background(Color(.systemGroupedBackground))
    }
}

struct ModuleBottomTabs: View {
    @Binding var selectedTab: ModuleTab
    var onTabChange: ((ModuleTab) -> Void)? = nil

    enum ModuleTab: String, CaseIterable {
        case explorer = "Dictionnaire"
        case learning = "Apprentissage"
        case categories = "Catégories"
        case practice = "Pratique"

        var icon: String {
            switch self {
            case .explorer: return "book"
            case .learning: return "graduationcap"
            case .categories: return "square.grid.2x2"
            case .practice: return "gamecontroller"
            }
        }

        var filledIcon: String {
            switch self {
            case .explorer: return "book.fill"
            case .learning: return "graduationcap.fill"
            case .categories: return "square.grid.2x2.fill"
            case .practice: return "gamecontroller.fill"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .opacity(0.35)

            HStack(spacing: 0) {
                ForEach(ModuleTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                            onTabChange?(tab)
                        }
                    }) {
                        VStack(spacing: UI.Spacing.xs) {
                            Image(systemName: selectedTab == tab ? tab.filledIcon : tab.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.secondary)

                            Text(tab.rawValue)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, UI.Spacing.sm)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Previews

#Preview("ModuleTopBar") {
    VStack(spacing: 0) {
        ModuleTopBar(
            title: "Phonétique",
            icon: "🔊",
            showBackButton: true,
            onBack: {},
            trailingAction: HeaderAction(icon: "gearshape") {}
        )
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("ModuleBottomTabs") {
    VStack(spacing: 0) {
        Spacer()
        ModuleBottomTabs(selectedTab: .constant(.explorer))
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("StickyHeader") {
    ScrollView {
        VStack(spacing: 20) {
            StickyHeader(
                title: "Explorer les sons",
                subtitle: "Maîtrise la prononciation italienne",
                searchText: .constant(""),
                chips: [
                    ChipItem(id: "voyelle", label: "Voyelles", icon: "a.circle"),
                    ChipItem(id: "consonne", label: "Consonnes", icon: "c.circle"),
                    ChipItem(id: "accent", label: "Accents", icon: "italic")
                ],
                selectedChipId: "voyelle",
                onSelectChip: { _ in },
                countText: "15 sons listés"
            )

            ForEach(0..<5) { _ in
                OnykrouaCard {
                    Text("Card content")
                        .frame(height: 80)
                }
                .padding(.horizontal, UI.Spacing.lg)
            }
        }
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("ChipButton") {
    HStack(spacing: UI.Spacing.sm) {
        ChipButton(
            label: "Voyelles",
            icon: "a.circle",
            badge: "5",
            isSelected: true
        ) {}

        ChipButton(
            label: "Consonnes",
            icon: "c.circle",
            badge: nil,
            isSelected: false
        ) {}
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("OnykrouaCard") {
    VStack(spacing: UI.Spacing.lg) {
        OnykrouaCard(isInteractive: true) {
            HStack {
                Text("Interactive Card")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
        }

        OnykrouaCard(isInteractive: false) {
            Text("Static Card")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("PrimaryCTAButton") {
    VStack(spacing: UI.Spacing.lg) {
        PrimaryCTAButton(title: "Commencer", icon: "play.fill") {}

        PrimaryCTAButton(title: "Désactivé", isDisabled: true) {}

        PrimaryCTAButton(title: "Sans icône") {}
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("EmptyState") {
    EmptyState(
        title: "Aucun résultat",
        message: "Essaie un autre filtre ou une autre recherche",
        icon: "magnifyingglass",
        actionTitle: "Réinitialiser",
        action: {}
    )
    .background(Color(.systemGroupedBackground))
}

#Preview("PracticeModeCard") {
    VStack(spacing: UI.Spacing.lg) {
        PracticeModeCard(
            title: "Dictée de sons",
            subtitle: "Écoute et identifie le son correct",
            icon: "ear",
            color: .pink,
            badge: "3 min"
        ) {}

        PracticeModeCard(
            title: "Quiz Rapide",
            subtitle: "10 questions sur les règles de base",
            icon: "bolt.fill",
            color: .orange
        ) {}
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
