import SwiftUI
import SwiftData
import FirebaseAuth

struct SyncDebugView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var syncEngine = CloudSyncEngine.shared
    @State private var userId: String = ""
    @State private var localProgress: CachedUserProgress?
    @State private var localVocabCount: Int = 0
    @State private var localAchievementsCount: Int = 0
    @State private var localSessionsCount: Int = 0
    @State private var outboxCount: Int = 0
    @State private var isRefreshing = false
    @State private var showReloadConfirm = false
    @State private var showFlushConfirm = false
    @State private var statusMessage: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section("Sync Status") {
                    InfoRow(title: "User ID", value: userId.isEmpty ? "Not signed in" : String(userId.prefix(8)) + "...")
                    InfoRow(title: "Last Sync", value: formatDate(syncEngine.lastSyncDate))
                    InfoRow(title: "Is Syncing", value: syncEngine.isSyncing ? "Yes" : "No")
                    
                    if let error = syncEngine.syncError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Section("Local Cache Stats") {
                    InfoRow(title: "Progress Cached", value: localProgress != nil ? "Yes" : "No")
                    if let progress = localProgress {
                        InfoRow(title: "XP", value: "\(progress.xp)")
                        InfoRow(title: "Level", value: "\(progress.level)")
                        InfoRow(title: "Words Learned", value: "\(progress.wordsLearned)")
                        InfoRow(title: "Streak", value: "\(progress.streakDays) days")
                        InfoRow(title: "Last Updated", value: formatTimestamp(progress.updatedAt))
                        InfoRow(title: "Last Synced", value: formatTimestamp(progress.lastSyncAt))
                    }
                    
                    InfoRow(title: "Vocab Words", value: "\(localVocabCount)")
                    InfoRow(title: "Achievements", value: "\(localAchievementsCount)")
                    InfoRow(title: "Sessions", value: "\(localSessionsCount)")
                }
                
                Section("Offline Queue") {
                    InfoRow(title: "Pending Writes", value: "\(outboxCount)")
                    
                    if outboxCount > 0 {
                        Button(action: {
                            showFlushConfirm = true
                        }) {
                            Label("Flush Outbox", systemImage: "arrow.clockwise")
                                .foregroundColor(.blue)
                        }
                        .confirmationDialog("Flush Outbox", isPresented: $showFlushConfirm) {
                            Button("Flush Now") {
                                flushOutbox()
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("This will attempt to sync all pending writes to the cloud.")
                        }
                    }
                }
                
                Section("Actions") {
                    Button(action: {
                        showReloadConfirm = true
                    }) {
                        Label("Force Reload from Cloud", systemImage: "cloud.fill")
                            .foregroundColor(.orange)
                    }
                    .disabled(userId.isEmpty)
                    .confirmationDialog("Force Reload", isPresented: $showReloadConfirm) {
                        Button("Reload Now", role: .destructive) {
                            forceReload()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("This will reload all data from the cloud, overwriting local cache.")
                    }
                    
                    Button(action: {
                        refreshStats()
                    }) {
                        Label("Refresh Stats", systemImage: "arrow.clockwise")
                    }
                }
                
                if !statusMessage.isEmpty {
                    Section("Status") {
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Sync Debug")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadStats()
            }
            .refreshable {
                refreshStats()
            }
        }
    }
    
    private func loadStats() {
        if let uid = Auth.auth().currentUser?.uid {
            userId = uid
            
            let progressDescriptor = FetchDescriptor<CachedUserProgress>(
                predicate: #Predicate { $0.userId == uid }
            )
            localProgress = try? modelContext.fetch(progressDescriptor).first
            
            let vocabDescriptor = FetchDescriptor<CachedVocabWord>(
                predicate: #Predicate { $0.userId == uid }
            )
            localVocabCount = (try? modelContext.fetchCount(vocabDescriptor)) ?? 0
            
            let achievementsDescriptor = FetchDescriptor<CachedAchievement>(
                predicate: #Predicate { $0.userId == uid }
            )
            localAchievementsCount = (try? modelContext.fetchCount(achievementsDescriptor)) ?? 0
            
            let sessionsDescriptor = FetchDescriptor<CachedSession>(
                predicate: #Predicate { $0.userId == uid }
            )
            localSessionsCount = (try? modelContext.fetchCount(sessionsDescriptor)) ?? 0
            
            let outboxDescriptor = FetchDescriptor<SyncOutboxItem>(
                predicate: #Predicate { $0.userId == uid }
            )
            outboxCount = (try? modelContext.fetchCount(outboxDescriptor)) ?? 0
        }
    }
    
    private func refreshStats() {
        isRefreshing = true
        statusMessage = "Refreshing..."
        loadStats()
        statusMessage = "Stats refreshed at \(formatDate(Date()))"
        isRefreshing = false
    }
    
    private func forceReload() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        statusMessage = "Starting force reload..."
        
        Task {
            await syncEngine.bootstrap(userId: uid)
            await MainActor.run {
                loadStats()
                statusMessage = "Force reload completed at \(formatDate(Date()))"
            }
        }
    }
    
    private func flushOutbox() {
        statusMessage = "Flushing outbox..."
        
        Task {
            await syncEngine.flushOutbox()
            await MainActor.run {
                loadStats()
                statusMessage = "Outbox flushed at \(formatDate(Date()))"
            }
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTimestamp(_ timestamp: Int64) -> String {
        let date = Date.fromMilliseconds(timestamp)
        return formatDate(date)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
        .font(.callout)
    }
}

#Preview {
    SyncDebugView()
}
