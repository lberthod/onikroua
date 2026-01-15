# 📋 CAHIER DES CHARGES - 4 SPRINTS DE DÉVELOPPEMENT
**Onykroua iOS - Roadmap Pédagogique 2026**

**Date:** 15 Janvier 2026  
**Durée totale:** 8 semaines (4 sprints × 2 semaines)  
**Objectif:** Transformer l'app en plateforme d'apprentissage de référence

---

## 🎯 VISION GLOBALE

### Objectif stratégique
Faire d'Onykroua iOS le **premier tuteur IA vocal italien** sur l'App Store en combinant:
- **Contenu massif** (15,000+ mots déjà présents)
- **IA conversationnelle** (Gemini Live)
- **Gamification addictive** (XP, streaks, badges)
- **Progression structurée** (CEFR A1→C2)

### KPIs cibles (fin Sprint 4)
| Métrique | Actuel | Cible | Gain |
|----------|--------|-------|------|
| **Rétention J7** | ~25% | 50% | +100% |
| **Temps/jour** | 3 min | 12 min | +300% |
| **DAU/MAU** | ~15% | 35% | +133% |
| **App Store rating** | 3.5★ | 4.7★ | +34% |
| **NPS** | 30 | 65 | +117% |

---

## 🏗️ ARCHITECTURE DES 4 SPRINTS

```
SPRINT 1 (S1-S2) ━━━ Fondations & Engagement
    ↓
SPRINT 2 (S3-S4) ━━━ Intelligence & Contenu
    ↓
SPRINT 3 (S5-S6) ━━━ Progression & Qualité
    ↓
SPRINT 4 (S7-S8) ━━━ Excellence & Lancement
```

---

# 🚀 SPRINT 1 - FONDATIONS & ENGAGEMENT
**Durée:** Semaines 1-2  
**Thème:** Rendre l'app addictive et structurée  
**Effort total:** 80 heures

---

## 🎯 Objectifs Sprint 1

### Business Goals
- ✅ Réduire churn J1 de 50% → 25% (-50%)
- ✅ Augmenter temps moyen de 3min → 8min (+167%)
- ✅ Créer habitude quotidienne (streaks)

### Technical Goals
- ✅ Implémenter système de progression CEFR
- ✅ Ajouter gamification complète
- ✅ Créer onboarding engageant

---

## 📦 Features à développer

### 1.1 Système de Progression CEFR (Priorité: P0)
**Effort:** 16 heures  
**Impact:** CRITIQUE - Structure toute l'expérience

#### User Stories
```
US-1.1.1: En tant qu'utilisateur débutant, 
je veux passer un test de niveau initial,
pour recevoir un contenu adapté à mon niveau.

Critères d'acceptation:
- Test de 10 questions (5 min max)
- Évaluation A1, A2, B1, B2, C1
- Résultat affiché avec description
- Redirection vers contenu approprié

US-1.1.2: En tant qu'utilisateur,
je veux voir ma progression dans mon niveau,
pour rester motivé.

Critères d'acceptation:
- Barre de progression visible (0-100%)
- XP actuel / XP requis affiché
- Estimation temps restant
- Célébration passage de niveau
```

#### Spécifications techniques

**Models à créer:**
```swift
// Models/CEFRLevel.swift
enum CEFRLevel: String, Codable {
    case a1 = "A1 - Débutant"
    case a2 = "A2 - Élémentaire"
    case b1 = "B1 - Intermédiaire"
    case b2 = "B2 - Avancé"
    case c1 = "C1 - Autonome"
    case c2 = "C2 - Maîtrise"
    
    var xpRequired: Int {
        switch self {
        case .a1: return 1000
        case .a2: return 2500
        case .b1: return 5000
        case .b2: return 10000
        case .c1: return 20000
        case .c2: return 50000
        }
    }
    
    var description: String { ... }
    var color: Color { ... }
}

// Models/UserProgress.swift
@Model
class UserProgress {
    var currentLevel: CEFRLevel
    var currentXP: Int
    var totalXP: Int
    var wordsLearned: Int
    var lessonsCompleted: Int
    var lastStudyDate: Date
    var streak: Int
    
    var progressPercentage: Double {
        Double(currentXP) / Double(currentLevel.xpRequired)
    }
}
```

**Services à créer:**
```swift
// Services/LevelAssessmentService.swift
class LevelAssessmentService: ObservableObject {
    func generateAssessmentQuestions() -> [AssessmentQuestion]
    func evaluateAnswers(_ answers: [Answer]) -> CEFRLevel
    func unlockContentForLevel(_ level: CEFRLevel)
}
```

**Views à créer:**
```swift
// Views/Onboarding/LevelAssessmentView.swift
- Question display (10 questions)
- Multiple choice answers
- Progress indicator (1/10)
- Submit & evaluate
- Results screen with animation

// Views/Profile/ProgressDashboardView.swift
- Current level badge
- XP bar with animation
- Stats cards (words, lessons, streak)
- Level history
```

**Tests:**
- [ ] Test assessment évalue correctement A1-C2
- [ ] XP s'incrémente après chaque leçon
- [ ] Passage de niveau déclenche célébration
- [ ] Déblocage contenu fonctionne

---

### 1.2 Gamification Complète (Priorité: P0)
**Effort:** 20 heures  
**Impact:** +80% engagement quotidien

