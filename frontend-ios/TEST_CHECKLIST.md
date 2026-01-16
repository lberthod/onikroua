# Cloud Sync Test Checklist

## Purpose

This checklist validates the cloud-authoritative sync system for the Onykroua iOS app. All tests should pass before considering the sync system production-ready.

---

## Test Environment Setup

### Prerequisites

- Two iOS devices or simulators (Device A and Device B)
- Firebase project with RTDB enabled
- `database.rules.json` deployed to Firebase
- App installed on both devices
- Network toggle capability (Airplane mode)

### Test User Accounts

- Create test user accounts via Firebase Auth
- Use distinct accounts for isolation tests

---

## 1. Multi-Device Sync Tests

### Test 1.1: Real-time Vocabulary Sync

**Objective**: Verify vocabulary changes sync across devices

**Steps**:
1. Sign in to the same account on Device A and Device B
2. On Device A, mark 5 words as "known"
3. Wait 2-3 seconds
4. On Device B, check vocabulary status

**Expected Result**:
- ✅ All 5 words appear as "known" on Device B
- ✅ No manual refresh required
- ✅ `updatedAt` timestamps match

**Pass Criteria**: All 5 words visible on Device B with correct status

---

### Test 1.2: Real-time Progress Sync

**Objective**: Verify XP and level sync across devices

**Steps**:
1. Sign in to the same account on Device A and Device B
2. On Device A, complete a lesson earning 50 XP
3. Wait 2-3 seconds
4. On Device B, check user progress

**Expected Result**:
- ✅ XP increased by 50 on Device B
- ✅ Progress bar updated
- ✅ Total stats reflect new values

**Pass Criteria**: Device B shows identical progress to Device A

---

### Test 1.3: Achievement Unlock Sync

**Objective**: Verify achievements sync across devices

**Steps**:
1. Sign in to the same account on Device A and Device B
2. On Device A, unlock an achievement (e.g., "First Word")
3. Wait 2-3 seconds
4. On Device B, navigate to achievements screen

**Expected Result**:
- ✅ Achievement shows as unlocked on Device B
- ✅ Unlock timestamp matches
- ✅ Visual indicator appears

**Pass Criteria**: Achievement appears unlocked on Device B

---

## 2. Offline Queue Tests

### Test 2.1: Offline Vocabulary Updates

**Objective**: Verify offline writes are queued and synced

**Steps**:
1. Sign in on Device A
2. Enable Airplane mode
3. Mark 10 words as "known"
4. Verify words appear as "known" in app (optimistic update)
5. Disable Airplane mode
6. Wait 5-10 seconds

**Expected Result**:
- ✅ Words show as "known" immediately (offline)
- ✅ After reconnection, all 10 updates sync to cloud
- ✅ No data loss
- ✅ Outbox count goes from 10 → 0

**Pass Criteria**: All 10 words successfully synced to cloud (verify on Device B or Firebase Console)

---

### Test 2.2: Offline Session Recording

**Objective**: Verify sessions recorded offline are synced

**Steps**:
1. Sign in on Device A
2. Enable Airplane mode
3. Complete a full study session (vocabulary quiz, etc.)
4. Verify session appears in history
5. Disable Airplane mode
6. Wait 5-10 seconds

**Expected Result**:
- ✅ Session visible locally while offline
- ✅ After reconnection, session syncs to cloud
- ✅ XP awarded in cloud
- ✅ Session appears on Device B

**Pass Criteria**: Session visible in Firebase Console and on Device B

---

### Test 2.3: Offline Queue Persistence

**Objective**: Verify outbox survives app restart

**Steps**:
1. Sign in on Device A
2. Enable Airplane mode
3. Mark 5 words as "known"
4. Force quit the app
5. Reopen app (still in Airplane mode)
6. Check sync debug screen
7. Disable Airplane mode
8. Wait 5-10 seconds

**Expected Result**:
- ✅ Outbox shows 5 items after app restart
- ✅ After reconnection, all 5 items sync
- ✅ No data loss

