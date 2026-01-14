import Foundation
import SwiftData

// MARK: - Pending Action Model

@Model
final class PendingActionModel {
    @Attribute(.unique) var id: String
    var actionType: String
    var payload: String
    var createdAt: Date
    var retryCount: Int
    var lastError: String?
    
    init(
        id: String = UUID().uuidString,
        actionType: String,
        payload: String,
        createdAt: Date = Date(),
        retryCount: Int = 0,
        lastError: String? = nil
    ) {
        self.id = id
        self.actionType = actionType
        self.payload = payload
        self.createdAt = createdAt
        self.retryCount = retryCount
        self.lastError = lastError
    }
}

// MARK: - Offline Sync Manager

@MainActor
class OfflineSyncManager: ObservableObject {
    static let shared = OfflineSyncManager()
    
    @Published var isSyncing: Bool = false
    @Published var pendingActions: Int = 0
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?
    
    private var modelContext: ModelContext?
    private let networkMonitor = NetworkMonitor.shared
    
    private init() {
        setupObservers()
    }
    
    // MARK: - Setup
    
    func setupModelContext(_ context: ModelContext) {
        self.modelContext = context
        print("✅ OfflineSyncManager ModelContext configured")
    }
    
    private func setupObservers() {
        // Observe network changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NetworkStatusChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                if self?.networkMonitor.isConnected == true {
                    await self?.syncPendingActions()
                }
            }
        }
    }
    
    // MARK: - Queue Operations
    
    func queueAction(type: String, data: [String: Any]) {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let payload = String(data: jsonData, encoding: .utf8) ?? "{}"
            
            let action = PendingActionModel(
                actionType: type,
                payload: payload
            )
            
            context.insert(action)
            try context.save()
            
            pendingActions += 1
            print("📥 Queued action: \(type)")
            
            // Try to sync immediately if online
            if networkMonitor.isConnected {
                Task {
                    await syncPendingActions()
                }
            }
        } catch {
            print("❌ Failed to queue action: \(error)")
        }
    }
    
    func getPendingActions() -> [PendingActionModel] {
        guard let context = modelContext else {
            return []
        }
        
        let descriptor = FetchDescriptor<PendingActionModel>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ Failed to fetch pending actions: \(error)")
            return []
        }
    }
    
    // MARK: - Sync Operations
    
    func syncPendingActions() async {
        guard networkMonitor.isConnected else {
            print("⚠️ Cannot sync: No network connection")
            return
        }
        
        guard !isSyncing else {
            print("⚠️ Sync already in progress")
            return
        }
        
        isSyncing = true
        
        let actions = getPendingActions()
        pendingActions = actions.count
        
        guard !actions.isEmpty else {
            isSyncing = false
            return
        }
        
        print("🔄 Syncing \(actions.count) pending actions...")
        
        for action in actions {
            await processAction(action)
        }
        
        lastSyncDate = Date()
        isSyncing = false
        
        print("✅ Sync completed")
    }
    
    private func processAction(_ action: PendingActionModel) async {
        guard let context = modelContext else {
            return
        }
        
        do {
            // Parse payload
            guard let data = action.payload.data(using: .utf8),
                  let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw NSError(domain: "OfflineSync", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid payload"])
            }
            
            // Process action based on type
            switch action.actionType {
            case "markWordLearned":
                await processMarkWordLearned(payload)
            case "bookmark":
                await processBookmark(payload)
            case "like":
                await processLike(payload)
            case "updateProgress":
                await processUpdateProgress(payload)
            default:
                print("⚠️ Unknown action type: \(action.actionType)")
            }
            
            // Remove action from queue on success
            context.delete(action)
            try context.save()
            pendingActions -= 1
            
            print("✅ Processed action: \(action.actionType)")
            
        } catch {
            // Update retry count
            action.retryCount += 1
            action.lastError = error.localizedDescription
            
            // Remove if too many retries
            if action.retryCount > 5 {
                context.delete(action)
                pendingActions -= 1
                print("❌ Action removed after \(action.retryCount) retries: \(action.actionType)")
            }
            
            try? context.save()
            syncError = error
            print("❌ Failed to process action: \(error)")
        }
    }
    
    // MARK: - Action Processors
    
    private func processMarkWordLearned(_ payload: [String: Any]) async {
        guard let wordId = payload["wordId"] as? String,
              let word = payload["word"] as? String,
              let translation = payload["translation"] as? String,
              let language = payload["language"] as? String,
              let category = payload["category"] as? String else {
            return
        }
        
        // In real app, this would sync to backend
        ProgressPersistenceManager.shared.markWordAsLearned(
            wordId: wordId,
            word: word,
            translation: translation,
            language: language,
            category: category
        )
        
        print("📤 Synced learned word: \(word)")
    }
    
    private func processBookmark(_ payload: [String: Any]) async {
        guard let itemId = payload["itemId"] as? String,
              let isBookmarked = payload["isBookmarked"] as? Bool else {
            return
        }
        
        // In real app, this would sync to backend
        print("📤 Synced bookmark: \(itemId) = \(isBookmarked)")
    }
    
    private func processLike(_ payload: [String: Any]) async {
        guard let itemId = payload["itemId"] as? String,
              let isLiked = payload["isLiked"] as? Bool else {
            return
        }
        
        // In real app, this would sync to backend
        print("📤 Synced like: \(itemId) = \(isLiked)")
    }
    
    private func processUpdateProgress(_ payload: [String: Any]) async {
        // In real app, this would sync to backend
        print("📤 Synced progress update")
    }
    
    // MARK: - Manual Sync
    
    func forceSyncNow() async {
        print("🔄 Force sync requested")
        await syncPendingActions()
    }
    
    // MARK: - Clear Queue
    
    func clearAllPendingActions() {
        guard let context = modelContext else {
            return
        }
        
        do {
            try context.delete(model: PendingActionModel.self)
            try context.save()
            pendingActions = 0
            print("✅ Cleared all pending actions")
        } catch {
            print("❌ Failed to clear pending actions: \(error)")
        }
    }
}

