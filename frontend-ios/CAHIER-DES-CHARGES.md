# 📋 CAHIER DES CHARGES - Améliorations onykroua iOS
## Spécifications Techniques pour l'Implémentation

**Date:** Janvier 2026  
**Version cible:** 2.0  
**Priorité:** Critique & Élevée  
**Délai estimé:** 4-6 semaines

---

## 🎯 OBJECTIFS GÉNÉRAUX

Transformer l'application onykroua d'une **collection de ressources d'apprentissage** en un **système d'apprentissage guidé et efficace** qui:

1. **Guide l'utilisateur** à travers un parcours structuré
2. **Adapte le contenu** au niveau réel de l'utilisateur
3. **Maximise la rétention** grâce à la répétition espacée visible
4. **Simplifie l'expérience** en réduisant la surcharge cognitive
5. **Augmente l'engagement** avec des mécanismes de motivation clairs

---

## 📦 LIVRABLES

### Phase 1: Réorganisation Structurelle (Priorité CRITIQUE)
- ✅ Nouveau système de Dashboard "Aujourd'hui"
- ✅ Parcours d'apprentissage guidé (Learning Path)
- ✅ Interface de révision quotidienne
- ✅ Système de recommandation intelligent

### Phase 2: Améliorations UX/UI (Priorité ÉLEVÉE)
- ✅ Refonte de l'écran principal
- ✅ Filtrage de contenu par niveau CECRL
- ✅ Amélioration du feedback utilisateur
- ✅ Standardisation des patterns

### Phase 3: Optimisations (Priorité MOYENNE)
- ⚪ Skeleton screens
- ⚪ Améliorations ergonomiques
- ⚪ Fonctionnalités sociales

---

## 🏗️ ARCHITECTURE TECHNIQUE

### Nouveaux Composants à Créer

```
onykroua/
├── Models/
│   ├── LearningPath.swift           ✨ NOUVEAU
│   ├── DailySession.swift           ✨ NOUVEAU
│   ├── Recommendation.swift         ✨ NOUVEAU
│   └── ContentFilter.swift          ✨ NOUVEAU
├── Services/
│   ├── LearningPathManager.swift    ✨ NOUVEAU
│   ├── DailySessionService.swift    ✨ NOUVEAU
│   ├── RecommendationEngine.swift   ✨ NOUVEAU
│   └── ContentFilterService.swift   ✨ NOUVEAU
├── Views/
│   ├── Dashboard/
│   │   ├── TodayDashboardView.swift ✨ NOUVEAU
│   │   ├── DailyMissionCard.swift   ✨ NOUVEAU
│   │   └── ReviewSessionView.swift  ✨ NOUVEAU
│   ├── LearningPath/
│   │   ├── LearningPathView.swift   ✨ NOUVEAU
│   │   ├── ChapterView.swift        ✨ NOUVEAU
│   │   └── LessonView.swift         ✨ NOUVEAU
│   └── ContentView_Refactored.swift ✨ REFONTE
└── Utils/
    └── Constants+LearningPath.swift  ✨ NOUVEAU
```

---

## 📐 SPÉCIFICATIONS DÉTAILLÉES

## 1. DASHBOARD "AUJOURD'HUI" (PRIORITÉ CRITIQUE 🔴)

### 1.1 Objectif
Créer un point d'entrée unique et clair qui guide l'utilisateur vers l'action la plus pertinente du jour.

### 1.2 Spécifications Fonctionnelles

#### Écran Principal Simplifié
```swift
// Structure de TodayDashboardView.swift

struct TodayDashboardView: View {
    // 1. Section Hero - Action Principale du Jour
    //    - Mission quotidienne OU Révision urgente OU Nouvelle leçon
    //    - CTA visible et engageant
    //    - Estimation de temps (ex: "10 min")
    
    // 2. Section Progression
    //    - Barre de progression du jour (objectif quotidien)
    //    - Streak actuel avec animation
    //    - Mini stats (mots appris aujourd'hui, XP gagné)
    
    // 3. Section Raccourcis (max 3)
    //    - Continuer où j'en étais
    //    - Révisions à faire (avec badge si > 0)
    //    - Explorer (accès aux catégories)
    
    // 4. Section Motivation
    //    - Citation/conseil du jour
    //    - Prochain badge à débloquer (avec progression)
}
```

