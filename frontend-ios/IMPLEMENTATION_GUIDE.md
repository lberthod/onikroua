# Cloud Sync Implementation Guide

## Overview

This guide shows how to use the new cloud-authoritative sync system in your SwiftUI Views.

---

## Quick Start

### 1. Accessing Repositories

Repositories should be injected into your Views via `@StateObject` or passed through the environment.

```swift
struct VocabularyView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vocabRepo: VocabRepository
    @StateObject private var progressRepo: ProgressRepository
    
    init(container: ModelContainer) {
        _vocabRepo = StateObject(wrappedValue: VocabRepository(container: container))
        _progressRepo = StateObject(wrappedValue: ProgressRepository(container: container))
    }
    
    var body: some View {
        // Your UI here
    }
}
```

### 2. Reading Data (from Cache)

Always read from local cache for fast, synchronous access:

```swift
// Get user progress
if let progress = progressRepo.getProgress() {
    Text("XP: \(progress.xp)")
    Text("Level: \(progress.level)")
    Text("Streak: \(progress.streakDays) days")
}

// Get vocabulary words
let knownWords = vocabRepo.getWordsByStatus("known")
let learningWords = vocabRepo.getWordsByStatus("learning")

Text("Known: \(knownWords.count)")
Text("Learning: \(learningWords.count)")
```

### 3. Writing Data (Optimistic Update + Cloud Sync)

All writes go through repositories, which handle local cache + cloud sync:

```swift
Button("Mark as Known") {
    Task {
        do {
            try await vocabRepo.markWordAsKnown(wordId: "greetings_bonjour")
            try await progressRepo.recordWordLearned()
            try await progressRepo.addXP(10)
            
            // UI updates immediately (optimistic)
            // Cloud sync happens in background
            
        } catch {
            print("Error: \(error)")
            // Handle error (show alert, etc.)
        }
    }
}
```

---

## Common Use Cases

### Use Case 1: Vocabulary Quiz

```swift
struct VocabularyQuizView: View {
    @StateObject private var vocabRepo: VocabRepository
    @StateObject private var progressRepo: ProgressRepository
    
    @State private var currentWord: VocabWord
    @State private var score: Int = 0
    @State private var total: Int = 0
    
    func submitAnswer(correct: Bool) {
        Task {
            do {
                // Record review
                try await vocabRepo.recordReview(
                    wordId: safeFirebaseKey(currentWord.word),
                    correct: correct
                )
                
                if correct {
                    score += 1
                    try await progressRepo.addXP(10)
                }
                
                total += 1
                
                // Move to next word
                loadNextWord()
                
            } catch {
                print("Error recording review: \(error)")
            }
        }
    }
}
```

### Use Case 2: Complete Study Session

```swift
func completeSession() {
    Task {
        do {
            let sessionXP = calculateSessionXP()
            let itemsCount = wordsStudied.count
            let correctCount = wordsStudied.filter { $0.correct }.count
            let duration = Int(Date().timeIntervalSince(sessionStartTime))
            
            try await progressRepo.recordSessionCompleted(
                xpGained: sessionXP,
                activityType: "vocabulary",
                itemsCount: itemsCount,
                correctCount: correctCount,
                durationSeconds: duration
            )
            
            // Session automatically synced to cloud
            // UI can navigate to results screen
            
        } catch {
            print("Error completing session: \(error)")
        }
    }
}
```

### Use Case 3: Check and Unlock Achievements

```swift
func checkAchievements() {
    Task {
        guard let progress = progressRepo.getProgress() else { return }
        
        let achievementRepo = AchievementRepository(container: modelContainer)
        await achievementRepo.checkAndUnlockAchievements(
            progress: progress,
            vocabRepo: vocabRepo
        )
        
        // Achievements auto-unlock if criteria met
        // Real-time sync to cloud happens automatically
    }
}
```

### Use Case 4: Display User Stats

