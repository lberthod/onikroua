# ✅ TÂCHES D'OPTIMISATION - Onykroua iOS

**Date:** 14 Janvier 2026  
**Basé sur:** AUDIT-TECHNIQUE-2026.md  
**Priorité:** P0 → P1 → P2

---

## 🔥 SPRINT 1 - STABILITÉ & PERFORMANCE (8h)

### ✅ Tâche 1.1: Migration AppEnvironment (4h) [P0]

**Objectif:** Éliminer les 40 instances de @StateObject et utiliser l'injection de dépendances

#### Actions concrètes:

1. **Migrer FeedView.swift** (30min)
   ```swift
   // AVANT:
   @StateObject private var feedService = FeedService()
   @StateObject private var speechService = SpeechService()
   
   // APRÈS:
   @Environment(\.appEnvironment) var env
   // Usage: env.feedService, env.speechService
   ```
   - [ ] Remplacer `@StateObject private var feedService`
   - [ ] Remplacer `@StateObject private var speechService`
   - [ ] Passer `env.speechService` aux sous-vues
   - [ ] Tester: scroll feed, TTS, like/bookmark

2. **Migrer VocabularyView.swift** (30min)
   - [ ] Remplacer `@StateObject private var speechService`
   - [ ] Remplacer `@StateObject private var dataManager`
   - [ ] Mettre à jour les 3 tabs (Dictionary, Categories, Practice)
   - [ ] Tester: tabs, search, TTS

3. **Migrer ConjugationView.swift** (30min)
   - [ ] Même pattern que VocabularyView
   - [ ] Migrer les 5 tabs (Rules, Verbs, Tenses, Practice, More)
   - [ ] Tester: conjugaison display, TTS

4. **Migrer les 16 fichiers de tabs** (2h)
   - [ ] `Views/VocabularyTabs/DictionaryTab.swift`
   - [ ] `Views/VocabularyTabs/CategoriesTab.swift`
   - [ ] `Views/VocabularyTabs/VocabularyPracticeTab.swift`
   - [ ] `Views/ConjugationTabs/RulesTab.swift`
   - [ ] `Views/ConjugationTabs/VerbsTab.swift`
   - [ ] `Views/ConjugationTabs/TensesTab.swift`
   - [ ] `Views/ConjugationTabs/PracticeTab.swift`
   - [ ] `Views/ConjugationTabs/MoreTab.swift`
   - [ ] `Views/GrammarTabs/RulesGrammarTab.swift`
   - [ ] `Views/GrammarTabs/CategoriesGrammarTab.swift`
   - [ ] `Views/GrammarTabs/QuickReferenceGrammarTab.swift`
   - [ ] `Views/EmojiView.swift`
   - [ ] `Views/ConversationView.swift`
   - [ ] `Views/PhoneticView.swift`
   - [ ] `Views/GrammarView.swift`
   - [ ] `Views/ProfileView.swift`

5. **Validation finale** (30min)
   - [ ] `grep -r "@StateObject" onykroua/` → 0 résultats dans Views
   - [ ] `grep -r "\.shared" onykroua/Views/` → 0 résultats
   - [ ] Build sans warnings
   - [ ] Test manuel de toutes les vues
   - [ ] Vérifier memory usage (Instruments)

**Livrables:**
- ✅ 0 @StateObject dans les vues (sauf racine)
- ✅ Toutes les vues utilisent @Environment
- ✅ Memory usage -20%

---

### ✅ Tâche 1.2: Lazy Loading JSON (2h) [P0]

**Objectif:** Diviser par 4 le temps de démarrage (3-5s → <1s)

#### Actions concrètes:

1. **Modifier VocabularyDataManager.swift** (1h)
   ```swift
   // AVANT:
   private init() {
       loadVocabulary(language: "it")  // BLOQUANT
       loadVocabulary(language: "es")  // BLOQUANT
   }
   
   // APRÈS:
   private init() {
       // Ne charge rien au démarrage
   }
   
   public func ensureLoaded(language: String) {
       guard !isLoaded[language] else { return }
       loadVocabularyAsync(language: language)
   }
   ```
   
   - [ ] Ajouter variable `private var isLoaded: [String: Bool] = [:]`
   - [ ] Créer `ensureLoaded(language:)` méthode
   - [ ] Modifier `loadVocabulary` → `loadVocabularyAsync` avec Task
   - [ ] Ajouter `@Published var isLoading: Bool = false`
   - [ ] Ajouter `@Published var loadingError: Error?`

