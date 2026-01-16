# Firebase Realtime Database Schema

## Overview

This document defines the canonical schema for the Onykroua app's Firebase Realtime Database (RTDB). The cloud is the **single source of truth** for all user data.

## Design Principles

1. **Cloud Authoritative**: RTDB is always the source of truth
2. **Timestamps**: All nodes include `updatedAt` (Int64 milliseconds since epoch)
3. **User Isolation**: Data scoped under `/users/{uid}/`
4. **Deterministic IDs**: Stable, predictable identifiers where possible
5. **Conflict Resolution**: `updatedAt` timestamp determines winner (latest wins)

## Schema Structure

### Root Paths

```
/users/{uid}/              # User-scoped data
/leaderboards/global/      # Global leaderboard
```

---

## User Data Structure

### `/users/{uid}/meta`

User metadata and account information.

```json
{
  "schemaVersion": 1,
  "createdAt": 1704067200000,
  "lastLoginAt": 1704153600000,
  "activeDeviceId": "iPhone_ABC123",
  "updatedAt": 1704153600000
}
```

**Fields:**
- `schemaVersion` (Int): Schema version for migrations (current: 1)
- `createdAt` (Int64): Account creation timestamp (ms)
- `lastLoginAt` (Int64): Most recent login timestamp (ms)
- `activeDeviceId` (String, optional): Last active device identifier
- `updatedAt` (Int64): Last modification timestamp (ms)

---

### `/users/{uid}/progress`

User's overall learning progress.

```json
{
  "level": 1,
  "xp": 350,
  "streakDays": 7,
  "longestStreak": 15,
  "lastStudyAt": 1704153600000,
  "wordsLearned": 42,
  "wordsReviewed": 120,
  "lessonsCompleted": 8,
  "quizzesCompleted": 5,
  "quizzesCorrect": 23,
  "conversationsCompleted": 3,
  "grammarRulesLearned": 6,
  "verbsLearned": 8,
  "studyTimeMinutes": 180,
  "sessionsCompleted": 12,
  "updatedAt": 1704153600000
}
```

**Fields:**
- `level` (Int): User's current level number
- `xp` (Int): Current experience points
- `streakDays` (Int): Current consecutive study days
- `longestStreak` (Int): Longest streak ever achieved
- `lastStudyAt` (Int64): Last study session timestamp (ms)
- `wordsLearned` (Int): Total words learned count
- `wordsReviewed` (Int): Total word reviews count
- `lessonsCompleted` (Int): Total lessons completed
- `quizzesCompleted` (Int): Total quizzes taken
- `quizzesCorrect` (Int): Total correct quiz answers
- `conversationsCompleted` (Int): Conversation exercises completed
- `grammarRulesLearned` (Int): Grammar rules mastered
- `verbsLearned` (Int): Verbs learned count
- `studyTimeMinutes` (Int): Total study time in minutes
- `sessionsCompleted` (Int): Total study sessions
- `updatedAt` (Int64): Last modification timestamp (ms)

---

### `/users/{uid}/vocab/{wordId}`

Individual vocabulary word progress.

**Word ID Format**: Sanitized stable identifier (e.g., `greetings_bonjour`, `food_pain`)
- Replace spaces with underscores
- Remove special characters: `.`, `$`, `#`, `[`, `]`, `/`
- Use lowercase

```json
{
  "status": "learning",
  "strength": 75,
  "lastSeenAt": 1704153600000,
  "reviewCount": 5,
  "correctCount": 4,
  "updatedAt": 1704153600000
}
```

**Fields:**
- `status` (String): One of: `"new"`, `"learning"`, `"known"`
- `strength` (Int): Mastery level 0-100
- `lastSeenAt` (Int64): Last review timestamp (ms)
- `reviewCount` (Int): Total number of reviews
- `correctCount` (Int): Number of correct reviews
- `updatedAt` (Int64): Last modification timestamp (ms)

**Status Transitions:**
- `new` → `learning`: First encounter
- `learning` → `known`: Strength reaches 100 or multiple correct reviews
- `known` → `learning`: Incorrect review (strength drops)

---

### `/users/{uid}/achievements/{achievementId}`

User's unlocked achievements.

**Achievement ID**: Stable enum-based identifier (e.g., `first_word`, `streak_7`, `words_100`)

```json
{
  "unlocked": true,
  "unlockedAt": 1704067200000,
  "progress": 100,
  "updatedAt": 1704067200000
}
```

**Fields:**
- `unlocked` (Bool): Whether achievement is unlocked
- `unlockedAt` (Int64): Unlock timestamp (ms), null if not unlocked
- `progress` (Int): Progress toward achievement (0-100)
- `updatedAt` (Int64): Last modification timestamp (ms)

---

### `/users/{uid}/sessions/{sessionId}`

Study session records.

**Session ID**: Firebase push ID for chronological ordering

```json
{
  "startedAt": 1704153000000,
  "endedAt": 1704153600000,
  "itemsCount": 15,
  "correctCount": 12,
  "xpGained": 45,
  "activityType": "vocabulary",
  "updatedAt": 1704153600000
}
```

**Fields:**
- `startedAt` (Int64): Session start timestamp (ms)
- `endedAt` (Int64): Session end timestamp (ms)
- `itemsCount` (Int): Number of items in session
- `correctCount` (Int): Number correct (if applicable)
- `xpGained` (Int): Experience points earned
- `activityType` (String): Type of activity (`"vocabulary"`, `"quiz"`, `"conversation"`, `"grammar"`)
- `updatedAt` (Int64): Last modification timestamp (ms)

---

### `/leaderboards/global/{uid}`

Global leaderboard entry per user.

```json
{
  "xp": 2450,
  "level": 5,
  "username": "User123",
  "updatedAt": 1704153600000
}
```

**Fields:**
- `xp` (Int): User's total XP for ranking
- `level` (Int): User's current level
- `username` (String): Display name
- `updatedAt` (Int64): Last modification timestamp (ms)

**Access Control**: Users can only write their own UID entry

---

## Timestamp Format

All timestamps use **Int64 milliseconds since Unix epoch** (January 1, 1970 UTC).

Swift example:
```swift
let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
```

Firebase ServerValue.timestamp() automatically provides this format.

---

## Conflict Resolution Rules

1. **Primary Rule**: `updatedAt` determines winner (latest wins)
2. **Progress Merging**: For cumulative fields (XP, counts), consider max value
3. **Sessions**: Append-only; conflicts rare due to push IDs
4. **Vocab**: Per-word resolution using `updatedAt`

---

## Schema Version

**Current Version**: 1

Future migrations will increment `schemaVersion` in `/users/{uid}/meta`.

---

## Data Validation

All writes must include:
- Valid `updatedAt` timestamp
- Required fields per node type
- Proper data types (enforced by RTDB rules)

See `database.rules.json` for server-side validation.
