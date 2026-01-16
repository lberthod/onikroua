# 🔥 Firebase Realtime Database - Guide d'Intégration

## 📱 Onikroua iOS - Synchronisation Cloud

Ce guide explique l'intégration complète de Firebase Realtime Database pour synchroniser les données utilisateur sur tous les appareils.

---

## ✨ Fonctionnalités Cloud

### Données Synchronisées

#### 1. **Progression Utilisateur** (`/userProgress/{userId}`)
```json
{
  "currentXP": 1250,
  "totalXP": 3500,
  "level": "B1",
  "streak": 15,
  "longestStreak": 30,
  "lastStudyDate": 1705353600,
  "wordsLearned": 450,
  "verbsLearned": 35,
  "grammarRulesLearned": 25,
  "conversationsCompleted": 8,
  "quizzesCompleted": 42,
  "quizSuccessRate": 0.85,
  "exercisesCompleted": 120,
  "flashcardsReviewed": 350,
  "achievementsUnlocked": ["first_word", "streak_7", "words_100"],
  "dailyGoal": 5,
  "dailyXPGained": 150,
  "selectedLanguage": "it",
  "updatedAt": {".sv": "timestamp"}
}
```

#### 2. **Achievements** (`/achievements/{userId}/{achievementId}`)
```json
{
  "unlockedAt": 1705353600,
  "timestamp": {".sv": "timestamp"}
}
```

#### 3. **Sessions d'Étude** (`/studySessions/{userId}/{sessionId}`)
```json
{
  "duration": 600,
  "xpGained": 150,
  "activityType": "quiz_vocabulary",
  "timestamp": {".sv": "timestamp"},
  "date": "2026-01-15T20:00:00Z"
}
```

#### 4. **Résultats de Quiz** (`/quizResults/{userId}/{resultId}`)
```json
{
  "quizType": "vocabulary",
  "score": 8,
  "totalQuestions": 10,
  "difficulty": "intermediate",
  "percentage": 80,
  "timestamp": {".sv": "timestamp"},
  "date": "2026-01-15T20:00:00Z"
}
```

#### 5. **Items de Révision SRS** (`/reviewItems/{userId}/{itemId}`)
```json
{
  "itemType": "vocabulary",
  "easeFactor": 2.5,
  "interval": 14,
  "nextReviewDate": 1705353600,
  "reviewCount": 5,
  "lastUpdated": {".sv": "timestamp"}
}
```

#### 6. **Progression Vocabulaire** (`/vocabulary/{userId}/{wordId}`)
```json
{
  "isLearned": true,
  "reviewCount": 3,
  "lastReviewDate": 1705353600,
  "lastUpdated": {".sv": "timestamp"}
}
```

#### 7. **Paramètres Utilisateur** (`/userSettings/{userId}`)
```json
{
  "notificationsEnabled": true,
  "dailyGoal": 5,
  "studyReminder": "20:00",
  "theme": "system",
  "language": "it"
}
```

#### 8. **Classement** (`/leaderboard/{userId}`)
```json
{
  "username": "User123",
  "totalXP": 3500,
  "level": "B1",
  "streak": 15,
  "lastUpdated": {".sv": "timestamp"}
}
```

---

## 🏗️ Architecture

### Services

#### **FirebaseSyncService**
Service principal de synchronisation cloud.

**Localisation:** `Services/FirebaseSyncService.swift`

**Fonctionnalités:**
- ✅ Synchronisation temps réel (Real-time observers)
- ✅ Upload/Download progression utilisateur
- ✅ Sync achievements
- ✅ Log sessions d'étude
- ✅ Sync résultats quiz
- ✅ Sync items de révision SRS
- ✅ Sync vocabulaire appris
- ✅ Gestion du classement
- ✅ Merge intelligent des données
- ✅ Détection de connexion

**Méthodes Principales:**