#### Comportements
- **Au lancement**: Analyser l'état de progression et proposer l'action optimale
- **Mission complétée**: Célébration + proposition de la prochaine action
- **Pas de mission**: Proposer de créer un objectif ou explorer librement

### 1.3 Spécifications Techniques

#### Modèle DailySession
```swift
@Model
final class DailySession {
    var date: Date
    var missionType: MissionType
    var missionCompleted: Bool
    var reviewsDue: Int
    var reviewsCompleted: Int
    var lessonsCompleted: Int
    var xpEarned: Int
    var timeSpent: Int // secondes
    var streakMaintained: Bool
    
    enum MissionType: String, Codable {
        case review       // Réviser X items
        case newLesson    // Compléter une nouvelle leçon
        case practice     // Pratiquer une compétence spécifique
        case assessment   // Évaluation de niveau
        case custom       // Mission personnalisée
    }
    
    func generateDailyMission(userProgress: UserProgress) -> Mission {
        // Logique de génération intelligente
    }
}

struct Mission: Identifiable {
    let id: UUID
    let type: MissionType
    let title: String
    let description: String
    let estimatedTime: Int // minutes
    let xpReward: Int
    let targetCount: Int
    let currentCount: Int
    let content: [ReviewItem] // ou [Lesson] selon le type
}
```

#### Service DailySessionService
```swift
@Observable
final class DailySessionService {
    var currentSession: DailySession?
    var todayMission: Mission?
    
    func startNewDay(userProgress: UserProgress) async {
        // Créer une nouvelle session pour aujourd'hui
        // Générer la mission du jour basée sur:
        // - Items dus pour révision
        // - Progression dans le learning path
        // - Niveau CECRL actuel
        // - Historique des derniers jours
    }
    
    func getTodayPriority() -> ActionPriority {
        // Déterminer l'action prioritaire
    }
    
    func completeMission() async {
        // Marquer la mission comme complétée
        // Mettre à jour les stats
        // Déclencher animations/célébrations
    }
}

enum ActionPriority {
    case urgentReview(count: Int)  // Révisions en retard
    case dailyReview(count: Int)   // Révisions du jour
    case newContent                // Nouveau contenu recommandé
    case practice                  // Pratique d'une faiblesse identifiée
    case freeExploration          // Pas de priorité spécifique
}
```

### 1.4 Design UI/UX

#### Wireframe Textuel
```
┌─────────────────────────────────────┐
│ ☀️ Aujourd'hui                      │
│                                     │
│ ┌─────────────────────────────┐   │
│ │ 🎯 MISSION DU JOUR          │   │
│ │                              │   │
│ │ Révise 20 mots              │   │
│ │ ⏱️ 10 min  •  +50 XP        │   │
│ │                              │   │
│ │ [▓▓▓▓▓░░░░░] 5/20           │   │
│ │                              │   │
│ │     [ 🚀 COMMENCER ]        │   │
│ └─────────────────────────────┘   │
│                                     │
│ 📊 Progression du jour              │
│ [▓▓▓▓░░░░░░] 40/100 XP              │
│                                     │
│ 🔥 12 jours • 📚 3 mots • ⭐ 45 XP │
│                                     │
│ ┌───────┐ ┌───────┐ ┌───────┐     │
│ │ 📖    │ │ 🔄 5  │ │ 🌍    │     │
│ │Contin.│ │Réviser│ │Explor.│     │
│ └───────┘ └───────┘ └───────┘     │
│                                     │
│ 💡 "La répétition est la mère      │
│     de l'apprentissage"             │
│                                     │
│ 🏆 Prochain badge: Semaine parfaite│
│ [▓▓▓▓▓▓░] 6/7 jours                │
└─────────────────────────────────────┘
```

---

## 2. PARCOURS D'APPRENTISSAGE GUIDÉ (PRIORITÉ CRITIQUE 🔴)

### 2.1 Objectif
Structurer le contenu en un curriculum progressif qui guide l'utilisateur du niveau A1 vers C2.

### 2.2 Spécifications Fonctionnelles

#### Structure du Learning Path
```
Niveau A1 - Débutant
├── Chapitre 1: Se présenter (5 leçons)
│   ├── Leçon 1.1: Salutations [COMPLÉTÉ ✓]
│   ├── Leçon 1.2: Alphabet et prononciation [EN COURS]
│   ├── Leçon 1.3: Nombres 1-20 [VERROUILLÉ 🔒]
│   ├── Leçon 1.4: Phrases essentielles [VERROUILLÉ 🔒]
│   └── Quiz chapitre 1 [VERROUILLÉ 🔒]
├── Chapitre 2: La famille et les amis (6 leçons)
│   └── [VERROUILLÉ 🔒]
└── ...

Niveau A2 - Élémentaire
├── [VERROUILLÉ 🔒 - Complète A1 d'abord]
```

