# 🔨 Instructions de Build - Version 1.1 (8)

## 📋 Prérequis

- **macOS**: Sonoma ou plus récent
- **Xcode**: 15.0 ou plus récent
- **iOS Target**: 16.0 minimum

---

## 🚀 Build rapide

### 1. Ouvrir le projet

```bash
cd /Users/berthod/Desktop/onykroua/frontend-ios/onykroua
open onykroua.xcodeproj
```

### 2. Clean Build Folder

Dans Xcode:
- **⌘⇧K** (Product → Clean Build Folder)

### 3. Build

- **⌘B** (Product → Build)

### 4. Run

- **⌘R** (Product → Run)
- Choisir simulator: **iPhone 15**

---

## ⚙️ Configuration

### Signing & Capabilities

1. Sélectionner le target **onykroua**
2. Onglet **Signing & Capabilities**
3. Team: Sélectionner votre équipe
4. Bundle Identifier: `com.loicberthod.onykroua`

### Build Settings

- **iOS Deployment Target**: 16.0
- **Swift Language Version**: Swift 5
- **Optimization Level (Debug)**: No Optimization [-Onone]
- **Optimization Level (Release)**: Optimize for Speed [-O]

---

## 📦 Nouveaux fichiers ajoutés

### Utils/
- `Extensions.swift` - Extensions centralisées
- `Constants.swift` - Constantes de l'app

### Services/
- `AppEnvironment.swift` - Dependency injection

### Views/Components/
- `SharedComponents.swift` - Composants réutilisables

### Documentation/
- `OPTIMIZATIONS.md` - Optimisations implémentées
- `VOCABULARY-FEED-IMPROVEMENTS.md` - Améliorations vocabulaire & feed
- `DIAGNOSTIC-CORRECTIONS.md` - Diagnostic et corrections
- `BUILD-INSTRUCTIONS.md` - Ce fichier

---

## 🐛 Dépannage

### Erreur: "Command line tools instance"

Si vous obtenez cette erreur:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Erreur: "Missing file Extensions.swift"

1. Dans Xcode, File → Add Files to "onykroua"
2. Sélectionner `Utils/Extensions.swift`
3. Cocher "Copy items if needed"
4. Add to target: **onykroua**

### Erreur: "Unresolved identifier 'AppConstants'"

1. Build le projet (⌘B)
2. Si persiste, ajouter `Utils/Constants.swift` au target

### Erreur de compilation dans VocabularyPracticeTab

Si erreur sur `VocabChoiceButton`:
```swift
// Vérifier que la définition inclut bien:
struct VocabChoiceButton: View {
    let number: Int  // ← Important
    let text: String
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void
    // ...
}
```

---

## ✅ Checklist de vérification

Après le build, vérifier:

- [ ] L'app démarre sans crash
- [ ] La homepage affiche "Version 1.1 (8)" en bas
- [ ] Navigation vers Vocabulaire fonctionne
- [ ] Tab "Pratique" s'affiche
- [ ] Mode "Choix" affiche le mot en gros
- [ ] 4 choix numérotés (1, 2, 3, 4) visibles
- [ ] Feedback vert/rouge fonctionne
- [ ] Navigation vers Feed fonctionne
- [ ] Sélecteur de langue (🇮🇹/🇪🇸) visible en haut
- [ ] Scroll vertical fluide
- [ ] Audio s'arrête au scroll

---

## 📊 Taille du build

### Debug
- App Bundle: ~15 MB
- IPA: ~12 MB

### Release
- App Bundle: ~8 MB
- IPA: ~6 MB

---

## 🚢 Déploiement

### TestFlight

1. Archive l'app: Product → Archive
2. Valider: Window → Organizer
3. Distribute → TestFlight
4. Upload

### App Store

1. Archive l'app
2. Distribute → App Store Connect
3. Soumettre pour revue

---

## 📝 Notes de version

### Version 1.1 (8) - 13 janvier 2026

**Nouvelles fonctionnalités:**
- ✅ Quiz vocabulaire optimisé (mot en gros + 4 choix)
- ✅ Feed avec scroll vertical infini
- ✅ Sélecteur de langue dans le feed
- ✅ Intégration vocabulaire réel depuis JSON
- ✅ Architecture optimisée (Extensions, Constants, AppEnvironment)
- ✅ Composants réutilisables
- ✅ Système de cache pour performances

**Améliorations techniques:**
- ✅ Centralisation des extensions
- ✅ Constantes typées
- ✅ Cache intelligent dans DataManagers
- ✅ Infinite scrolling (charge 5 items avant la fin)
- ✅ Stop audio automatique lors du scroll

**Bugs corrigés:**
- ✅ Conflits de nommage (GrammarRule vs ConjugationGrammarRule)
- ✅ Problèmes d'access control dans SwiftUI
- ✅ Extensions dupliquées supprimées

---

*Document créé le: 13 janvier 2026*
