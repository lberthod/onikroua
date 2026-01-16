# Cloud Sync Strategy - Onykroua iOS

## Overview

This document describes the **cloud-authoritative** synchronization strategy for the Onykroua iOS app. The Firebase Realtime Database (RTDB) is the single source of truth, with local SwiftData acting as a performance cache.

---

## Architecture Principles

### 1. Cloud as Single Source of Truth

- **RTDB** contains the canonical state of all user data
- **SwiftData** is a local cache for fast reads and offline support
- After any sync, local state converges to cloud state
- `updatedAt` timestamp (Int64 milliseconds) resolves conflicts

### 2. Three-Layer Architecture

```
┌─────────────────┐
│  Views (SwiftUI) │  ← Never touch Firebase directly
└────────┬─────────┘
         │
         ▼
┌─────────────────────┐
│   Repositories      │  ← Business logic, data access
│ (Progress, Vocab,   │
│  Achievement)       │
└────────┬────────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌─────────┐  ┌──────────────┐
│SwiftData│  │CloudSyncEngine│
│ (Cache) │  │  + Firebase   │
└─────────┘  └──────────────┘
```

**Views** → call **Repositories** → update **SwiftData cache** + push to **Cloud** (via outbox if offline)

### 3. Sync Flows

#### A. Bootstrap (First Load / Login)

1. User signs in
2. `CloudSyncEngine.bootstrap()` triggered
3. Check if cloud data exists:
   - **No cloud data** → Initialize new user in cloud with seed data
   - **Has cloud data** → Fetch all user data from cloud
4. Populate SwiftData cache with cloud data
5. Cloud wins if there's any local-cloud discrepancy
6. Setup real-time observers for live updates

#### B. Real-time Pull (Cloud → Local)

Firebase observers listen to:
- `/users/{uid}/progress`
- `/users/{uid}/vocab` (per-word changes)
- `/users/{uid}/achievements`
- `/users/{uid}/sessions` (new sessions)

When cloud changes:
1. Receive snapshot from Firebase
2. Parse into DTO
3. Check local cache
4. If `remote.updatedAt >= local.updatedAt` → Update local cache
5. Else → Skip (local is newer)

#### C. Optimistic Push (Local → Cloud)

User performs action (e.g., mark word as known):
1. Repository receives request
2. **Optimistic write** to SwiftData (instant UI update)
3. Push to Firebase:
   - **Online** → Direct write succeeds
   - **Offline** → Write fails, enqueue in `SyncOutboxItem`
4. Background task retries failed writes

---

## Conflict Resolution

### Primary Rule: Latest Timestamp Wins

```swift
if remote.updatedAt >= local.updatedAt {
    // Cloud wins - overwrite local
    local.updateFrom(dto: remote)
} else {
    // Local wins - push to cloud on next sync
    pushToCloud(local)
}
```

### Special Cases

#### Progress (Cumulative Fields)

For fields like `xp`, `wordsLearned`, consider **max** value if both devices were offline:

```swift
let finalXP = max(localProgress.xp, remoteProgress.xp)
```

**However**, primary strategy is timestamp-based. Cumulative merging is optional enhancement.

#### Sessions (Append-Only)

- Sessions use Firebase push IDs → natural append-only
- No conflicts expected
- Duplicates prevented by checking `sessionId` before insert

#### Vocab Words (Per-Word Resolution)

- Each word has independent `updatedAt`
- Word A conflict doesn't affect Word B
- Status transitions (`new` → `learning` → `known`) tracked per word

---

## Offline Queue (Outbox)

### SyncOutboxItem

Persistent queue for failed writes:

```swift
@Model
final class SyncOutboxItem {
    var id: String
    var userId: String
    var path: String          // e.g., "users/{uid}/vocab/bonjour"
    var payloadJSON: String
    var attempts: Int
    var lastError: String?
    var createdAt: Int64
}
```

### Retry Strategy

- **Backoff**: Exponential (2s, 5s, 15s, 60s)
- **Max Attempts**: 10
- **Flush Triggers**:
  - Network reconnection
  - App foreground
  - Manual flush (debug screen)

### Failure Handling