#### Règles de Déblocage
1. **Leçons séquentielles**: Une leçon doit être complétée à 80%+ pour débloquer la suivante
2. **Quiz de validation**: Chaque chapitre se termine par un quiz (70%+ pour valider)
3. **Révisions obligatoires**: Si trop d'items en retard, bloquer nouveau contenu
4. **Niveau adaptatif**: Possibilité de passer un test pour skip certaines leçons

### 2.3 Spécifications Techniques

#### Modèle LearningPath
```swift
@Model
final class LearningPath {
    var userId: String
    var targetLevel: CEFRLevel
    var currentChapter: String
    var currentLesson: String
    var chaptersCompleted: [String]
    var lessonsCompleted: [String]
    var lastAccessedDate: Date
    var estimatedCompletionDate: Date?
}

struct Chapter: Identifiable, Codable {
    let id: String
    let level: CEFRLevel
    let order: Int
    let title: String
    let description: String
    let icon: String
    let estimatedDuration: Int // minutes
    let lessons: [Lesson]
    let quiz: Quiz
    
    var isUnlocked: Bool
    var isCompleted: Bool
    var progress: Double // 0.0 - 1.0
}

struct Lesson: Identifiable, Codable {
    let id: String
    let chapterId: String
    let order: Int
    let title: String
    let description: String
    let type: LessonType
    let estimatedDuration: Int
    let xpReward: Int
    
    let vocabularyWords: [String]? // IDs des mots à apprendre
    let grammarRules: [String]?    // IDs des règles
    let exercises: [Exercise]
    
    var isUnlocked: Bool
    var isCompleted: Bool
    var score: Double? // 0.0 - 1.0
    var completedDate: Date?
    
    enum LessonType: String, Codable {
        case vocabulary
        case grammar
        case conjugation
        case conversation
        case listening
        case mixed
    }
}

struct Exercise: Identifiable, Codable {
    let id: String
    let type: ExerciseType
    let question: String
    let options: [String]?
    let correctAnswer: String
    let explanation: String
    let hint: String?
    
    enum ExerciseType: String, Codable {
        case multipleChoice
        case fillBlank
        case matching
        case translation
        case listening
        case speaking
    }
}
```

#### Service LearningPathManager
```swift
@Observable
final class LearningPathManager {
    var learningPath: LearningPath?
    var chapters: [Chapter] = []
    var currentLesson: Lesson?
    
    func initializeLearningPath(userLevel: CEFRLevel) {
        // Créer le parcours initial basé sur le niveau
        // Charger les chapitres appropriés
    }
    
    func getNextRecommendedLesson() -> Lesson? {
        // Déterminer la prochaine leçon à suivre
    }
    
    func completeLesson(lessonId: String, score: Double) async {
        // Marquer comme complété
        // Débloquer la leçon suivante si score >= 0.8
        // Mettre à jour la progression
    }
    
    func checkChapterCompletion(chapterId: String) -> Bool {
        // Vérifier si toutes les leçons sont complétées
    }
    
    func unlockNextChapter(currentChapterId: String) {
        // Débloquer le chapitre suivant
    }
    
    func getProgressOverview() -> ProgressOverview {
        // Stats globales du parcours
    }
}

struct ProgressOverview {
    let currentLevel: CEFRLevel
    let chaptersCompleted: Int
    let chaptersTotal: Int
    let lessonsCompleted: Int
    let lessonsTotal: Int
    let overallProgress: Double
    let estimatedTimeToNextLevel: Int // heures
}
```

### 2.4 Design UI/UX