2. **Mettre à jour les vues consommatrices** (30min)
   - [ ] VocabularyView: appeler `ensureLoaded` dans `.onAppear`
   - [ ] FeedView: appeler `ensureLoaded` dans `.onAppear`
   - [ ] ConjugationView: appeler `ensureLoaded` dans `.onAppear`
   - [ ] Ajouter ProgressView pendant chargement

3. **Ajouter un LoadingScreen** (30min)
   - [ ] Créer `Views/Components/LoadingScreen.swift`
   - [ ] Animation Lottie ou ProgressView avec message
   - [ ] Afficher pendant premier chargement
   - [ ] Transition smooth vers contenu

**Livrables:**
- ✅ Cold start < 1 seconde
- ✅ Chargement en background
- ✅ UI responsive immédiatement
- ✅ Loading states visuels

---

### ✅ Tâche 1.3: Gestion d'erreurs centralisée (2h) [P0]

**Objectif:** Robustesse et UX professionnelle

#### Actions concrètes:

1. **Créer ErrorManager.swift** (45min)
   ```swift
   class ErrorManager: ObservableObject {
       @Published var currentError: AppError?
       @Published var showError = false
       
       func handle(_ error: Error, retryAction: (() -> Void)? = nil)
       func clear()
   }
   
   enum AppError: LocalizedError {
       case jsonLoadFailed(String)
       case networkError
       case dataCorrupted
       // ...
   }
   ```
   
   - [ ] Créer `Services/ErrorManager.swift`
   - [ ] Définir `AppError` enum avec tous les cas
   - [ ] Implémenter `handle()` et `clear()`
   - [ ] Ajouter à `AppEnvironment`

2. **Créer ErrorView.swift** (45min)
   - [ ] Créer `Views/Components/ErrorView.swift`
   - [ ] Design: icon + message + retry button
   - [ ] Support dark mode
   - [ ] Animation d'apparition

3. **Intégrer dans les vues** (30min)
   - [ ] Wrapper try-catch dans VocabularyDataManager
   - [ ] Wrapper try-catch dans GrammarDataManager
   - [ ] Afficher ErrorView dans VocabularyView
   - [ ] Afficher ErrorView dans ConjugationView
   - [ ] Afficher ErrorView dans FeedView

**Livrables:**
- ✅ 0 crashes sur erreurs JSON
- ✅ Messages d'erreur user-friendly
- ✅ Retry automatique possible
- ✅ Logging des erreurs

---

## 🧪 SPRINT 2 - QUALITÉ (10h)

### ✅ Tâche 2.1: Tests unitaires critiques (6h) [P0]

**Objectif:** 70% code coverage minimum

#### Actions concrètes:

1. **Setup test infrastructure** (30min)
   - [ ] Créer folder `onykrouaTests/`
   - [ ] Ajouter test target dans Xcode
   - [ ] Setup Quick/Nimble (optionnel)
   - [ ] Créer `MockAppEnvironment.swift`

2. **VocabularyDataManagerTests.swift** (2h)
   ```swift
   final class VocabularyDataManagerTests: XCTestCase {
       func testLoadVocabulary_Italian_Success()
       func testLoadVocabulary_Spanish_Success()
       func testGetAllWords_ReturnsUniqueWords()
       func testCache_HitOnSecondCall()
       func testInvalidateCache_ClearsCache()
       // ... 15+ tests
   }
   ```
   
   - [ ] Test: chargement JSON italien
   - [ ] Test: chargement JSON espagnol
   - [ ] Test: getAllWords retourne unique
   - [ ] Test: cache fonctionne
   - [ ] Test: invalidation cache
   - [ ] Test: getWordsByCategory
   - [ ] Test: getMainCategories
   - [ ] Test: alphabetical sorting
   - [ ] Test: erreur si JSON manquant
   - [ ] Test: performance (<100ms)