After 10 failed attempts:
- Keep item in outbox (don't delete)
- Mark for manual review
- Display warning in debug screen

---

## Data Isolation

### User Data Scoping

All user data is under `/users/{uid}/`:
- RTDB security rules enforce read/write only on own UID
- SwiftData cache always filtered by `userId`
- Logout clears local cache (optional) or just stops observers

### Multi-Device Scenarios

**Scenario**: User A uses iPhone and iPad simultaneously

1. iPhone marks word "bonjour" as known
2. iPhone pushes to cloud with `updatedAt: T1`
3. Cloud real-time update triggers
4. iPad receives update via observer
5. iPad's local cache updated (cloud wins if `T1 > iPad.updatedAt`)
6. Both devices converge to same state

**Scenario**: User A logs out, User B logs in on same device

1. User A logout → Remove observers, optionally clear cache
2. User B login → Bootstrap from cloud with User B's UID
3. No User A data visible to User B (enforced by RTDB rules + cache filtering)

---

## Implementation Components

### 1. DTOs (Data Transfer Objects)

Located in `Models/CloudSync/FirebaseDTOs.swift`:
- `UserMetaDTO`
- `UserProgressDTO`
- `VocabWordDTO`
- `AchievementDTO`
- `SessionDTO`
- `LeaderboardEntryDTO`

Pure data structures, no business logic. Codable for easy serialization.

### 2. SwiftData Cache Models

Located in `Models/CloudSync/CacheModels.swift`:
- `CachedUserProgress`
- `CachedVocabWord`
- `CachedAchievement`
- `CachedSession`
- `SyncOutboxItem`
- `SyncMetadata`

All include:
- `userId` for isolation
- `updatedAt` for conflict resolution
- `lastSyncAt` for diagnostics
- `toDTO()` and `updateFrom(dto:)` methods

### 3. CloudSyncEngine

Located in `Services/CloudSync/CloudSyncEngine.swift`:

**Responsibilities**:
- Bootstrap on login
- Setup/teardown Firebase observers
- Handle incoming cloud updates
- Merge cloud data into local cache
- Flush outbox queue

**Does NOT**:
- Handle business logic (that's in Repositories)
- Expose data to Views (that's via Repositories)

### 4. Repositories

Located in `Services/CloudSync/`:
- `ProgressRepository`: XP, levels, streaks, session tracking
- `VocabRepository`: Word status, reviews, strength
- `AchievementRepository`: Unlock, progress tracking

**Responsibilities**:
- Business logic (e.g., "mark word as known" → update status + strength)
- Optimistic local writes
- Push to cloud (direct or via outbox)
- Provide clean API for Views

### 5. RTDB Security Rules

Located in `database.rules.json`:

- User can only read/write `/users/{uid}` where `uid === auth.uid`
- Leaderboard: read all, write only own entry
- Field validation (types, ranges, required fields)
- `updatedAt` required on all writes

---

## Testing Strategy

### Unit Tests (Recommended)

- DTO serialization/deserialization
- Conflict resolution logic
- Outbox retry mechanism
- Cache update logic

### Integration Tests

See **TEST_CHECKLIST.md** for acceptance tests.

---

## Observability

### Debug Screen

Located in `Views/Debug/SyncDebugView.swift`:

**Features**:
- View sync status (last sync, errors)
- Local cache stats (vocab count, progress, etc.)
- Outbox queue size
- Force reload from cloud
- Manual flush outbox
- Timestamps for diagnostics

**Access**: Add to debug menu or dev builds only

### Logging

All sync operations log with prefixes:
- `🔄 CloudSync:` - General sync operations
- `📥 CloudSync:` - Incoming updates from cloud
- `✅ CloudSync:` - Successful operations
- `❌ CloudSync:` - Errors
- `⚠️ CloudSync:` - Warnings (e.g., outbox enqueue)

Enable verbose logging in dev builds.

---

## Migration Path

### From Old FirebaseSyncService

1. Keep old `FirebaseSyncService` for backward compatibility during transition
2. Gradually migrate Views to use new Repositories
3. Once all Views migrated, deprecate old service
4. New users automatically use new system (bootstrap)

### Schema Versioning

- Current schema version: **1**
- Stored in `/users/{uid}/meta/schemaVersion`
- Future migrations check version and apply transformations

---

## Performance Considerations

### Read Performance

- **Local cache first**: Views read from SwiftData (fast, synchronous)
- **No blocking on sync**: Sync happens in background
- **Pagination**: Large datasets (sessions) fetched with limits

### Write Performance

- **Optimistic updates**: UI reflects changes immediately
- **Async cloud push**: Network operations don't block UI
- **Batching**: Consider batching multiple writes if needed

### Network Efficiency

- **Real-time observers**: Only changed nodes trigger updates (not full fetch)
- **Targeted writes**: Only changed fields updated (though we update full nodes for simplicity)
- **Outbox coalescing**: Could merge multiple updates to same path (future enhancement)

---

## Error Handling

### Network Errors

- Caught during cloud push
- Item added to outbox
- Retry on reconnection
- User sees optimistic update (no interruption)

### Authentication Errors

- Bootstrap aborted
- Observers removed
- User prompted to re-authenticate

### Data Corruption

- Invalid DTO from cloud → Log error, skip update
- Invalid cache model → Bootstrap reload
- Last resort: Clear cache, full reload from cloud

---

## Future Enhancements

1. **Batch Operations**: Group multiple writes into single transaction
2. **Partial Sync**: Only sync changed data since last sync
3. **Conflict UI**: Show user when conflicts detected, let them choose
4. **Cloud Functions**: Server-side leaderboard updates, validation
5. **Offline Indicators**: Show badge when writes are queued
6. **Smart Merging**: Cumulative field merging (max XP, combined streak logic)

---

## Summary

✅ **Cloud is always right**: RTDB wins conflicts  
✅ **Offline works**: Writes queued, synced later  
✅ **Multi-device safe**: Real-time updates, timestamp resolution  
✅ **Secure**: RTDB rules enforce isolation  
✅ **Fast UX**: Optimistic updates, local cache reads  
✅ **Observable**: Debug screen + structured logging  

This strategy ensures data consistency, resilience, and a smooth user experience across all scenarios.