#### User Stories
```
US-1.2.1: En tant qu'utilisateur,
je veux gagner des XP pour chaque activité,
pour voir ma progression chiffrée.

Critères:
- Vocabulaire appris: +10 XP
- Verbe conjugué: +15 XP
- Quiz réussi: +20 XP
- Conversation complétée: +30 XP
- Animation XP gain visible

US-1.2.2: En tant qu'utilisateur,
je veux maintenir un streak quotidien,
pour créer une habitude.

Critères:
- Compteur de jours consécutifs
- Flamme 🔥 visible partout
- Alerte avant perte du streak
- Bouclier de protection (1 oubli gratuit)

US-1.2.3: En tant qu'utilisateur,
je veux débloquer des badges,
pour célébrer mes accomplissements.

Critères:
- 30+ badges définis
- Notification déblocage
- Galerie badges dans profil
- Partage sur réseaux sociaux
```

#### Spécifications techniques

**Models:**
```swift
// Models/Achievement.swift
enum AchievementType {
    case firstWord
    case streak7Days
    case streak30Days
    case level100
    case perfectWeek
    case vocabularyMaster
    // ... 24 autres
}

struct Achievement: Identifiable {
    let id: UUID
    let type: AchievementType
    let name: String
    let description: String
    let icon: String
    let xpReward: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
}

// Models/DailyStreak.swift
@Model
class DailyStreak {
    var currentStreak: Int
    var longestStreak: Int
    var lastStudyDate: Date
    var freezeAvailable: Bool
    
    func checkStreak() -> Bool
    func incrementStreak()
    func breakStreak()
}
```

**Services:**
```swift
// Services/GamificationManager.swift
class GamificationManager: ObservableObject {
    @Published var xp: Int = 0
    @Published var level: Int = 1
    @Published var achievements: [Achievement] = []
    
    func awardXP(_ amount: Int, for activity: Activity)
    func checkLevelUp()
    func unlockAchievement(_ type: AchievementType)
    func checkDailyGoal() -> Bool
}
```

**Views:**
```swift
// Views/Components/XPGainAnimation.swift
- Confetti animation
- XP counter animation
- Level up modal

// Views/Profile/AchievementsView.swift
- Grid of badges (locked/unlocked)
- Progress bars for each
- Share button

// Views/Components/StreakWidget.swift
- Flame icon avec compteur
- Calendar view 7 derniers jours
- Freeze button si disponible
```

**Liste des 30 badges:**
1. 🎯 Premier mot - Apprendre 1 mot
2. 📚 Bibliophile - 100 mots appris
3. 🧠 Érudit - 500 mots appris
4. 🏆 Maître - 1000 mots appris
5. 🔥 Streak 7 jours
6. ⚡ Streak 30 jours
7. 💎 Streak 100 jours
8. ✨ Semaine parfaite - 7/7 jours
9. 🎓 Premier niveau - Atteindre A2
10. 🌟 Niveau B1
11. 💫 Niveau B2
12. 🚀 Niveau C1
13. 👑 Niveau C2
14. 🗣️ Conversateur - 10 dialogues
15. ✍️ Grammairien - 20 règles maîtrisées
16. 🎤 Orateur - 50 prononciations
17. ⚡ Vitesse - Leçon en < 2 min
18. 🎯 Précision - 95% réussite
19. 🌅 Lève-tôt - Étudier avant 8h
20. 🌙 Nocturne - Étudier après 22h
21. 📱 Accro - 50 sessions
22. 💪 Acharné - 100 sessions
23. 🎨 Collectionneur emoji - Toutes catégories
24. 🚂 Voyageur - Tous scénarios
25. 🎲 Chanceux - Quiz parfait 10x
26. 🔄 Réviseur - 100 révisions
27. 📊 Analytique - Consulter stats 10x
28. 👥 Social - Partager 5 badges
29. 🎁 Généreux - Inviter 3 amis
30. 🏅 Légende - Tous les badges

**Tests:**
- [ ] XP s'accumule correctement
- [ ] Streak s'incrémente si étude quotidienne
- [ ] Badges se débloquent aux bons moments
- [ ] Animations sont fluides

---

### 1.3 Onboarding Engageant (Priorité: P0)
**Effort:** 12 heures  
**Impact:** -50% abandon J1

#### User Stories
```
US-1.3.1: En tant que nouvel utilisateur,
je veux être guidé au premier lancement,
pour comprendre comment utiliser l'app.

Critères:
- 5 écrans maximum
- Skippable après écran 1
- Illustrations attractives
- CTA clairs
```

#### Spécifications

**Flow onboarding:**
```
Écran 1: Welcome
- Logo animé
- Titre: "Apprendre l'italien avec l'IA"
- Sous-titre: "15,000 mots • Tuteur IA • Gamification"
- Bouton: "Commencer"
- Lien: "J'ai déjà un compte"

Écran 2: Choix de langue
- Drapeaux IT / ES
- "Quelle langue veux-tu apprendre?"
- Sélection unique
- Bouton: "Suivant"

Écran 3: Objectif
- Options:
  □ Voyage / Vacances
  □ Travail / Business
  □ Études
  □ Passion / Culture
- Multi-sélection possible
- Bouton: "Suivant"

Écran 4: Test de niveau
- "Quel est ton niveau actuel?"
- Options:
  □ Débutant complet (A1)
  □ J'ai des bases (A2)
  □ Intermédiaire (B1)
  □ Avancé (B2+)
  □ Je ne sais pas → Test automatique
- Bouton: "Suivant"

Écran 5: Rythme d'apprentissage
- "Combien de temps par jour?"
- Slider: 5 min → 60 min
- Objectif XP calculé
- Bouton: "C'est parti!"

Écran 6: Permissions (optionnel)
- Notifications: "Rappels quotidiens"
- Toggle ON/OFF
- Explication: "On te rappellera de pratiquer"
- Bouton: "Terminer"
```

