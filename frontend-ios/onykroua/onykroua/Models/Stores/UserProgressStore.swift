import Foundation
import SwiftUI
import SwiftData
import FirebaseAuth

@Observable
final class UserProgressStore {
    private let modelContext: ModelContext
    
    var progress: UserProgress?
    var isLoading: Bool = false
    var error: Error?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadProgress()
    }
    
    func loadProgress() {
        guard let userId = Auth.auth().currentUser?.uid else {
            error = AppError.authenticationError("User not authenticated")
            return
        }
        
        isLoading = true
        
        let descriptor = FetchDescriptor<UserProgressCacheModel>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        if let cached = try? modelContext.fetch(descriptor).first {
            progress = UserProgressMapper.fromCache(cached)
        } else {
            progress = nil
        }
        
        isLoading = false
    }
    
    func saveProgress(_ domain: UserProgress) {
        let descriptor = FetchDescriptor<UserProgressCacheModel>(
            predicate: #Predicate { $0.userId == domain.userId }
        )
        
        if let cached = try? modelContext.fetch(descriptor).first {
            let updatedCache = UserProgressMapper.toCache(domain, into: cached)
            try? modelContext.save()
        } else {
            let newCache = UserProgressMapper.toCache(domain)
            modelContext.insert(newCache)
            try? modelContext.save()
        }
        
        progress = domain
    }
    
    func updateProgress(_ update: (inout UserProgress) -> Void) {
        guard var mutableProgress = progress else { return }
        
        update(&mutableProgress)
        saveProgress(mutableProgress)
    }
}