```swift
struct StatsView: View {
    @StateObject private var progressRepo: ProgressRepository
    @StateObject private var vocabRepo: VocabRepository
    
    var body: some View {
        List {
            if let progress = progressRepo.getProgress() {
                Section("Overall Progress") {
                    StatRow(label: "Total XP", value: "\(progress.xp)")
                    StatRow(label: "Level", value: "\(progress.level)")
                    StatRow(label: "Streak", value: "\(progress.streakDays) days")
                    StatRow(label: "Longest Streak", value: "\(progress.longestStreak) days")
                }
                
                Section("Learning Stats") {
                    StatRow(label: "Words Learned", value: "\(progress.wordsLearned)")
                    StatRow(label: "Words Reviewed", value: "\(progress.wordsReviewed)")
                    StatRow(label: "Lessons Completed", value: "\(progress.lessonsCompleted)")
                }
            }
            
            Section("Vocabulary") {
                StatRow(label: "Known Words", value: "\(vocabRepo.getKnownWordsCount())")
                StatRow(label: "Learning Words", value: "\(vocabRepo.getLearningWordsCount())")
            }
        }
    }
}
```

---

## Handling Offline Mode

The sync system automatically handles offline mode:

1. **User Action** → Repository called
2. **Local Cache** → Updated immediately (optimistic UI)
3. **Cloud Write** → Attempted
   - **Success** → Done
   - **Failure** → Enqueued in `SyncOutboxItem`
4. **On Reconnection** → Outbox auto-flushes

### Showing Offline Indicator (Optional)

```swift
struct ContentView: View {
    @StateObject private var syncEngine = CloudSyncEngine.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        VStack {
            if !networkMonitor.isConnected {
                HStack {
                    Image(systemName: "wifi.slash")
                    Text("Offline - Changes will sync when connected")
                }
                .padding()
                .background(Color.orange.opacity(0.2))
            }
            
            // Your main content
        }
    }
}
```

---

## Error Handling

### Repository Errors

```swift
do {
    try await vocabRepo.markWordAsKnown(wordId: wordId)
} catch RepositoryError.userNotAuthenticated {
    // Show login screen
    showAuthView = true
} catch RepositoryError.dataNotFound {
    // Data not in cache - might need to bootstrap
    showErrorAlert("Data not found. Try refreshing.")
} catch RepositoryError.syncFailed(let message) {
    // Sync issue - data is saved locally, will retry
    showErrorAlert("Sync pending: \(message)")
} catch {
    // Unknown error
    showErrorAlert("An error occurred: \(error.localizedDescription)")
}
```

### Sync Errors

Monitor `CloudSyncEngine.shared.syncError` for global sync issues:

```swift
.onAppear {
    if let error = CloudSyncEngine.shared.syncError {
        showAlert("Sync Error", message: error)
    }
}
```

---

## Best Practices

### ✅ DO

1. **Always read from cache** (Repositories provide cached data)
2. **Use async/await** for all write operations
3. **Handle errors gracefully** (data is still saved locally)
4. **Use safe Firebase keys** via `safeFirebaseKey()` helper
5. **Let the system handle sync** (don't manually trigger unless debugging)

### ❌ DON'T

1. **Don't call Firebase directly from Views** (use Repositories)
2. **Don't block UI on sync operations** (they're async)
3. **Don't manually manage SwiftData cache** (Repositories handle it)
4. **Don't assume immediate cloud availability** (could be offline)
5. **Don't create multiple ModelContainer instances** (use shared one)

---

## Integration with Existing Code

### Migrating from Old FirebaseSyncService

**Old Code:**
```swift
try await FirebaseSyncService.shared.syncVocabularyWord(
    wordId: wordId,
    status: "known",
    reviewCount: 5,
    lastReviewDate: Date()
)
```

**New Code:**
```swift
try await vocabRepo.markWordAsKnown(wordId: wordId)
// Review count and timestamps handled automatically
```

### Adapting UserProgress Model

The old `UserProgress` SwiftData model is still used for UI logic. The new `CachedUserProgress` is internal to the sync system.

**Migration Helper:**
```swift
extension CachedUserProgress {
    func toUIModel() -> UserProgress {
        let progress = UserProgress()
        progress.totalXP = self.xp
        progress.currentLevel = "Level \(self.level)"
        progress.streak = self.streakDays
        progress.longestStreak = self.longestStreak
        progress.wordsLearned = self.wordsLearned
        // ... map other fields
        return progress
    }
}
```

---

## Testing Your Integration

### 1. Unit Test Example

```swift
@MainActor
class VocabRepositoryTests: XCTestCase {
    var container: ModelContainer!
    var repo: VocabRepository!
    
    override func setUp() async throws {
        container = try ModelContainer(
            for: CachedVocabWord.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        repo = VocabRepository(container: container)
    }
    
    func testMarkWordAsKnown() async throws {
        try await repo.markWordAsKnown(wordId: "test_word")
        
        let word = repo.getVocabWord(wordId: "test_word")
        XCTAssertEqual(word?.status, "known")
        XCTAssertEqual(word?.strength, 100)
    }
}
```