**Views:**
```swift
// Views/Onboarding/OnboardingContainerView.swift
- PageView avec 6 écrans
- Indicateur de progression (dots)
- Skip button (top-right)
- Back/Next navigation

// Views/Onboarding/WelcomeScreen.swift
// Views/Onboarding/LanguageSelectionScreen.swift
// Views/Onboarding/GoalSelectionScreen.swift
// Views/Onboarding/LevelSelectionScreen.swift
// Views/Onboarding/RhythmSelectionScreen.swift
// Views/Onboarding/PermissionsScreen.swift
```

**Models:**
```swift
struct OnboardingData {
    var selectedLanguage: Language
    var goals: [LearningGoal]
    var initialLevel: CEFRLevel
    var dailyGoalMinutes: Int
    var notificationsEnabled: Bool
}
```

**Tests:**
- [ ] Peut skip après écran 1
- [ ] Toutes sélections sauvegardées
- [ ] Redirection correcte après onboarding
- [ ] Ne s'affiche qu'une fois

---

### 1.4 Système de Notifications (Priorité: P1)
**Effort:** 8 heures

#### Spécifications
```swift
// Services/NotificationManager.swift
- Rappel quotidien (heure choisie)
- Alerte perte de streak (23h si pas d'activité)
- Badge déblocage
- Niveau atteint
- Défi quotidien disponible
```

**Types de notifications:**
1. Daily reminder: "🔥 Maintiens ton streak de X jours!"
2. Streak warning: "⚠️ Plus que 1h pour sauver ton streak!"
3. Achievement: "🎉 Badge débloqué: [Nom]"
4. Level up: "🎓 Félicitations! Niveau [X] atteint"
5. Encouragement: "💪 3 mots de plus pour ton objectif!"

---

### 1.5 Révision du VocabularyView (Priorité: P1)
**Effort:** 12 heures

#### Améliorations
```
Actuellement:
- Liste plate de mots
- Aucun filtrage par niveau

Nouveau:
- Filtrage par niveau CEFR
- Tag de difficulté (A1, A2, etc.)
- Indicateur "Maîtrisé" vs "À réviser"
- Recherche avancée
- Favoris en haut
```

**Models:**
```swift
extension VocabularyWord {
    var cefrLevel: CEFRLevel
    var masteryLevel: Int // 0-100%
    var lastReviewedDate: Date?
    var reviewCount: Int
    var correctCount: Int
    
    var needsReview: Bool {
        // SRS algorithm
    }
}
```

---

### 1.6 Dashboard de Statistiques (Priorité: P1)
**Effort:** 10 heures

#### Contenu
```
ProfileView enrichi:

📊 Cette semaine
- XP gagné: 450 XP (+20% vs semaine dernière)
- Temps d'étude: 1h 23min
- Mots appris: 23
- Leçons complétées: 8

📈 Progression
- Graphique XP (7 derniers jours)
- Graphique temps d'étude
- Streak calendar

🎯 Objectifs
- Objectif quotidien: 12/15 min ✅
- Objectif hebdomadaire: 5/7 jours ⚠️
- Mots ce mois: 87/100

🏆 Badges récents
- 3 derniers badges débloqués
- Prochain badge: +15% de progression
```

---

## 🧪 Tests & Validation Sprint 1

### Tests unitaires (40 tests minimum)
```swift
// CEFRLevelTests.swift
- testXPRequiredForEachLevel()
- testProgressPercentageCalculation()

// GamificationManagerTests.swift
- testXPAwardCorrectly()
- testLevelUpTriggersAtThreshold()
- testAchievementUnlocking()

// DailyStreakTests.swift
- testStreakIncrementOnDailyStudy()
- testStreakBreaksAfter24Hours()
- testFreezePreventBreak()

// OnboardingTests.swift
- testDataPersistsAfterOnboarding()
- testOnboardingShowsOnlyOnce()
```

### Tests UI (10 scenarios)
```swift
// OnboardingUITests.swift
- testCanCompleteFullOnboarding()
- testCanSkipAfterFirstScreen()

// GamificationUITests.swift
- testXPAnimationPlays()
- testBadgeUnlockModalAppears()
- testStreakCounterIncrements()
```

### Tests manuels
- [ ] Onboarding fluide sur iPhone 12, 14, 15
- [ ] iPad adaptatif
- [ ] Dark mode complet
- [ ] Animations 60 FPS
- [ ] Pas de memory leak

---

## 📋 Checklist Sprint 1

### Code
- [ ] 6 Models créés (CEFRLevel, UserProgress, Achievement, DailyStreak, OnboardingData, NotificationData)
- [ ] 4 Services créés (LevelAssessment, Gamification, Notification, Analytics)
- [ ] 15 Views créées (Onboarding × 6, Assessment, Dashboard, Achievements, etc.)
- [ ] 50 tests écrits et passent

### Design
- [ ] 30 icônes de badges créés
- [ ] Illustrations onboarding (5)
- [ ] Animations XP/Level up
- [ ] Color palette enrichie