3. **GrammarDataManagerTests.swift** (1h)
   - [ ] Test: getRules par langue
   - [ ] Test: groupRules par catégorie
   - [ ] Test: cache groupRules
   - [ ] Test: search functionality
   - [ ] Test: filter par difficulté
   - [ ] 10+ tests minimum

4. **ProgressTrackerTests.swift** (1h)
   - [ ] Test: markWordLearned ajoute mot
   - [ ] Test: XP calculation correct
   - [ ] Test: level up logic
   - [ ] Test: persistence UserDefaults
   - [ ] Test: dailyStreak increment
   - [ ] Test: reset progress
   - [ ] 8+ tests minimum

5. **SpeechServiceTests.swift** (30min)
   - [ ] Test: speak ne crash pas
   - [ ] Test: stop arrête speech
   - [ ] Test: isSpeaking state
   - [ ] Test: multiple languages
   - [ ] 5+ tests minimum

6. **FeedServiceTests.swift** (1h)
   - [ ] Test: loadNextPage augmente items
   - [ ] Test: pagination fonctionne
   - [ ] Test: like/bookmark persistence
   - [ ] Test: reset feed
   - [ ] Test: mix de types de contenu
   - [ ] 10+ tests minimum

**Livrables:**
- ✅ 50+ tests unitaires
- ✅ 70%+ code coverage
- ✅ Tests passent en CI
- ✅ < 5 secondes execution totale

---

### ✅ Tâche 2.2: Crash Reporting (1h) [P1]

**Objectif:** Monitoring production

#### Actions concrètes:

1. **Firebase Crashlytics setup** (30min)
   - [ ] `pod init` si pas de Podfile
   - [ ] Ajouter `pod 'Firebase/Crashlytics'`
   - [ ] `pod install`
   - [ ] Configuration GoogleService-Info.plist
   - [ ] Init dans onykrouaApp.swift

2. **Configuration Xcode** (15min)
   - [ ] Ajouter run script pour dSYM upload
   - [ ] Build settings: Debug symbols
   - [ ] Test crash avec `fatalError()` en debug

3. **Custom logging** (15min)
   - [ ] Wrapper Crashlytics.crashlytics().log()
   - [ ] Logger dans ErrorManager
   - [ ] Custom keys (userId, language, etc.)

**Livrables:**
- ✅ Crashlytics opérationnel
- ✅ Test crash envoyé
- ✅ Dashboard configuré
- ✅ Alertes email setup

---

### ✅ Tâche 2.3: CI/CD Pipeline (3h) [P1]

**Objectif:** Automation complète

#### Actions concrètes:

1. **GitHub Actions workflow** (2h)
   - [ ] Créer `.github/workflows/ios.yml`
   - [ ] Job: Run tests (Xcode test)
   - [ ] Job: SwiftLint
   - [ ] Job: Build archive
   - [ ] Job: Upload to TestFlight (on tag)
   - [ ] Secrets: App Store Connect API key

2. **Fastlane configuration** (30min)
   - [ ] Vérifier `fastlane/Fastfile` existe
   - [ ] Lane: `test` (run_tests)
   - [ ] Lane: `beta` (build + upload TestFlight)
   - [ ] Lane: `release` (build + upload App Store)
   - [ ] Match pour code signing

3. **Documentation** (30min)
   - [ ] README: CI/CD badges
   - [ ] CONTRIBUTING.md avec workflow
   - [ ] PR template avec checklist

**Livrables:**
- ✅ Tests auto sur chaque PR
- ✅ TestFlight auto sur tag
- ✅ Code signing automatique
- ✅ Documentation à jour

---

## 💾 SPRINT 3 - DONNÉES (7h)

### ✅ Tâche 3.1: Cache persistant SwiftData (4h) [P1]

**Objectif:** Instant launch + offline complete

#### Actions concrètes:

1. **Créer modèles SwiftData** (1h)
   ```swift
   @Model
   final class VocabularyWord {
       var word: String
       var translation: String
       var language: String
       var category: String?
       // ... autres champs
   }
   
   @Model
   final class UserProgress {
       var learnedWords: [String]
       var totalXP: Int
       var dailyStreak: Int
   }
   ```
   
   - [ ] Créer `Models/SwiftData/VocabularyWord+Model.swift`
   - [ ] Créer `Models/SwiftData/UserProgress+Model.swift`
   - [ ] Créer `Models/SwiftData/GrammarRule+Model.swift`
   - [ ] Configuration ModelContainer