#### Vue Parcours d'Apprentissage
```swift
struct LearningPathView: View {
    @EnvironmentObject var pathManager: LearningPathManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header avec progression globale
                ProgressHeaderCard()
                
                // Liste des chapitres
                ForEach(pathManager.chapters) { chapter in
                    ChapterCard(chapter: chapter)
                        .disabled(!chapter.isUnlocked)
                }
            }
        }
        .navigationTitle("Mon Parcours")
    }
}

struct ChapterCard: View {
    let chapter: Chapter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(chapter.icon)
                    .font(.title)
                Text(chapter.title)
                    .font(.headline)
                Spacer()
                if chapter.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            ProgressView(value: chapter.progress)
            
            Text("\(chapter.lessons.count) leçons • \(chapter.estimatedDuration) min")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Preview des premières leçons
            ForEach(chapter.lessons.prefix(3)) { lesson in
                LessonRow(lesson: lesson)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .opacity(chapter.isUnlocked ? 1.0 : 0.5)
    }
}
```

---

## 3. INTERFACE DE RÉVISION QUOTIDIENNE (PRIORITÉ CRITIQUE 🔴)

### 3.1 Objectif
Rendre le système de répétition espacée (déjà implémenté) visible et accessible.

### 3.2 Spécifications Fonctionnelles

#### Fonctionnalités
- **Badge notification** sur le dashboard indiquant le nombre d'items à réviser
- **Session de révision** avec interface dédiée
- **Cartes flashcards** interactives
- **Feedback immédiat** avec explications
- **Difficulté auto-évaluée** (Difficile/Moyen/Facile)
- **Progression en temps réel** de la session

#### Modes de Révision
1. **Mode Rapide**: 10 items, 5 minutes
2. **Mode Standard**: 20 items, 10 minutes
3. **Mode Intensif**: 50 items, 25 minutes
4. **Mode Personnalisé**: X items choisis

### 3.3 Spécifications Techniques

#### Intégration avec AdaptiveReviewSystem
```swift
// Extension de AdaptiveReviewSystem existant

extension AdaptiveReviewSystem {
    func getDueItemsCount() -> Int {
        return reviewQueue.filter { $0.isDueForReview }.count
    }
    
    func getUrgentItemsCount() -> Int {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        return reviewQueue.filter { $0.nextReview < twoDaysAgo }.count
    }
    
    func startReviewSession(mode: ReviewMode) -> ReviewSession {
        let items = getDueItems(limit: mode.itemCount)
        return ReviewSession(items: items, mode: mode)
    }
}

enum ReviewMode {
    case quick      // 10 items
    case standard   // 20 items
    case intensive  // 50 items
    case custom(Int)
    
    var itemCount: Int {
        switch self {
        case .quick: return 10
        case .standard: return 20
        case .intensive: return 50
        case .custom(let count): return count
        }
    }
}

@Observable
final class ReviewSession {
    var items: [AdaptiveReviewSystem.ReviewItem]
    var currentIndex: Int = 0
    var correctCount: Int = 0
    var incorrectCount: Int = 0
    var startTime: Date = Date()
    var mode: ReviewMode
    
    var currentItem: AdaptiveReviewSystem.ReviewItem? {
        guard currentIndex < items.count else { return nil }
        return items[currentIndex]
    }
    
    var progress: Double {
        guard !items.isEmpty else { return 0 }
        return Double(currentIndex) / Double(items.count)
    }
    
    var isCompleted: Bool {
        return currentIndex >= items.count
    }
    
    func submitAnswer(wasCorrect: Bool, difficulty: AdaptiveReviewSystem.ReviewItem.DifficultyLevel) {
        // Enregistrer la réponse
        // Passer à l'item suivant
    }
    
    func getSessionSummary() -> SessionSummary {
        let duration = Date().timeIntervalSince(startTime)
        return SessionSummary(
            itemsReviewed: currentIndex,
            correctAnswers: correctCount,
            incorrectAnswers: incorrectCount,
            duration: Int(duration),
            xpEarned: correctCount * 5
        )
    }
}

struct SessionSummary {
    let itemsReviewed: Int
    let correctAnswers: Int
    let incorrectAnswers: Int
    let duration: Int
    let xpEarned: Int
    
    var successRate: Double {
        guard itemsReviewed > 0 else { return 0 }
        return Double(correctAnswers) / Double(itemsReviewed)
    }
}
```

### 3.4 Design UI/UX