### 2. UI Test Example

```swift
func testOfflineVocabUpdate() throws {
    let app = XCUIApplication()
    app.launch()
    
    // Enable airplane mode (requires manual setup)
    // Mark word as known
    app.buttons["markKnownButton"].tap()
    
    // Verify word shows as known (optimistic update)
    XCTAssertTrue(app.staticTexts["Known"].exists)
    
    // Disable airplane mode
    // Wait for sync
    sleep(5)
    
    // Verify sync completed
    XCTAssertEqual(getCloudWordStatus(wordId: "test"), "known")
}
```

---

## Debugging

### Enable Verbose Logging

Add to AppDelegate or early in app lifecycle:

```swift
UserDefaults.standard.set(true, forKey: "enableVerboseSyncLogging")
```

Then check console for:
- `🔄 CloudSync:` - Sync operations
- `📥 CloudSync:` - Cloud → Local updates
- `✅ CloudSync:` - Successful operations
- `❌ CloudSync:` - Errors
- `⚠️ CloudSync:` - Warnings

### Access Debug Screen

Add to your settings or debug menu:

```swift
NavigationLink("Sync Debug") {
    SyncDebugView()
}
```

### Manual Operations

```swift
// Force reload from cloud
Task {
    guard let userId = Auth.auth().currentUser?.uid else { return }
    await CloudSyncEngine.shared.bootstrap(userId: userId)
}

// Flush outbox manually
Task {
    await CloudSyncEngine.shared.flushOutbox()
}
```

---

## Performance Tips

### Batch Operations (Future Enhancement)

Currently each write is individual. For bulk operations:

```swift
// Instead of:
for word in words {
    try await vocabRepo.markWordAsKnown(wordId: word.id)
}

// Consider collecting updates and doing a batch write
// (Requires custom implementation)
```

### Pagination for Large Datasets

```swift
// Fetch sessions with limit
let descriptor = FetchDescriptor<CachedSession>(
    predicate: #Predicate { $0.userId == userId },
    sortBy: [SortDescriptor(\CachedSession.startedAt, order: .reverse)]
)
descriptor.fetchLimit = 20

let recentSessions = try context.fetch(descriptor)
```

---

## Security Notes

1. **RTDB Rules Deployed**: Ensure `database.rules.json` is deployed to Firebase
2. **User Isolation**: All data scoped to `/users/{uid}/`
3. **No Client-Side Validation Bypass**: Server rules validate all writes
4. **Sensitive Data**: Don't store PII in RTDB without encryption
5. **API Keys**: Keep Firebase config secure (use `.gitignore`)

---

## Troubleshooting

### Issue: Data Not Syncing

**Check:**
1. User is authenticated (`Auth.auth().currentUser != nil`)
2. Network connectivity
3. Outbox count in debug screen (items queued?)
4. Firebase Console for write errors
5. RTDB rules deployed correctly

### Issue: Conflicts Not Resolving

**Check:**
1. Both devices online and connected
2. Timestamps being set correctly (`Date().toMilliseconds()`)
3. Observers setup correctly (check logs)
4. No infinite loop in conflict logic

### Issue: Bootstrap Fails

**Check:**
1. User has valid auth token
2. RTDB rules allow read access
3. Network connection stable
4. No corrupted data in cloud

---

## Next Steps

1. **Deploy RTDB Rules**: `firebase deploy --only database`
2. **Test Multi-Device**: Use TEST_CHECKLIST.md
3. **Monitor Firebase Console**: Check data structure and usage
4. **Add UI Indicators**: Offline mode, sync status
5. **Performance Testing**: Measure sync times for large datasets
6. **Add Analytics**: Track sync success/failure rates

---

## Support

For issues or questions:
1. Check logs (search for `CloudSync:`)
2. Review SYNC_STRATEGY.md for architecture details
3. Use SyncDebugView for diagnostics
4. Check TEST_CHECKLIST.md for test scenarios

---

## Summary

The new sync system provides:
- ✅ Cloud-authoritative data
- ✅ Offline-first UX
- ✅ Multi-device sync
- ✅ Conflict resolution
- ✅ Clean architecture (Repositories)
- ✅ Observable sync state
- ✅ Secure by default

Use Repositories for all data access, trust the cache for reads, and let the system handle sync automatically.