```swift
// Synchronisation progression
func syncUserProgress(_ progress: UserProgress) async throws
func fetchUserProgress() async throws -> UserProgress?

// Achievements
func syncAchievement(_ achievementId: String, unlockedAt: Date) async throws
func fetchAchievements() async throws -> [String: Date]

// Sessions d'étude
func logStudySession(duration: Int, xpGained: Int, activityType: String) async throws
func fetchStudySessions(limit: Int) async throws -> [[String: Any]]

// Quiz
func syncQuizResult(quizType: String, score: Int, totalQuestions: Int, difficulty: String) async throws

// SRS
func syncReviewItem(itemId: String, itemType: String, easeFactor: Double, interval: Int, nextReviewDate: Date, reviewCount: Int) async throws
func fetchReviewItems() async throws -> [[String: Any]]

// Vocabulaire
func syncVocabularyWord(wordId: String, isLearned: Bool, reviewCount: Int, lastReviewDate: Date) async throws

// Paramètres
func syncUserSettings(_ settings: [String: Any]) async throws
func fetchUserSettings() async throws -> [String: Any]?

// Classement
func updateLeaderboard(username: String, totalXP: Int, level: String, streak: Int) async throws
func fetchLeaderboard(limit: Int) async throws -> [[String: Any]]

// Sync complète
func performFullSync(progress: UserProgress) async throws

// Connexion
func checkConnection() async -> Bool
```

#### **GamificationManager** (Modifié)
Intégration de la synchronisation automatique.

**Modifications:**
```swift
// Ajout du service sync
private let syncService = FirebaseSyncService.shared

// Init avec sync automatique
init(modelContext: ModelContext) {
    self.modelContext = modelContext
    loadOrCreateProgress()
    loadAchievements()
    Task {
        await syncFromCloud()  // 🆕 Sync au démarrage
    }
}

// Auto-sync lors des mises à jour
func updateStreak() {
    currentProgress?.checkAndUpdateStreak()
    checkAchievements()
    try? modelContext.save()
    Task {
        await syncToCloud()  // 🆕 Sync automatique
    }
}

// Méthodes de sync
func syncFromCloud() async
func syncToCloud() async
func performFullSync() async
private func mergeProgress(remote: UserProgress, local: UserProgress)
```

---

## 🔄 Flux de Synchronisation

### 1. **Au Démarrage de l'App**

```
App Launch
    ↓
FirebaseManager.shared init
    ↓
Auth State Listener activated
    ↓
GamificationManager init
    ↓
syncFromCloud()
    ├─ fetchUserProgress()
    ├─ Merge avec données locales
    ├─ fetchAchievements()
    └─ Update UI
```

### 2. **Lors d'une Action Utilisateur**

```
User Action (Quiz, Exercise, etc.)
    ↓
GamificationManager.awardXP()
    ↓
Local SwiftData Save
    ↓
syncToCloud()
    ├─ syncUserProgress()
    ├─ syncAchievement() (si nouveau)
    ├─ logStudySession()
    └─ updateLeaderboard()
```

### 3. **Synchronisation Temps Réel**

```
Remote Data Change (autre appareil)
    ↓
Firebase Observer triggered
    ↓
handleRemoteUpdate()
    ↓
Merge avec données locales
    ↓
Update UI
```

### 4. **Résolution de Conflits**

**Stratégie: Last-Write-Wins avec Merge Intelligent**

```swift
private func mergeProgress(remote: UserProgress, local: UserProgress) {
    // Prendre les maximums pour les compteurs
    local.currentXP = max(local.currentXP, remote.currentXP)
    local.totalXP = max(local.totalXP, remote.totalXP)
    local.wordsLearned = max(local.wordsLearned, remote.wordsLearned)
    local.longestStreak = max(local.longestStreak, remote.longestStreak)
    
    // Prendre le niveau le plus élevé
    if remoteLevel.xpThreshold > local.level.xpThreshold {
        local.level = remoteLevel
    }
    
    // Merger les achievements (union)
    for achievementId in remote.achievementsUnlocked {
        if !local.achievementsUnlocked.contains(achievementId) {
            local.achievementsUnlocked.append(achievementId)
        }
    }
}
```

---

## 🎨 Interface Utilisateur

### Composants UI Créés

#### **FirebaseSyncStatusView**
Badge affichant l'état de synchronisation.

```swift
struct FirebaseSyncStatusView: View {
    @ObservedObject var syncService: FirebaseSyncService
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    var body: some View {
        HStack {
            if syncService.isSyncing {
                ProgressView()
                Text("☁️ Synchronisation...")
            } else if let lastSync = syncService.lastSyncDate {
                Image(systemName: "checkmark.icloud.fill")
                Text("Synchronisé \(lastSync.relativeDescription)")
            }
        }
    }
}
```

**Utilisation:**
```swift
// Dans HomeView ou ProfileView
FirebaseSyncStatusView(syncService: FirebaseSyncService.shared)
    .environmentObject(FirebaseManager.shared)
```