#### Vue Session de Révision
```swift
struct ReviewSessionView: View {
    @StateObject var session: ReviewSession
    @State private var showAnswer = false
    @State private var userAnswer = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressView(value: session.progress)
                .padding()
            
            Text("\(session.currentIndex + 1) / \(session.items.count)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let item = session.currentItem {
                // Flashcard
                FlashcardView(
                    item: item,
                    showAnswer: $showAnswer,
                    onAnswer: handleAnswer
                )
            }
            
            Spacer()
            
            if !showAnswer {
                Button("Révéler la réponse") {
                    withAnimation { showAnswer = true }
                }
                .buttonStyle(.borderedProminent)
            } else {
                DifficultySelector(onSelect: handleDifficulty)
            }
        }
        .navigationTitle("Révision")
        .navigationBarBackButtonHidden(true)
    }
    
    func handleDifficulty(_ difficulty: AdaptiveReviewSystem.ReviewItem.DifficultyLevel) {
        // Logique de soumission
        withAnimation {
            showAnswer = false
            session.submitAnswer(wasCorrect: true, difficulty: difficulty)
        }
    }
}

struct FlashcardView: View {
    let item: AdaptiveReviewSystem.ReviewItem
    @Binding var showAnswer: Bool
    let onAnswer: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Type badge
            HStack {
                typeIcon
                Text(item.type.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            
            // Question
            Text(item.content.question)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .padding()
            
            if let hint = item.content.hint, !showAnswer {
                Text("💡 \(hint)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Answer (revealed)
            if showAnswer {
                Divider()
                
                Text(item.content.answer)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if let example = item.content.example {
                    Text(example)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                        .padding()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(radius: 10)
        .padding()
        .rotation3DEffect(
            .degrees(showAnswer ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(), value: showAnswer)
    }
    
    var typeIcon: some View {
        Group {
            switch item.type {
            case .vocabulary: Image(systemName: "book.fill")
            case .conjugation: Image(systemName: "text.book.closed")
            case .grammar: Image(systemName: "text.alignleft")
            case .conversation: Image(systemName: "message.fill")
            }
        }
        .foregroundColor(.blue)
    }
}

struct DifficultySelector: View {
    let onSelect: (AdaptiveReviewSystem.ReviewItem.DifficultyLevel) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Comment était cette carte ?")
                .font(.headline)
            
            HStack(spacing: 12) {
                DifficultyButton(title: "Difficile", color: .red, difficulty: .hard, action: onSelect)
                DifficultyButton(title: "Moyen", color: .orange, difficulty: .medium, action: onSelect)
                DifficultyButton(title: "Facile", color: .green, difficulty: .easy, action: onSelect)
            }
            .padding()
        }
    }
}
```

---

## 4. SYSTÈME DE RECOMMANDATION INTELLIGENT (PRIORITÉ CRITIQUE 🔴)

### 4.1 Objectif
Filtrer et personnaliser le contenu (Feed, vocabulaire, exercices) selon le niveau CECRL et les performances de l'utilisateur.

### 4.2 Spécifications Fonctionnelles

#### Critères de Filtrage
1. **Niveau CECRL**: Adapter la difficulté du contenu
2. **Historique d'apprentissage**: Éviter le contenu déjà maîtrisé
3. **Points faibles identifiés**: Proposer du contenu de renforcement
4. **Préférences**: Type de contenu préféré (vocabulaire, grammaire, etc.)
5. **Temps disponible**: Adapter la longueur des activités

### 4.3 Spécifications Techniques

#### Service RecommendationEngine
```swift
@Observable
final class RecommendationEngine {
    private let userProgress: UserProgress
    private let learningPath: LearningPath?
    private let reviewSystem: AdaptiveReviewSystem
    
    func getRecommendedContent(
        type: ContentType,
        limit: Int = 20
    ) -> [RecommendedContent] {
        // Algorithme de recommandation
        let userLevel = userProgress.level
        let weakAreas = identifyWeakAreas()
        
        // Score chaque contenu potentiel
        // Prioriser: niveau approprié > renforcement > nouveau
        
        return filteredContent
    }
    
    func identifyWeakAreas() -> [ContentArea] {
        // Analyser les performances
        // Identifier les domaines avec faible taux de réussite
        var weakAreas: [ContentArea] = []
        
        if userProgress.quizSuccessRate < 0.7 {
            weakAreas.append(.general)
        }
        
        // Analyser par type de contenu via reviewSystem
        let vocabSuccess = reviewSystem.getSuccessRate(type: .vocabulary)
        if vocabSuccess < 0.7 {
            weakAreas.append(.vocabulary)
        }
        
        return weakAreas
    }
    
    func getNextBestAction() -> RecommendedAction {
        // Déterminer l'action la plus pertinente maintenant
        
        // Priorité 1: Révisions en retard
        let dueCount = reviewSystem.getDueItemsCount()
        if dueCount > 20 {
            return .urgentReview(count: dueCount)
        }
        
        // Priorité 2: Mission du jour
        if let mission = DailySessionService.shared.todayMission {
            if !mission.isCompleted {
                return .dailyMission(mission)
            }
        }
        
        // Priorité 3: Continuer le parcours
        if let nextLesson = LearningPathManager.shared.getNextRecommendedLesson() {
            return .continueLesson(nextLesson)
        }
        
        // Priorité 4: Renforcer une faiblesse
        let weakAreas = identifyWeakAreas()
        if let weakest = weakAreas.first {
            return .reinforceArea(weakest)
        }
        
        // Par défaut: Explorer
        return .explore
    }
}

enum RecommendedAction {
    case urgentReview(count: Int)
    case dailyMission(Mission)
    case continueLesson(Lesson)
    case reinforceArea(ContentArea)
    case explore
}

enum ContentArea {
    case vocabulary
    case grammar
    case conjugation
    case conversation
    case listening
    case general
}

struct RecommendedContent {
    let id: String
    let type: ContentType
    let title: String
    let difficulty: CEFRLevel
    let reason: String  // "Basé sur ton niveau A2"
    let estimatedTime: Int
    let relevanceScore: Double  // 0-1
}
```

