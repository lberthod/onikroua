import SwiftUI

// MARK: - Design Tokens

enum UI {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    enum Radius {
        static let r12: CGFloat = 12
        static let r16: CGFloat = 16
        static let r20: CGFloat = 20
    }
    
    enum Size {
        static let chipHeight: CGFloat = 34
        static let searchHeight: CGFloat = 44
        static let headerTopPadding: CGFloat = 8
        static let buttonHeight: CGFloat = 52
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
