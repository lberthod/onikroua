import SwiftUI
import SwiftData

struct SyncStatusView: View {
    @ObservedObject var syncEngine = CloudSyncEngine.shared
    @ObservedObject var networkMonitor: NetworkMonitor
    // @Query(filter: #Predicate<SyncOutboxItemCacheModel> { $0.attempts < 10 }) private var outboxItems: [SyncOutboxItemCacheModel]
    private var outboxItems: [Any] { [] } // Placeholder - CloudSync models not included in project
    
    var outboxCount: Int {
        outboxItems.count
    }
    
    var body: some View {
        if syncEngine.isSyncing {
            HStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.8)
                
                Text("Synchronisation...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if outboxCount > 0 {
                    Text("(\(outboxCount))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        } else if outboxCount > 0 && !networkMonitor.isConnected {
            HStack(spacing: 8) {
                Image(systemName: "icloud.slash")
                    .foregroundColor(.orange)
                
                Text("\(outboxCount) en attente")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
    }
}