#### Filtrage du Feed
```swift
// Modification de FeedService

extension FeedService {
    func loadFilteredItems(
        userLevel: CEFRLevel,
        limit: Int = 20
    ) -> [FeedItem] {
        // Filtrer selon le niveau
        let filtered = allItems.filter { item in
            // Logique de filtrage par niveau
            item.difficulty.isAppropriateFor(userLevel)
        }
        
        // Trier par pertinence
        return filtered.sorted { item1, item2 in
            item1.relevanceScore(for: userLevel) > item2.relevanceScore(for: userLevel)
        }
    }
}

extension CEFRLevel {
    func isAppropriateFor(_ userLevel: CEFRLevel) -> Bool {
        // Accepter niveau actuel +/- 1
        let levelIndex = CEFRLevel.allCases.firstIndex(of: self) ?? 0
        let userIndex = CEFRLevel.allCases.firstIndex(of: userLevel) ?? 0
        return abs(levelIndex - userIndex) <= 1
    }
}
```

---

## 5. REFONTE DE L'ÉCRAN PRINCIPAL (PRIORITÉ ÉLEVÉE 🟡)

### 5.1 Avant/Après

#### AVANT (Actuel)
- ❌ 6 sections empilées
- ❌ Trop de choix simultanés
- ❌ Pas de hiérarchie claire
- ❌ Surcharge cognitive

#### APRÈS (Nouveau)
- ✅ 3 sections principales max
- ✅ Une action hero mise en avant
- ✅ Hiérarchie visuelle claire
- ✅ Navigation simplifiée

### 5.2 Nouvelle Structure

```swift
struct ContentView_Refactored: View {
    @EnvironmentObject var env: AppEnvironment
    @StateObject var recommendationEngine: RecommendationEngine
    @StateObject var dailySessionService: DailySessionService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 1. Header simple
                    CompactHeaderView()
                    
                    // 2. ACTION HERO - La chose la plus importante à faire
                    HeroActionCard(action: recommendationEngine.getNextBestAction())
                    
                    // 3. Progression compacte
                    CompactProgressCard()
                    
                    // 4. Révisions (si > 0)
                    if reviewSystem.getDueItemsCount() > 0 {
                        ReviewReminderCard()
                    }
                    
                    // 5. Accès rapide (carousel horizontal)
                    QuickAccessCarousel()
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

struct HeroActionCard: View {
    let action: RecommendedAction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                iconForAction
                    .font(.system(size: 48))
                
                Spacer()
                
                estimatedTimeBadge
            }
            
            Text(titleForAction)
                .font(.title2.bold())
            
            Text(descriptionForAction)
                .font(.body)
                .foregroundColor(.secondary)
            
            Button(action: { handleAction() }) {
                HStack {
                    Text("Commencer")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: gradientForAction,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .padding(.horizontal)
    }
}

struct QuickAccessCarousel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accès rapide")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    QuickAccessCard(icon: "🎯", title: "Mon Parcours", destination: LearningPathView())
                    QuickAccessCard(icon: "📚", title: "Vocabulaire", destination: VocabularyView_Enhanced())
                    QuickAccessCard(icon: "📖", title: "Conjugaison", destination: ConjugationView())
                    QuickAccessCard(icon: "📱", title: "Feed", destination: FeedView())
                    QuickAccessCard(icon: "💬", title: "Conversation", destination: ConversationView())
                    QuickAccessCard(icon: "📊", title: "Statistiques", destination: AnalyticsView())
                }
                .padding(.horizontal)
            }
        }
    }
}
```