**Pass Criteria**: All 5 updates successfully synced

---

## 3. Conflict Resolution Tests

### Test 3.1: Simultaneous Offline Edits - Same Word

**Objective**: Verify conflict resolution using `updatedAt`

**Steps**:
1. Sign in to same account on Device A and Device B
2. Enable Airplane mode on BOTH devices
3. On Device A, mark word "bonjour" as "learning" (timestamp T1)
4. Wait 5 seconds
5. On Device B, mark word "bonjour" as "known" (timestamp T2, where T2 > T1)
6. Disable Airplane mode on Device A first
7. Wait for sync
8. Disable Airplane mode on Device B
9. Wait for sync (10 seconds)
10. Check final state on both devices

**Expected Result**:
- ✅ Final state on both: "known" (Device B's update, latest timestamp)
- ✅ No flip-flopping between states
- ✅ Stable convergence

**Pass Criteria**: Both devices show "known" after full sync

---

### Test 3.2: Simultaneous Offline Edits - Different Words

**Objective**: Verify independent word conflicts don't interfere

**Steps**:
1. Sign in to same account on Device A and Device B
2. Enable Airplane mode on BOTH devices
3. On Device A, mark word "bonjour" as "known"
4. On Device B, mark word "merci" as "known"
5. Disable Airplane mode on both devices
6. Wait for sync

**Expected Result**:
- ✅ Both words marked as "known" on both devices
- ✅ No conflicts (different words)
- ✅ Both updates preserved

**Pass Criteria**: Both devices show both words as "known"

---

### Test 3.3: Progress Conflict - Offline XP Gain

**Objective**: Verify XP updates converge correctly

**Steps**:
1. Sign in to same account on Device A and Device B
2. Note starting XP: 100
3. Enable Airplane mode on BOTH devices
4. On Device A, gain 50 XP
5. On Device B, gain 30 XP
6. Disable Airplane mode on Device A first
7. Wait for sync
8. Disable Airplane mode on Device B
9. Wait for full sync

**Expected Result**:
- ✅ Final XP based on latest `updatedAt` timestamp
- ✅ No XP loss (depends on strategy: timestamp wins OR max value)
- ✅ Stable final state

**Pass Criteria**: Both devices show consistent XP (either 150 or 130 based on timestamp, or 180 if using max merge)

**Note**: Document actual behavior observed. Current implementation uses timestamp-based resolution.

---

## 4. User Isolation Tests

### Test 4.1: Cross-User Data Isolation

**Objective**: Verify User B cannot see User A's data

**Steps**:
1. Sign in as User A on Device A
2. Mark 10 words as "known"
3. Sign out
4. Sign in as User B on same device
5. Check vocabulary and progress

**Expected Result**:
- ✅ User B sees empty/default progress
- ✅ No User A vocabulary visible
- ✅ User B's own data (if any) loads correctly

**Pass Criteria**: Complete data isolation, no cross-contamination

---

### Test 4.2: Firebase Console Data Check

**Objective**: Verify RTDB structure is clean and isolated

**Steps**:
1. Sign in as User A, perform some actions
2. Sign in as User B, perform different actions
3. Open Firebase Console → Realtime Database
4. Navigate to `/users/{userA_uid}` and `/users/{userB_uid}`

**Expected Result**:
- ✅ User A data only under `/users/{userA_uid}/`
- ✅ User B data only under `/users/{userB_uid}/`
- ✅ No data mixing
- ✅ All nodes have `updatedAt` fields

**Pass Criteria**: Clean data structure with proper isolation

---

### Test 4.3: Security Rules Enforcement

**Objective**: Verify User A cannot read User B's data

**Steps**:
1. Sign in as User A
2. Attempt to read `/users/{userB_uid}/progress` (via direct Firebase SDK call or test script)

**Expected Result**:
- ✅ Read fails with permission denied error
- ✅ User A can only read own UID path

**Pass Criteria**: Permission denied error

**Note**: This test requires direct Firebase SDK access or security rules simulator

---

## 5. Cold Start Tests

### Test 5.1: Fresh Install Bootstrap

**Objective**: Verify app works on first install

**Steps**:
1. Delete app from device
2. Reinstall app
3. Sign in with existing account (has cloud data)
4. Wait for bootstrap

**Expected Result**:
- ✅ App loads cloud data successfully
- ✅ All progress, vocab, achievements restored
- ✅ No crashes or errors
- ✅ UI reflects correct state

**Pass Criteria**: Full data restoration from cloud

---

### Test 5.2: New User Initialization

**Objective**: Verify new users are initialized correctly

**Steps**:
1. Create a brand new Firebase Auth account
2. Sign in on Device A
3. Complete onboarding
4. Perform first action (e.g., mark a word as known)

**Expected Result**:
- ✅ Cloud initialized with default progress (level 1, 0 XP)
- ✅ Meta node created with schema version
- ✅ First action synced successfully
- ✅ No errors

**Pass Criteria**: User data properly initialized in cloud

---

### Test 5.3: Re-login After Cache Clear

**Objective**: Verify app recovers from cache loss

**Steps**:
1. Sign in as User A, use app normally
2. Force quit app
3. Clear app data/cache (or use "Reset and Erase All Content" in Simulator)
4. Relaunch app
5. Sign in as User A again

**Expected Result**:
- ✅ Bootstrap loads all data from cloud
- ✅ Local cache repopulated
- ✅ App state matches cloud exactly

**Pass Criteria**: Full recovery from cloud

---

## 6. Stress & Edge Cases

### Test 6.1: Rapid Sequential Updates

**Objective**: Verify system handles rapid writes

**Steps**:
1. Sign in on Device A
2. Rapidly mark 50 words as "known" (as fast as possible)
3. Check sync debug screen
4. Verify all updates reach cloud

**Expected Result**:
- ✅ All 50 words synced (no data loss)
- ✅ No race conditions
- ✅ Outbox processes all items

**Pass Criteria**: All 50 words visible in Firebase Console

---

### Test 6.2: Long Offline Period

**Objective**: Verify system handles extended offline use

**Steps**:
1. Sign in on Device A
2. Enable Airplane mode
3. Use app for 30 minutes (complete lessons, mark words, etc.)
4. Accumulate 50+ queued writes
5. Disable Airplane mode
6. Wait for full sync (may take 1-2 minutes)

**Expected Result**:
- ✅ All writes eventually sync
- ✅ No timeout errors
- ✅ Outbox fully flushed
- ✅ Data integrity maintained

**Pass Criteria**: All actions synced successfully

---

### Test 6.3: Network Interruption During Sync

**Objective**: Verify resilience to network issues

**Steps**:
1. Sign in on Device A
2. Start marking words as known
3. During sync, toggle Airplane mode ON briefly (1-2 seconds)
4. Toggle Airplane mode OFF
5. Continue marking words
6. Verify all updates sync

**Expected Result**:
- ✅ Failed writes queued in outbox
- ✅ Successful retry after reconnection
- ✅ No duplicate writes
- ✅ No data loss

**Pass Criteria**: All updates eventually reach cloud

---

## 7. Observability Tests

### Test 7.1: Debug Screen Accuracy

**Objective**: Verify debug screen shows correct information

**Steps**:
1. Sign in on Device A
2. Open sync debug screen
3. Note outbox count, cache stats, last sync time
4. Mark 5 words as known
5. Refresh debug screen

**Expected Result**:
- ✅ Outbox count accurate
- ✅ Cache stats updated (vocab count increased by 5)
- ✅ Last sync timestamp recent
- ✅ No errors displayed

**Pass Criteria**: Debug info matches actual state

---

### Test 7.2: Force Reload Functionality

**Objective**: Verify force reload works correctly

**Steps**:
1. Sign in on Device A
2. Use app, create local state
3. Manually modify cloud data in Firebase Console (change XP)
4. Open debug screen on Device A
5. Tap "Force Reload from Cloud"
6. Verify UI updates

**Expected Result**:
- ✅ Local cache overwritten with cloud data
- ✅ UI reflects cloud state (new XP value)
- ✅ No errors

**Pass Criteria**: Cloud data successfully pulled and displayed

---

### Test 7.3: Manual Outbox Flush

**Objective**: Verify manual flush works

**Steps**:
1. Sign in on Device A
2. Enable Airplane mode
3. Mark 10 words as known
4. Verify outbox count = 10 in debug screen
5. Disable Airplane mode
6. Tap "Flush Outbox" in debug screen
7. Wait for completion

**Expected Result**:
- ✅ Outbox count decreases to 0
- ✅ All 10 words synced to cloud
- ✅ Status message shows success

**Pass Criteria**: Outbox fully flushed

---

## Test Summary Template

Use this template to record test results:

```
| Test ID | Test Name | Status | Notes |
|---------|-----------|--------|-------|
| 1.1 | Real-time Vocabulary Sync | ⏳ | |
| 1.2 | Real-time Progress Sync | ⏳ | |
| 1.3 | Achievement Unlock Sync | ⏳ | |
| 2.1 | Offline Vocabulary Updates | ⏳ | |
| 2.2 | Offline Session Recording | ⏳ | |
| 2.3 | Offline Queue Persistence | ⏳ | |
| 3.1 | Simultaneous Offline Edits - Same Word | ⏳ | |
| 3.2 | Simultaneous Offline Edits - Different Words | ⏳ | |
| 3.3 | Progress Conflict - Offline XP Gain | ⏳ | |
| 4.1 | Cross-User Data Isolation | ⏳ | |
| 4.2 | Firebase Console Data Check | ⏳ | |
| 4.3 | Security Rules Enforcement | ⏳ | |
| 5.1 | Fresh Install Bootstrap | ⏳ | |
| 5.2 | New User Initialization | ⏳ | |
| 5.3 | Re-login After Cache Clear | ⏳ | |
| 6.1 | Rapid Sequential Updates | ⏳ | |
| 6.2 | Long Offline Period | ⏳ | |
| 6.3 | Network Interruption During Sync | ⏳ | |
| 7.1 | Debug Screen Accuracy | ⏳ | |
| 7.2 | Force Reload Functionality | ⏳ | |
| 7.3 | Manual Outbox Flush | ⏳ | |
```

**Status Legend**:
- ⏳ Not Started
- 🔄 In Progress
- ✅ Passed
- ❌ Failed

---

## Acceptance Criteria

**Minimum requirements for production release**:

- ✅ All Multi-Device Sync tests pass (1.x)
- ✅ All Offline Queue tests pass (2.x)
- ✅ At least 2 Conflict Resolution tests pass (3.x)
- ✅ All User Isolation tests pass (4.x)
- ✅ All Cold Start tests pass (5.x)
- ✅ Debug screen functional (7.1, 7.2, 7.3)

**Nice-to-have**:
- All Stress & Edge Case tests pass (6.x)
- Performance benchmarks met (< 2s sync for 100 items)

---

## Debugging Failed Tests

If a test fails:

1. **Check Logs**: Look for `CloudSync:` prefixed messages in console
2. **Inspect Firebase Console**: Verify data structure and timestamps
3. **Check Debug Screen**: View outbox, cache stats, errors
4. **Enable Verbose Logging**: Add breakpoints in `CloudSyncEngine` and Repositories
5. **Verify RTDB Rules**: Ensure rules deployed correctly
6. **Check Network**: Verify device has internet connection

---

## Notes

- Run tests on multiple device types (iPhone, iPad) and iOS versions
- Test with different network conditions (WiFi, cellular, poor connection)
- Monitor Firebase usage quotas during stress tests
- Document any edge cases or unexpected behaviors discovered
- Keep this checklist updated as new features are added