### Data
- [ ] Tags CEFR ajoutés aux 15,000 mots
- [ ] Difficulté définie pour chaque mot
- [ ] Questions assessment créées (50)

### Documentation
- [ ] README Sprint 1 résultats
- [ ] Changelog v1.2
- [ ] Screenshots App Store mis à jour

---

## 🎯 Critères de succès Sprint 1

### Quantitatifs
- ✅ Churn J1: 50% → 25% (-50%)
- ✅ Temps moyen: 3 min → 8 min (+167%)
- ✅ Completion onboarding: >85%
- ✅ XP moyen/utilisateur: >200 XP/semaine

### Qualitatifs
- ✅ Onboarding Net Promoter Score: >70
- ✅ Aucun crash lié aux nouvelles features
- ✅ App Store reviews: "Progression claire" mentionnée

---

# 🤖 SPRINT 2 - INTELLIGENCE & CONTENU
**Durée:** Semaines 3-4  
**Effort total:** 75 heures  
**Thème:** IA conversationnelle + Explosion de contenu

---

## 🎯 Objectifs Sprint 2

### Business Goals
- ✅ Différenciation concurrentielle (premier tuteur IA vocal IT)
- ✅ Temps d'étude: 8 min → 12 min (+50%)
- ✅ Feature adoption Gemini: >40%

### Technical Goals
- ✅ Intégrer Gemini API
- ✅ Reconnaissance vocale
- ✅ Tripler les scénarios (4 → 20+)

---

## 📦 Features Sprint 2

### 2.1 Intégration Gemini Live (Priorité: P0)
**Effort:** 24 heures  
**Impact:** GAME CHANGER

#### User Stories
```
US-2.1.1: En tant qu'utilisateur,
je veux parler en italien avec une IA,
pour pratiquer en conditions réelles.

Critères:
- Conversation vocale temps réel
- Réponses en <2 secondes
- Correction grammaticale automatique
- Suggestions de vocabulaire
- Historique sauvegardé

US-2.1.2: En tant qu'utilisateur,
je veux recevoir du feedback sur mes erreurs,
pour m'améliorer.

Critères:
- Détection erreurs grammaticales
- Explication en français
- Proposition correction
- Exemples similaires
```

#### Architecture technique

**Gemini API Setup:**
```swift
// Services/GeminiService.swift
import GoogleGenerativeAI

class GeminiService: ObservableObject {
    private let model: GenerativeModel
    private let apiKey: String
    
    @Published var isConnected = false
    @Published var currentConversation: [Message] = []
    
    init() {
        apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
        model = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
    }
    
    // Conversation mode
    func startConversation(topic: ConversationTopic)
    func sendMessage(_ text: String) async throws -> String
    func correctGrammar(_ text: String) async throws -> Correction
    func generateExercise(level: CEFRLevel) async throws -> Exercise
    func explainConcept(_ concept: String) async throws -> Explanation
}

struct Correction {
    let original: String
    let corrected: String
    let errors: [GrammarError]
    let explanation: String
}

struct GrammarError {
    let type: ErrorType // verb, article, preposition, etc.
    let position: Range<String.Index>
    let correction: String
    let rule: String
}
```

**Prompts optimisés:**
```swift
enum GeminiPrompt {
    static let conversationStarter = """
    Tu es un professeur d'italien natif, patient et encourageant.
    L'utilisateur est niveau \(level).
    Commence une conversation sur: \(topic).
    Utilise un vocabulaire adapté au niveau.
    Pose des questions ouvertes.
    Corrige gentiment les erreurs.
    """
    
    static let grammarCorrector = """
    Analyse cette phrase en italien:
    "\(userInput)"
    
    Identifie toutes les erreurs grammaticales.
    Pour chaque erreur:
    1. Type d'erreur
    2. Correction
    3. Explication en français
    4. Exemple similaire correct
    
    Format JSON.
    """
    
    static let exerciseGenerator = """
    Génère un exercice de niveau \(level) sur: \(topic).
    Types possibles: QCM, traduction, trou, conjugaison.
    Fournis 5 questions + réponses + explications.
    Format JSON.
    """
}
```

**Views:**
```swift
// Views/GeminiLive/GeminiChatView.swift
- Interface chat (bubbles)
- Bouton micro (record)
- Corrections en temps réel
- Historique conversations

// Views/GeminiLive/VoiceRecorderView.swift
- Waveform animation
- Timer enregistrement
- Cancel/Send buttons

// Views/GeminiLive/CorrectionDetailView.swift
- Erreur surlignée
- Explication détaillée
- Règle de grammaire liée
- Exemples similaires
```

**Sécurité API Key:**
```swift
// Utiliser Swift Package Manager Secrets
// OU backend Firebase Functions (recommandé)

// Functions/gemini-proxy.ts
export const callGemini = functions.https.onCall(async (data, context) => {
    // Vérifier auth
    if (!context.auth) throw new Error("Unauthorized")
    
    // Rate limiting
    // Call Gemini API
    // Return response
})
```

---

### 2.2 Reconnaissance Vocale (Priorité: P0)
**Effort:** 12 heures