---

## 6. AMÉLIORATIONS UI/UX DIVERSES (PRIORITÉ ÉLEVÉE 🟡)

### 6.1 Skeleton Screens
```swift
struct SkeletonLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            SkeletonBox(width: .infinity, height: 200)
            SkeletonBox(width: .infinity, height: 120)
            SkeletonBox(width: .infinity, height: 120)
        }
        .padding()
    }
}

struct SkeletonBox: View {
    let width: CGFloat
    let height: CGFloat
    @State private var shimmer = false
    
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: width == .infinity ? nil : width, height: height)
            .cornerRadius(12)
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.6), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shimmer ? 300 : -300)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmer = true
                }
            }
    }
}
```

### 6.2 Toast Notifications
```swift
@Observable
final class ToastManager {
    var toast: Toast?
    
    func show(message: String, type: ToastType, duration: Double = 3.0) {
        toast = Toast(message: message, type: type)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.toast = nil
        }
    }
}

struct Toast: Identifiable {
    let id = UUID()
    let message: String
    let type: ToastType
    
    enum ToastType {
        case success, error, warning, info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
}

struct ToastView: View {
    let toast: Toast
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .foregroundColor(.white)
            Text(toast.message)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
        .padding()
        .background(toast.type.color)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
    }
}
```

### 6.3 Meilleure Gestion des Erreurs
```swift
// Modifier ErrorManager pour utiliser ToastManager

extension ErrorManager {
    func handleWithToast(_ error: AppError, toast: ToastManager, retry: (() -> Void)? = nil) {
        let message = errorMessage(for: error)
        
        switch error {
        case .networkError:
            toast.show(message: message, type: .warning)
        case .dataCorruption, .syncFailed:
            toast.show(message: message, type: .error)
        default:
            toast.show(message: message, type: .info)
        }
    }
}
```

### 6.4 Audio Controls Globaux
```swift
struct GlobalAudioControls: View {
    @ObservedObject var speechService: SpeechService
    
    var body: some View {
        if speechService.isSpeaking {
            HStack {
                Button(action: { speechService.stop() }) {
                    Image(systemName: "stop.fill")
                }
                
                Text(speechService.currentText ?? "")
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: { speechService.togglePause() }) {
                    Image(systemName: speechService.isPaused ? "play.fill" : "pause.fill")
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
```

---

## 7. CONSTANTES ET CONFIGURATION (PRIORITÉ ÉLEVÉE 🟡)

### 7.1 Learning Path Data
```swift
// Constants+LearningPath.swift

struct LearningPathData {
    static let italianA1 = LevelCurriculum(
        level: .a1,
        chapters: [
            ChapterData(
                id: "a1-ch1",
                title: "Se présenter",
                icon: "👋",
                lessons: [
                    LessonData(
                        id: "a1-ch1-l1",
                        title: "Salutations",
                        type: .vocabulary,
                        vocabularyIds: ["ciao", "buongiorno", "buonasera", "arrivederci", "grazie", "prego"],
                        exercises: [
                            // Exercices prédéfinis
                        ]
                    ),
                    // ... autres leçons
                ]
            ),
            // ... autres chapitres
        ]
    )
    
    static let spanishA1 = LevelCurriculum(/* ... */)
}
```

---

## 📋 CHECKLIST D'IMPLÉMENTATION

### Phase 1: Foundation (Semaine 1-2)
- [ ] Créer les nouveaux modèles (LearningPath, DailySession, etc.)
- [ ] Implémenter LearningPathManager
- [ ] Implémenter DailySessionService
- [ ] Implémenter RecommendationEngine
- [ ] Définir les données de curriculum (A1-A2 minimum)

### Phase 2: UI Core (Semaine 2-3)
- [ ] Créer TodayDashboardView
- [ ] Créer LearningPathView avec ChapterView et LessonView
- [ ] Créer ReviewSessionView
- [ ] Refactoriser ContentView principal
- [ ] Implémenter HeroActionCard