2. **Migration JSON → SwiftData** (2h)
   - [ ] Script de migration one-time
   - [ ] Vérifier si déjà migré (UserDefaults flag)
   - [ ] Charger JSON → Insert SwiftData
   - [ ] Progress indicator pendant migration
   - [ ] Validation: count == JSON count

3. **Adapter DataManagers** (1h)
   - [ ] VocabularyDataManager: fetch depuis SwiftData
   - [ ] Fallback JSON si SwiftData vide
   - [ ] Cache en mémoire + SwiftData
   - [ ] Queries optimisées avec predicates

**Livrables:**
- ✅ Instant app launch (<0.5s)
- ✅ 15,000 mots en SwiftData
- ✅ 0 loading JSON après migration
- ✅ Memory usage -40%

---

### ✅ Tâche 3.2: Mode offline complet (3h) [P1]

**Objectif:** 100% fonctionnel sans connexion

#### Actions concrètes:

1. **Network monitor** (30min)
   ```swift
   class NetworkMonitor: ObservableObject {
       @Published var isConnected = true
       private let monitor = NWPathMonitor()
   }
   ```
   
   - [ ] Créer `Services/NetworkMonitor.swift`
   - [ ] Ajouter à AppEnvironment
   - [ ] Publisher pour status changes

2. **Offline queue** (1h)
   - [ ] Queue pour actions (like, bookmark, progress)
   - [ ] Persistence avec SwiftData
   - [ ] Sync quand online
   - [ ] Retry logic

3. **UI offline states** (1h30)
   - [ ] Banner "Mode hors ligne" en haut
   - [ ] Désactiver features online-only
   - [ ] Messages clairs pour user
   - [ ] Sync indicator quand reconnecté

**Livrables:**
- ✅ App fonctionne 100% offline
- ✅ Actions queueées et synced
- ✅ UI claire online/offline
- ✅ Aucune perte de données

---

## 🎨 SPRINT 4 - UX POLISH (9h)

### ✅ Tâche 4.1: Onboarding flow (4h) [P1]

**Objectif:** Accueil professionnel des nouveaux users

#### Actions concrètes:

1. **Créer OnboardingView.swift** (2h)
   ```swift
   struct OnboardingView: View {
       @State private var currentPage = 0
       let pages = [
           OnboardingPage(icon: "🇮🇹", title: "Apprenez l'italien", ...),
           OnboardingPage(icon: "🎯", title: "Pratique interactive", ...),
           OnboardingPage(icon: "📊", title: "Suivez vos progrès", ...),
           OnboardingPage(icon: "🔊", title: "Prononciation native", ...),
       ]
   }
   ```
   
   - [ ] Design 4-5 écrans
   - [ ] Animations page transitions
   - [ ] Skip button
   - [ ] Get started CTA
   - [ ] Illustrations/SF Symbols

2. **Language selection** (1h)
   - [ ] Picker élégant IT/ES
   - [ ] Preview des drapeaux
   - [ ] Sauvegarder choix
   - [ ] Possibilité de changer après

3. **Permissions** (30min)
   - [ ] Explication TTS usage
   - [ ] Explication notifications (futur)
   - [ ] Boutons Allow/Skip

4. **Integration** (30min)
   - [ ] UserDefaults: `hasCompletedOnboarding`
   - [ ] Show onboarding si first launch
   - [ ] Transition vers main app

**Livrables:**
- ✅ Onboarding 4-5 screens
- ✅ Beautiful animations
- ✅ Language selection
- ✅ Skip & complete tracking

---

### ✅ Tâche 4.2: Recherche avancée (3h) [P2]

**Objectif:** Search 10x meilleur

#### Actions concrètes:

1. **Fuzzy search** (1h30)
   ```swift
   func fuzzySearch(_ query: String, in words: [VocabWord]) -> [VocabWord] {
       let normalized = query.lowercased().folding(options: .diacriticInsensitive, locale: .current)
       return words.filter { word in
           let wordNormalized = word.word.lowercased().folding(...)
           return wordNormalized.contains(normalized) ||
                  word.translation.lowercased().contains(normalized) ||
                  levenshteinDistance(wordNormalized, normalized) <= 2
       }
   }
   ```
   
   - [ ] Implémenter algorithme fuzzy
   - [ ] Normalisation accents
   - [ ] Levenshtein distance
   - [ ] Score de pertinence