#### **CloudSyncBadge**
Badge compact pour la barre de navigation.

```swift
struct CloudSyncBadge: View {
    @ObservedObject var syncService: FirebaseSyncService
    
    var body: some View {
        HStack(spacing: 4) {
            if syncService.isSyncing {
                ProgressView()
            } else if syncService.lastSyncDate != nil {
                Image(systemName: "checkmark.icloud.fill")
                    .foregroundColor(.green)
            }
        }
    }
}
```

#### **SyncSettingsView**
Vue complète des paramètres de synchronisation.

**Fonctionnalités:**
- État de connexion
- Dernière synchronisation
- Bouton "Synchroniser maintenant"
- Détails de synchronisation

#### **SyncDetailsView**
Modal avec détails complets de la synchronisation.

**Affiche:**
- ✅ Statut actuel
- ✅ Dernière sync timestamp
- ✅ Erreurs éventuelles
- ✅ Liste des données synchronisées
- ✅ Informations sur le cloud

---

## 🔐 Sécurité & Règles Firebase

### Règles Realtime Database

```json
{
  "rules": {
    "userProgress": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid",
        ".validate": "newData.hasChildren(['currentXP', 'totalXP', 'level'])"
      }
    },
    "achievements": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "studySessions": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "quizResults": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "reviewItems": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "vocabulary": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "userSettings": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "leaderboard": {
      ".read": true,
      "$uid": {
        ".write": "$uid === auth.uid",
        ".validate": "newData.hasChildren(['username', 'totalXP', 'level'])"
      }
    }
  }
}
```

### Authentification

**Méthodes Supportées:**
- ✅ Sign In with Apple
- ✅ Email/Password
- ✅ Anonyme (pour tester)

**FirebaseManager** gère l'authentification:
```swift
// Sign In with Apple
func signInWithApple(idToken: String, nonce: String) async throws

// Email/Password
func signInWithEmail(email: String, password: String) async throws
func createAccount(email: String, password: String) async throws

// Anonyme
func signInAnonymously() async throws

// Sign Out
func signOut() throws
```

---

## 📊 Monitoring & Analytics

### Logs de Synchronisation

Tous les événements sont loggés avec des emojis pour faciliter le debugging:

```
✅ Firebase Sync: User progress uploaded
📥 Firebase Sync: User progress downloaded
🔄 Firebase Sync: Starting full sync...
✅ Sync: Merged remote progress
❌ Sync: Failed to sync - [error]
📊 Firebase Sync: 42 study sessions downloaded
🎯 Firebase Sync: Achievement first_word synced
```

### Métriques à Tracker

```swift
// Dans AdvancedAnalyticsService
struct SyncMetrics {
    let successfulSyncs: Int
    let failedSyncs: Int
    let averageSyncTime: TimeInterval
    let lastSyncDate: Date?
    let totalDataSynced: Int  // en bytes
}
```

---

## 🚀 Utilisation

### 1. **Configuration (Déjà fait)**

Firebase est configuré dans `onykrouaApp.swift`:
```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(...) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
```

### 2. **Synchronisation Automatique**

La synchronisation est automatique dès qu'un utilisateur est authentifié:

```swift
// Dans n'importe quelle vue
@EnvironmentObject var firebaseManager: FirebaseManager

var body: some View {
    if firebaseManager.isSignedIn {
        // L'utilisateur est connecté
        // La synchronisation est active
    }
}
```

### 3. **Synchronisation Manuelle**

```swift
// Récupérer le GamificationManager
let gamificationManager = GamificationManager(modelContext: modelContext)

// Sync complète
Task {
    await gamificationManager.performFullSync()
}
```

### 4. **Afficher le Statut**

```swift
// Dans HomeView
VStack {
    // Contenu...
    
    FirebaseSyncStatusView(syncService: FirebaseSyncService.shared)
        .environmentObject(FirebaseManager.shared)
}
```

### 5. **Settings**

```swift
// Dans SettingsView
SyncSettingsView(syncService: FirebaseSyncService.shared)
    .environmentObject(FirebaseManager.shared)
```

---

## 🧪 Tests

### Test de Synchronisation