#### Implémentation
```swift
// Services/SpeechRecognitionService.swift
import Speech

class SpeechRecognitionService: ObservableObject {
    @Published var recognizedText = ""
    @Published var isRecording = false
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "it-IT"))!
    
    func requestAuthorization() async -> Bool
    func startRecording()
    func stopRecording() -> String
    func analyzePronunciation(_ text: String, expected: String) -> PronunciationScore
}

struct PronunciationScore {
    let accuracy: Double // 0-100%
    let issues: [PronunciationIssue]
    let overallFeedback: String
}

struct PronunciationIssue {
    let word: String
    let expected: String
    let actual: String
    let confidence: Double
}
```

**UI:**
```swift
// Views/Practice/PronunciationPracticeView.swift
- Affiche phrase à lire
- Bouton micro (record)
- Score affiché (0-100%)
- Replay audio (native vs user)
- Conseils amélioration
```

---

### 2.3 Expansion Scénarios (4 → 24) (Priorité: P1)
**Effort:** 18 heures

#### Nouveaux scénarios (20)
```
Voyage (8 scénarios)
1. ✈️ Aéroport - Check-in
2. 🛃 Douane - Déclaration
3. 🚕 Taxi - Destination
4. 🗺️ Tourisme - Informations
5. 📸 Photos - Demander service
6. 🎫 Musée - Achat billets
7. 🏖️ Plage - Location parasol
8. 🚌 Bus - Horaires

Vie quotidienne (6 scénarios)
9. 🏪 Supermarché - Courses
10. 💊 Pharmacie - Ordonnance
11. ✂️ Coiffeur - Rendez-vous
12. 📦 Poste - Envoi colis
13. 🏦 Banque - Ouverture compte
14. 📞 Téléphone - Réclamation

Professionnel (3 scénarios)
15. 💼 Entretien - Job interview
16. 📧 Email - Correspondance
17. 🤝 Réunion - Présentation

Social (3 scénarios)
18. 🎉 Fête - Invitation
19. ☕ Café - Discussion
20. ❤️ Dating - Rendez-vous
```

**Structure enrichie:**
```swift
struct ConversationScenario {
    let id: UUID
    let title: String
    let category: ScenarioCategory // voyage, quotidien, pro, social
    let difficulty: CEFRLevel
    let duration: Int // minutes
    let vocabulary: [String] // mots clés
    let grammar: [String] // concepts grammaticaux
    let messages: [Message]
    let alternatives: [[Message]] // 3 variations
    let culturalNote: String?
    
    // Mode interactif
    let interactiveMode: Bool
    let userChoices: [Choice]?
}

struct Choice {
    let prompt: String
    let options: [String]
    let correctAnswer: Int
    let feedback: String
}
```

**Exemple scénario interactif:**
```swift
Scenario: Pharmacie 💊
Difficulté: A2
Durée: 5 min

[Bot] Buongiorno! Come posso aiutarla?

[User - Choix multiples]
A) Ho mal di testa. ✅
B) Ho un testa mal. ❌
C) J'ai mal à la tête. ❌

[Feedback si B]
"Attention à l'ordre: 'mal di testa' (mal de tête).
En italien, on dit 'ho mal di X' pas 'ho un X mal'."

[Bot] Ha la febbre?

[User - Réponse libre avec micro]
→ Reconnaissance vocale + correction Gemini
...
```

---

### 2.4 Module Culture Italienne (Priorité: P2)
**Effort:** 10 heures

#### Contenu (30 articles)
```
Histoire (5)
- Renaissance italienne
- Empire romain
- Unification (Risorgimento)
- Seconde Guerre mondiale
- République italienne

Cuisine (10)
- Pizza napolitaine
- Pasta types (20 formes)
- Fromages (Parmigiano, Mozzarella, Gorgonzola)
- Vins par région
- Café culture
- Gelato artisanal
- Cuisine régionale (Nord vs Sud)
- Aperitivo tradition
- Slow Food movement
- Street food italien

Art & Architecture (5)
- Michel-Ange
- Léonard de Vinci
- Botticelli
- Caravaggio
- Architecture baroque

Festivals (5)
- Carnevale di Venezia
- Palio di Siena
- Infiorata
- Festa della Repubblica
- Ferragosto

Géographie (5)
- Régions italiennes (20)
- Villes principales
- Lacs italiens
- Volcans (Etna, Vésuve)
- Îles (Sicile, Sardaigne)
```

**Format:**
```swift
struct CulturalArticle {
    let title: String
    let category: CultureCategory
    let level: CEFRLevel
    let readingTime: Int // minutes
    let content: String // en italien
    let translation: String // en français
    let vocabulary: [VocabularyWord]
    let quiz: [Question]
    let images: [String]
    let audio: String? // narration TTS
}
```

**View:**
```swift
// Views/Culture/CultureFeedView.swift
- Cartes article avec image
- Catégories filtrables
- Temps de lecture
- Audio narration
- Quiz fin d'article
- Favoris
```

---

### 2.5 Système de Quiz Interactifs (Priorité: P1)
**Effort:** 11 heures

#### Types de quiz
```swift
enum QuizType {
    case multipleChoice // QCM
    case fillInTheBlank // Trous
    case translation // FR → IT ou IT → FR
    case conjugation // Conjuguer verbe
    case listening // Écouter + répondre
    case speaking // Prononcer + évaluation
    case matching // Relier mots/images
    case ordering // Remettre dans l'ordre
}

struct Quiz {
    let type: QuizType
    let level: CEFRLevel
    let category: String
    let questions: [Question]
    let timeLimit: Int? // secondes
    let xpReward: Int
}

struct Question {
    let prompt: String
    let options: [String]?
    let correctAnswer: String
    let explanation: String
    let hint: String?
}
```