### Phase 3: Intégration (Semaine 3-4)
- [ ] Intégrer ReviewSystem avec l'UI
- [ ] Connecter LearningPath avec le contenu existant
- [ ] Implémenter le filtrage du Feed
- [ ] Ajouter ToastManager et Skeleton screens
- [ ] Implémenter GlobalAudioControls

### Phase 4: Polish (Semaine 4-5)
- [ ] Tests unitaires des nouveaux services
- [ ] Tests UI des nouveaux flows
- [ ] Animations et transitions
- [ ] Accessibilité (VoiceOver, Dynamic Type)
- [ ] Optimisations performance

### Phase 5: Migration (Semaine 5-6)
- [ ] Migration des données utilisateurs existants
- [ ] Backward compatibility
- [ ] Beta testing
- [ ] Documentation
- [ ] Release

---

## 🧪 TESTS REQUIS

### Tests Unitaires
```swift
// LearningPathManagerTests.swift
- testInitializeLearningPath()
- testLessonCompletion()
- testChapterUnlocking()
- testProgressCalculation()

// RecommendationEngineTests.swift
- testWeakAreasIdentification()
- testContentFiltering()
- testNextBestAction()

// DailySessionServiceTests.swift
- testMissionGeneration()
- testSessionCompletion()
- testStreakTracking()
```

### Tests UI
```swift
// DashboardUITests.swift
- testHeroActionCardDisplay()
- testMissionCompletion()
- testNavigationToReview()

// LearningPathUITests.swift
- testChapterUnlocking()
- testLessonProgression()
- testQuizCompletion()
```

---

## 📊 MÉTRIQUES DE SUCCÈS

### KPIs à Suivre Post-Implémentation

#### Engagement
- **Taux de rétention D+7**: Objectif +30%
- **Taux de rétention D+30**: Objectif +25%
- **Sessions quotidiennes moyennes**: Objectif +50%
- **Durée moyenne de session**: Objectif 12-15 minutes

#### Pédagogique
- **Taux de complétion des leçons**: Objectif 70%+
- **Taux de révision des items dus**: Objectif 80%+
- **Progression de niveau (A1→A2)**: Mesurer le temps moyen

#### UX
- **Temps pour première action après login**: Objectif < 10s
- **Taux d'utilisation du Dashboard "Aujourd'hui"**: Objectif 80%+
- **Taux de clics sur action recommandée**: Objectif 60%+

---

## 🚀 STRATÉGIE DE DÉPLOIEMENT

### Approche Phased Rollout

1. **Alpha (interne)**: Équipe dev uniquement
2. **Beta (fermée)**: 50-100 utilisateurs volontaires
3. **Beta (ouverte)**: Tous les utilisateurs existants avec opt-in
4. **Release General Availability**: Tous les nouveaux utilisateurs

### Feature Flags
```swift
struct FeatureFlags {
    static let learningPathEnabled = true
    static let todayDashboardEnabled = true
    static let reviewSessionEnabled = true
    static let recommendationEngineEnabled = true
}
```

---

## 📝 DOCUMENTATION REQUISE

- [ ] **Guide d'architecture** pour les nouveaux composants
- [ ] **API Documentation** pour les services
- [ ] **UI Component Library** (Storybook-like)
- [ ] **User Guide** pour les nouvelles fonctionnalités
- [ ] **Release Notes** détaillées

---

## ✅ CRITÈRES D'ACCEPTATION

### Fonctionnels
- ✅ L'utilisateur peut voir sa mission du jour au lancement
- ✅ L'utilisateur peut suivre un parcours structuré
- ✅ Les révisions sont accessibles en 1 clic depuis le dashboard
- ✅ Le contenu est filtré selon le niveau CECRL
- ✅ Les leçons se débloquent progressivement

### Techniques
- ✅ Aucune régression sur les fonctionnalités existantes
- ✅ Temps de chargement < 2 secondes
- ✅ Crash rate < 1%
- ✅ Couverture de tests > 70%
- ✅ Compatible iOS 16+

### UX
- ✅ Navigation intuitive (tests utilisateurs)
- ✅ Feedback immédiat sur toutes les actions
- ✅ Animations fluides (60 FPS)
- ✅ Accessibilité VoiceOver fonctionnelle

---

**Version:** 1.0  
**Date:** Janvier 2026  
**Approuvé par:** Équipe Produit  
**Prêt pour implémentation:** ✅