```swift
// 1. Créer un compte test
let firebaseManager = FirebaseManager.shared
try await firebaseManager.signInAnonymously()

// 2. Ajouter des données locales
let gamificationManager = GamificationManager(modelContext: context)
gamificationManager.awardXP(100, for: "test")
gamificationManager.recordWordLearned()

// 3. Sync vers le cloud
await gamificationManager.syncToCloud()

// 4. Vérifier dans Firebase Console
// https://console.firebase.google.com/project/onikroua/database

// 5. Effacer données locales et re-sync
await gamificationManager.syncFromCloud()

// 6. Vérifier que les données sont restaurées
print(gamificationManager.currentProgress?.currentXP) // Should be 100
```

### Test Multi-Appareils

```
Appareil A:
1. Se connecter avec le même compte
2. Gagner 100 XP
3. Attendre sync (2-3 secondes)

Appareil B:
1. Se connecter avec le même compte
2. Vérifier que les 100 XP apparaissent
3. Gagner 50 XP supplémentaires
4. Attendre sync

Appareil A:
5. Vérifier que les 150 XP totaux apparaissent
```

---

## 🐛 Troubleshooting

### Problème: Sync ne fonctionne pas

**Solutions:**
1. Vérifier que l'utilisateur est authentifié:
   ```swift
   print(FirebaseManager.shared.isSignedIn)
   ```

2. Vérifier la connexion réseau:
   ```swift
   let connected = await FirebaseSyncService.shared.checkConnection()
   print("Connected: \(connected)")
   ```

3. Vérifier les règles Firebase:
   - Console Firebase → Realtime Database → Rules
   - Tester avec règles publiques temporairement (UNSAFE):
     ```json
     {".read": true, ".write": true}
     ```

4. Vérifier les logs Xcode:
   ```
   ✅/❌ Firebase Sync: [message]
   ```

### Problème: Données en double

**Cause:** Conflit de synchronisation

**Solution:** Le merge intelligent devrait gérer ça, mais si nécessaire:
```swift
// Forcer une sync complète
await gamificationManager.syncFromCloud()
```

### Problème: Sync lente

**Optimisations:**
1. Limiter la fréquence de sync (debounce):
   ```swift
   private var syncTask: Task<Void, Never>?
   
   func debouncedSync() {
       syncTask?.cancel()
       syncTask = Task {
           try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 sec
           await syncToCloud()
       }
   }
   ```

2. Sync uniquement les changements (delta sync)

3. Utiliser transactions Firebase pour les updates atomiques

---

## 📈 Améliorations Futures

### Phase 2: Optimisations
- [ ] Delta sync (uniquement les changements)
- [ ] Compression des données
- [ ] Cache local plus intelligent
- [ ] Sync en arrière-plan
- [ ] Retry automatique avec exponential backoff

### Phase 3: Fonctionnalités Sociales
- [ ] Partage de progression avec amis
- [ ] Classements en temps réel
- [ ] Défis entre utilisateurs
- [ ] Messages de motivation

### Phase 4: Analytics Avancés
- [ ] Heatmap d'étude
- [ ] Prédictions ML de performance
- [ ] Recommandations personnalisées cloud
- [ ] A/B testing des features

---

## 📚 Ressources

### Documentation Firebase
- [Realtime Database Guide](https://firebase.google.com/docs/database)
- [Security Rules](https://firebase.google.com/docs/database/security)
- [iOS SDK Reference](https://firebase.google.com/docs/reference/swift/firebasedatabase/api/reference/Classes)

### Console Firebase
- **Project:** onikroua
- **Database URL:** `https://onikroua-default-rtdb.europe-west1.firebasedatabase.app`
- **Console:** https://console.firebase.google.com/project/onikroua

### Fichiers Modifiés
1. ✅ `Services/FirebaseSyncService.swift` (NOUVEAU - 500+ lignes)
2. ✅ `Services/GamificationManager.swift` (+100 lignes)
3. ✅ `Views/Components/FirebaseSyncStatusView.swift` (NOUVEAU - 300+ lignes)
4. ✅ `onykrouaApp.swift` (déjà configuré)

---

## ✅ Checklist d'Intégration

- [x] Firebase SDK ajouté au projet
- [x] GoogleService-Info.plist configuré
- [x] FirebaseManager créé et fonctionnel
- [x] FirebaseSyncService implémenté
- [x] GamificationManager modifié avec auto-sync
- [x] Composants UI créés (SyncStatusView, etc.)
- [x] Règles de sécurité définies
- [x] Documentation complète

**L'intégration Firebase Realtime Database est complète et opérationnelle !** 🎉🔥

---

**Dernière mise à jour:** 15 janvier 2026  
**Version:** 1.0.0