**UI:**
```swift
// Views/Quiz/QuizView.swift
- Timer (si limité)
- Compteur questions (3/10)
- Options cliquables
- Feedback immédiat (✅/❌)
- Explication post-réponse
- Score final
- XP reward animation
```

**Génération avec Gemini:**
```swift
func generateQuiz(topic: String, level: CEFRLevel, count: Int) async -> Quiz {
    let prompt = """
    Génère \(count) questions de quiz sur: \(topic)
    Niveau: \(level)
    Types variés: QCM, traduction, conjugaison
    Format JSON avec explications
    """
    // Call Gemini
}
```

---

## 🧪 Tests Sprint 2

### Tests API
- [ ] Gemini répond en <2s (95% du temps)
- [ ] Corrections grammaticales exactes (>90%)
- [ ] Reconnaissance vocale précision >85%

### Tests contenu
- [ ] 24 scénarios fonctionnels
- [ ] 30 articles culture vérifiés
- [ ] 100+ quiz générés

---

## 📋 Checklist Sprint 2

- [ ] Gemini API intégrée et sécurisée
- [ ] 24 scénarios conversationnels créés
- [ ] 30 articles culture rédigés
- [ ] Reconnaissance vocale fonctionnelle
- [ ] Quiz interactifs implémentés
- [ ] 40 tests passent

---

## 🎯 Critères succès Sprint 2

- ✅ Feature adoption Gemini: >40%
- ✅ Temps moyen: 8 → 12 min (+50%)
- ✅ Satisfaction IA: NPS >70
- ✅ Quiz completion rate: >60%

---

# 📚 SPRINT 3 - PROGRESSION & QUALITÉ
**Durée:** Semaines 5-6  
**Effort:** 70 heures  
**Thème:** SRS + 100 verbes + Analytics

---

## 🎯 Objectifs Sprint 3

### Business
- ✅ Rétention J30: 30% → 45% (+50%)
- ✅ Mots maîtrisés/utilisateur: +200%

### Technical
- ✅ SRS algorithmique (Anki-like)
- ✅ 100 verbes totaux
- ✅ Analytics dashboards

---

## 📦 Features Sprint 3

### 3.1 Spaced Repetition System (Priorité: P0)
**Effort:** 16 heures

#### Algorithme SM-2 (SuperMemo)
```swift
// Services/SRSService.swift
class SRSService: ObservableObject {
    func scheduleReview(for item: ReviewableItem, quality: Int) -> Date {
        // quality: 0 (oublié) à 5 (facile)
        let easeFactor = calculateEaseFactor(quality)
        let interval = calculateInterval(repetition, easeFactor)
        return Date().addingTimeInterval(interval)
    }
}

@Model
class ReviewableItem {
    var word: VocabularyWord
    var easeFactor: Double = 2.5
    var interval: TimeInterval = 0
    var repetitionCount: Int = 0
    var nextReviewDate: Date
    var lastReviewDate: Date?
    var reviewHistory: [Review]
}

struct Review {
    let date: Date
    let quality: Int // 0-5
    let duration: TimeInterval
}
```

**Daily Review Deck:**
```swift
// Views/Review/DailyReviewView.swift
- Carte vocabulaire (front/back)
- Boutons qualité: ❌ Encore | 🤔 Difficile | ✅ Correct | 😎 Facile
- Compteur restant
- Estimation temps
- Stats session
```

---

### 3.2 100 Verbes Italiens (Priorité: P1)
**Effort:** 20 heures

#### Liste prioritaire
```
Auxiliaires (2) ✅ FAIT
- essere, avere

Modaux (4) ✅ FAIT + ajouter:
- sapere, dovere, potere, volere

Mouvement (10)
✅ FAIT: andare, venire, partire, uscire
+ AJOUTER:
- tornare, arrivare, entrare, scendere, salire, correre

Communication (8)
- parlare ✅, dire ✅
+ dire, raccontare, chiedere, rispondere, telefonare, scrivere ✅

Perception (5)
- vedere ✅, sentire, ascoltare, guardare, toccare

Vie quotidienne (15)
- mangiare ✅, bere ✅, dormire ✅
+ svegliarsi, alzarsi, lavarsi, vestirsi, pettinarsi, 
  truccarsi, fare colazione, pranzare, cenare, 
  cucinare, pulire, stirare

Travail (8)
- lavorare, studiare, imparare, insegnare, 
  guadagnare, perdere, vincere, finire ✅

Émotions (10)
- amare, odiare, preferire, piacere, volere ✅,
  desiderare, sperare, temere, preoccuparsi, rilassarsi

Actions (15)
- fare ✅, dare ✅, prendere ✅, portare, mettere,
  togliere, aprire, chiudere, comprare, vendere,
  pagare, trovare, cercare, perdere, lasciare

Météo (3)
- piovere, nevicare, fare (caldo/freddo)

Cognitif (10)
- sapere ✅, conoscere ✅, capire ✅, pensare,
  credere, ricordare, dimenticare, immaginare,
  sognare, decidere

Social (10)
- incontrare, salutare, baciare, abbracciare,
  aiutare, ringraziare, scusare, invitare,
  rifiutare, accettare
```