2. **Search suggestions** (1h)
   - [ ] Afficher suggestions pendant typing
   - [ ] Historique des recherches (10 dernières)
   - [ ] Popular searches
   - [ ] Autocomplete

3. **Debouncing optimisé** (30min)
   - [ ] Combine debounce 300ms
   - [ ] Cancel previous requests
   - [ ] Loading indicator pendant search

**Livrables:**
- ✅ Fuzzy search fonctionnel
- ✅ Suggestions intelligentes
- ✅ 95%+ accuracy
- ✅ < 50ms latence

---

### ✅ Tâche 4.3: Empty states (2h) [P2]

**Objectif:** UI polie partout

#### Actions concrètes:

1. **Créer EmptyStateView variations** (1h)
   - [ ] NoFavoritesView
   - [ ] NoSearchResultsView
   - [ ] NoInternetView
   - [ ] NoDataView
   - [ ] Illustrations custom ou SF Symbols

2. **Integration dans vues** (1h)
   - [ ] VocabularyView: no favorites
   - [ ] Search results: no results
   - [ ] FeedView: no internet
   - [ ] ProfileView: no progress yet
   - [ ] Call-to-action buttons

**Livrables:**
- ✅ 6+ empty states
- ✅ Cohérent design
- ✅ CTAs clairs
- ✅ User guidance

---

## 🚀 SPRINT 5 - ADVANCED (10h)

### ✅ Tâche 5.1: ViewModels MVVM (6h) [P2]

**Objectif:** Clean architecture complète

#### Actions concrètes:

1. **VocabularyViewModel.swift** (2h)
   ```swift
   @Observable
   class VocabularyViewModel {
       private let dataManager: VocabularyDataManager
       var words: [VocabWord] = []
       var filteredWords: [VocabWord] = []
       var searchQuery = ""
       var selectedCategory: String?
       var isLoading = false
       
       func loadWords(language: String) async
       func search(_ query: String)
       func filterByCategory(_ category: String?)
   }
   ```
   
   - [ ] Créer ViewModels/VocabularyViewModel.swift
   - [ ] Extraire toute business logic de VocabularyView
   - [ ] Async/await pour loading
   - [ ] Tests unitaires ViewModel

2. **ConjugationViewModel.swift** (2h)
   - [ ] Même pattern
   - [ ] Gestion verbes, temps, conjugaisons
   - [ ] Quiz logic
   - [ ] Tests

3. **FeedViewModel.swift** (1h)
   - [ ] Pagination logic
   - [ ] Like/bookmark logic
   - [ ] Mix algorithm
   - [ ] Tests

4. **Refactor Views** (1h)
   - [ ] VocabularyView: utiliser ViewModel
   - [ ] ConjugationView: utiliser ViewModel
   - [ ] FeedView: utiliser ViewModel
   - [ ] Pure UI, zero business logic

**Livrables:**
- ✅ 3+ ViewModels
- ✅ Views = pure UI
- ✅ 90%+ testability
- ✅ Separation of concerns parfaite

---

### ✅ Tâche 5.2: Analytics (2h) [P2]

**Objectif:** Data-driven decisions

#### Actions concrètes:

1. **Firebase Analytics setup** (30min)
   - [ ] `pod 'Firebase/Analytics'`
   - [ ] Configuration
   - [ ] Test events

2. **Events tracking** (1h)
   ```swift
   // Analytics events:
   - screen_view (quelle vue)
   - word_learned (quel mot)
   - tts_used (combien de fois)
   - feature_used (quelle feature)
   - time_spent (par session)
   ```
   
   - [ ] Tracker screen views
   - [ ] Tracker word learned
   - [ ] Tracker TTS usage
   - [ ] Tracker feature adoption
   - [ ] Tracker time spent

3. **Dashboard setup** (30min)
   - [ ] Custom events dans Firebase
   - [ ] Funnels: onboarding → first word
   - [ ] Retention cohorts
   - [ ] User properties (language, level)

