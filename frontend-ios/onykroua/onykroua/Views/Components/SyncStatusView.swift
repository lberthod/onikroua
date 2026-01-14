import SwiftUI

// MARK: - Sync Status View

struct SyncStatusView: View {
    @ObservedObject var syncManager: OfflineSyncManager
    @ObservedObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        if syncManager.isSyncing {
            HStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.8)
                
                Text("Synchronisation en cours...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if syncManager.pendingActions > 0 {
                    Text("(\(syncManager.pendingActions) actions)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        } else if syncManager.pendingActions > 0 && !networkMonitor.isConnected {
            HStack(spacing: 8) {
                Image(systemName: "icloud.slash")
                    .foregroundColor(.orange)
                
                Text("\(syncManager.pendingActions) action(s) en attente")
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