**Données enrichies:**
```swift
extension Verb {
    var examples: [Example] // 5 exemples contextuels
    var synonyms: [String]
    var antonyms: [String]
    var commonExpressions: [Expression]
    var frequency: FrequencyLevel // rare, uncommon, common, very common
    var registerStyle: RegisterStyle // formal, neutral, informal, slang
}

struct Example {
    let sentence: String
    let translation: String
    let context: String // "Au restaurant", "En famille"
}

struct Expression {
    let text: String // "andare d'accordo"
    let meaning: String // "s'entendre"
    let example: String
}
```

---

### 3.3 Analytics Avancées (Priorité: P1)
**Effort:** 14 heures

#### Dashboards
```swift
// Views/Analytics/AnalyticsDashboardView.swift

Section 1: Vue d'ensemble
- Total XP
- Niveau actuel + progression
- Streak + record
- Temps total d'étude

Section 2: Cette semaine
- Graphique XP (7 jours)
- Temps par jour
- Mots appris vs révisés
- Leçons complétées

Section 3: Performance
- Taux de réussite quiz (%)
- Mots maîtrisés / Total
- Catégories fortes vs faibles
- Évolution niveau (graphique)

Section 4: Prédictions
- "À ce rythme, niveau B1 dans 45 jours"
- "Objectif 1000 mots dans 3 semaines"
- Recommandations personnalisées

Section 5: Comparaison
- Percentile vs autres apprenants
- Moyenne quotidienne vs objectif
```

**Services:**
```swift
// Services/AnalyticsService.swift
class AnalyticsService: ObservableObject {
    func calculateRetentionRate() -> Double
    func predictLevelUpDate() -> Date
    func identifyWeakCategories() -> [Category]
    func generatePersonalizedRecommendations() -> [Recommendation]
    func compareToAverage() -> ComparisonResult
}
```

---

### 3.4 Mode Hors Ligne Complet (Priorité: P1)
**Effort:** 12 heures

```swift
// Services/OfflineManager.swift
- Télécharger audio TTS (top 1000 mots)
- Cache articles culture
- Queue actions (sync quand online)
- SwiftData pour tout le contenu
- iCloud sync multi-device
```

---

### 3.5 Amélioration Grammaire (12 → 50 règles) (Priorité: P1)
**Effort:** 8 heures

**Nouvelles règles (38):**
```
Articles (8 règles)
- Articles définis (il, lo, la, i, gli, le)
- Articles indéfinis (un, uno, una, un')
- Articles partitifs
- Prépositions articulées (del, della, dello...)
- Cas spéciaux (l', gli)

Prépositions (10 règles)
- di, a, da, in, con, su, per, tra/fra
- Contractions obligatoires
- Usages idiomatiques
- Différences avec français

Temps & Modes (8 règles)
- Passé composé vs Imparfait
- Passé simple
- Plus-que-parfait
- Futur antérieur
- Conditionnel passé
- Subjonctif présent
- Subjonctif passé
- Gérondif

Pronoms (6 règles)
- Pronoms COD (lo, la, li, le)
- Pronoms COI (mi, ti, gli, le...)
- Pronoms combinés (glielo, gliene...)
- Pronoms relatifs (che, cui, quale...)
- Ne partitif
- Ci locatif

Adjectifs (6 règles)
- Accord en genre/nombre
- Position (avant/après nom)
- Possessifs (mio, tuo, suo...)
- Démonstratifs (questo, quello)
- Comparatifs (più, meno, come...)
- Superlatifs (il più, -issimo)
```

---

## 📋 Checklist Sprint 3

- [ ] SRS fonctionnel avec algorithme SM-2
- [ ] 100 verbes avec conjugaisons complètes
- [ ] 50 règles de grammaire
- [ ] Analytics dashboards implémentés
- [ ] Mode offline 100% fonctionnel
- [ ] 50 tests ajoutés

---

## 🎯 Critères succès Sprint 3

- ✅ Rétention J30: >45%
- ✅ Mots maîtrisés: +200%
- ✅ Review completion: >70%
- ✅ Offline usage: >30%

---

# 🚀 SPRINT 4 - EXCELLENCE & LANCEMENT
**Durée:** Semaines 7-8  
**Effort:** 65 heures  
**Thème:** Polish + Marketing + Launch

---

## 🎯 Objectifs Sprint 4

### Business
- ✅ App Store launch
- ✅ Rating >4.5★
- ✅ 1000 downloads S1

### Technical
- ✅ 0 crash
- ✅ Performance optimale
- ✅ A/B testing ready

---

## 📦 Features Sprint 4

### 4.1 Performance & Optimization (Priorité: P0)
**Effort:** 12 heures

```
- Cold start <1s
- Memory <100MB
- Bundle size optimization
- Image compression
- SwiftData indexing
- Lazy loading partout
- Instruments profiling
```

---

### 4.2 Accessibility WCAG 2.1 (Priorité: P0)
**Effort:** 10 heures

```
- VoiceOver labels complets
- Dynamic Type support
- Contrast ratios 4.5:1+
- Sous-titres audio
- Haptic feedback
- Keyboard navigation
- Screen reader optimisé
```

---

### 4.3 Social Features (Priorité: P2)
**Effort:** 14 heures

```
- Ajouter amis
- Leaderboard amis
- Défis amis (qui atteint 100 XP en premier?)
- Partage badges sur réseaux
- Invite friends (3 invités = badge)
```

---

### 4.4 Premium Tier (Priorité: P2)
**Effort:** 12 heures