**Livrables:**
- ✅ 10+ events trackés
- ✅ Dashboard configuré
- ✅ Insights actionnables
- ✅ Privacy compliant

---

### ✅ Tâche 5.3: Micro-interactions (2h) [P2]

**Objectif:** Premium feel

#### Actions concrètes:

1. **Haptic feedback** (45min)
   ```swift
   let impact = UIImpactFeedbackGenerator(style: .medium)
   impact.impactOccurred() // Sur actions
   ```
   
   - [ ] Haptic sur like/bookmark
   - [ ] Haptic sur word learned
   - [ ] Haptic sur level up
   - [ ] Haptic sur navigation
   - [ ] Different styles selon action

2. **Success animations** (45min)
   - [ ] Confetti sur level up
   - [ ] Checkmark animation sur word learned
   - [ ] Heart bounce sur like
   - [ ] Star animation sur achievement

3. **Skeleton loaders** (30min)
   - [ ] Skeleton pour lists
   - [ ] Shimmer effect
   - [ ] Replace ProgressView
   - [ ] Smooth transitions

**Livrables:**
- ✅ Haptic sur 8+ actions
- ✅ 4+ custom animations
- ✅ Skeleton loaders
- ✅ Premium feeling

---

## 📊 VALIDATION FINALE

### Checklist avant production

#### Performance
- [ ] Cold start < 1 seconde (mesure: Instruments)
- [ ] Memory < 100MB (mesure: Instruments)
- [ ] 60 FPS constant (mesure: Xcode debug)
- [ ] Crash rate < 0.5% (mesure: Crashlytics)
- [ ] Bundle size optimisé (< 50MB)

#### Quality
- [ ] Test coverage > 70% (mesure: Xcode coverage)
- [ ] 0 warnings Xcode
- [ ] SwiftLint passed
- [ ] Accessibility audit passed (Voice Over)
- [ ] Dark mode tested

#### UX
- [ ] Onboarding complété
- [ ] Empty states partout
- [ ] Error handling partout
- [ ] Loading states partout
- [ ] Haptic feedback cohérent

#### Documentation
- [ ] README à jour
- [ ] CHANGELOG.md créé
- [ ] API documentation (inline)
- [ ] Architecture decision records

#### Compliance
- [ ] Privacy manifest
- [ ] App Store screenshots
- [ ] App Store description
- [ ] Terms & Privacy policy

---

## 📈 TRACKING PROGRESS

### KPIs à suivre

#### Semaine 1-2 (Sprint 1-2)
- ✅ Cold start: 3.5s → 0.8s
- ✅ Test coverage: 0% → 70%
- ✅ Crashes: monitored
- ✅ CI/CD: automated

#### Semaine 3 (Sprint 3)
- ✅ Memory: 150MB → 90MB
- ✅ Offline: 100% functional
- ✅ Data: SwiftData migrated

#### Semaine 4-5 (Sprint 4-5)
- ✅ User retention: +30%
- ✅ Feature adoption: +50%
- ✅ App Store rating: 4.5+★
- ✅ Code quality: A+

---

## 🎯 QUICK REFERENCE

### Commandes utiles

```bash
# Tests
xcodebuild test -scheme onykroua -destination 'platform=iOS Simulator,name=iPhone 15'

# Coverage
xcodebuild test -scheme onykroua -enableCodeCoverage YES

# SwiftLint
swiftlint lint --strict

# Fastlane
fastlane test
fastlane beta
fastlane release

# Instruments (Memory)
instruments -t "Allocations" -D trace.trace ./build/onykroua.app

# File count
find . -name "*.swift" | wc -l

# Line count
find . -name "*.swift" -exec wc -l {} + | tail -1
```

### Ressources

- **Architecture:** MVVM + Clean Architecture
- **Tests:** XCTest, Quick/Nimble
- **CI/CD:** GitHub Actions, Fastlane
- **Analytics:** Firebase Analytics
- **Crash reporting:** Firebase Crashlytics
- **Persistence:** SwiftData (iOS 17+)

---

**Total estimation:** 44 heures sur 5 sprints  
**Impact:** Performance +200%, Quality +300%, UX +100%  
**ROI:** Application production-ready niveau App Store Top 10

---

**Créé avec ✅ le 14 Janvier 2026**