```swift
enum SubscriptionTier {
    case free
    case premium // 9.99€/mois ou 79.99€/an
}

Premium features:
- Gemini illimité (free: 20 messages/jour)
- Offline audio natif humain
- Export/Import données
- Statistiques avancées
- Pas de limite leçons/jour
- Contenu exclusif (50 scénarios VIP)
- Badge premium
```

---

### 4.5 App Store Optimization (Priorité: P0)
**Effort:** 8 heures

```
À préparer:
- 10 screenshots (iPhone + iPad)
- Vidéo preview 30s
- Description optimisée (keywords)
- Privacy policy
- EULA
- Support page
- Localization (IT, FR, EN)
- Metadata App Store Connect
```

---

### 4.6 Tests Finaux (Priorité: P0)
**Effort:** 9 heures

```
- TestFlight beta (50 testeurs)
- Bug bash (toute l'équipe)
- Performance testing
- Security audit
- Privacy compliance
- TestFlight feedback loop
```

---

## 📊 MÉTRIQUES DE SUCCÈS GLOBALES (POST SPRINT 4)

| KPI | Avant | Après | Gain |
|-----|-------|-------|------|
| **Rétention J1** | 50% | 75% | +50% |
| **Rétention J7** | 25% | 50% | +100% |
| **Rétention J30** | 15% | 45% | +200% |
| **Temps/jour** | 3 min | 12 min | +300% |
| **DAU/MAU** | 15% | 35% | +133% |
| **Mots maîtrisés** | 10 | 50 | +400% |
| **App Store rating** | 3.5★ | 4.7★ | +34% |
| **NPS** | 30 | 65 | +117% |
| **Conversion premium** | 0% | 5% | - |

---

## 💰 BUDGET & RESSOURCES

### Équipe recommandée
- 1 iOS Developer senior (Fulltime)
- 1 Designer UI/UX (50%)
- 1 Content Creator italien natif (30%)
- 1 QA Tester (30%)

### Coûts estimés (8 semaines)
- Développement: 40,000€
- Design: 8,000€
- Contenu: 5,000€
- QA: 4,000€
- Infrastructure (Firebase, Gemini API): 500€/mois
- **TOTAL: ~60,000€**

### ROI projeté
- Revenue Y1 (5% conversion × 10,000 users × 79.99€): ~40,000€
- Revenue Y2 (scaling): ~200,000€
- **ROI: 233% sur 2 ans**

---

## 📅 TIMELINE DÉTAILLÉE

```
Semaine 1-2: Sprint 1 - Fondations
├── J1-3: Onboarding
├── J4-7: Système CEFR
├── J8-10: Gamification
└── J11-14: Tests + Review

Semaine 3-4: Sprint 2 - IA
├── J15-18: Gemini API
├── J19-21: Scénarios
├── J22-24: Culture
└── J25-28: Tests + Review

Semaine 5-6: Sprint 3 - Progression
├── J29-32: SRS
├── J33-36: 100 verbes
├── J37-39: Analytics
└── J40-42: Tests + Review

Semaine 7-8: Sprint 4 - Launch
├── J43-46: Performance
├── J47-49: ASO
├── J50-52: TestFlight
├── J53-54: Corrections
└── J55-56: 🚀 LAUNCH
```

---

## ✅ CHECKLIST FINALE AVANT LAUNCH

### Code
- [ ] 200+ tests unitaires passent
- [ ] 50+ tests UI passent
- [ ] 0 warning Xcode
- [ ] Code coverage >70%
- [ ] SwiftLint violations: 0
- [ ] Memory leaks: 0
- [ ] Crash rate <0.1%

### Contenu
- [ ] 15,000 mots validés
- [ ] 100 verbes conjugués
- [ ] 50 règles grammaire
- [ ] 24 scénarios testés
- [ ] 30 articles culture relus
- [ ] Audio TTS fonctionnel

### Design
- [ ] 30 badges créés
- [ ] Animations polies
- [ ] Dark mode parfait
- [ ] iPad adapté
- [ ] Accessibility compliant

### Legal & Admin
- [ ] Privacy policy
- [ ] Terms of Service
- [ ] RGPD compliant
- [ ] App Store guideline compliant
- [ ] Firebase configuré
- [ ] Gemini API budget défini

### Marketing
- [ ] Landing page prête
- [ ] Social media posts planifiés
- [ ] Press kit préparé
- [ ] Influenceurs contactés
- [ ] Launch plan défini

---

## 🎉 CONCLUSION

Ce cahier des charges sur **4 sprints (8 semaines)** transformera Onykroua iOS d'une app de vocabulaire basique en un **tuteur IA complet et addictif**.

### Différenciateurs clés post-4 sprints:
1. **Premier tuteur IA vocal italien** sur iOS
2. **15,000+ mots** (3x Duolingo)
3. **Gamification complète** (XP, badges, streaks)
4. **Progression CEFR** structurée
5. **SRS algorithmique** (mémorisation optimale)

### Prochaines étapes immédiates:
1. ✅ Valider budget (60k€)
2. ✅ Assembler équipe
3. ✅ Sprint 1 kickoff
4. 🚀 Launch dans 8 semaines

**Ready to build the best Italian learning app on iOS! 🇮🇹**

---

**Créé le:** 15 Janvier 2026  
**Auteur:** Cascade AI  
**Version:** 1.0  
**Documents liés:** AUDIT-PEDAGOGIQUE-2026.md
