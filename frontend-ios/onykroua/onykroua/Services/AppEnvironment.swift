import Foundation
import SwiftUI

// MARK: - App Environment

/// Centralise tous les services et managers de l'application
/// Utilise le pattern Dependency Injection pour faciliter les tests
@MainActor
class AppEnvironment: ObservableObject {
    
    // MARK: - Shared Instance
    
    static let shared = AppEnvironment()
    
    // MARK: - Services
    
    let speechService: SpeechService
    let progressTracker: ProgressTracker
    let errorManager: ErrorManager
    
    // MARK: - Data Managers
    
    let vocabularyManager: VocabularyDataManager
    let grammarManager: GrammarDataManager
    let grammarData: GrammarData
    let feedService: FeedService
    
    // MARK: - Persistence Managers
    
    let vocabularyPersistence: VocabularyPersistenceManager
    let progressPersistence: ProgressPersistenceManager
    
    // MARK: - Network & Sync
    
    let networkMonitor: NetworkMonitor
    let syncManager: OfflineSyncManager
    
    // MARK: - Initialization
    
    private init() {
        // Services
        self.speechService = SpeechService()
        self.progressTracker = ProgressTracker.shared
        self.errorManager = ErrorManager()
        
        // Data Managers
        self.vocabularyManager = VocabularyDataManager.shared
        self.grammarManager = GrammarDataManager.shared
        self.grammarData = GrammarData()
        self.feedService = FeedService()
        
        // Persistence Managers
        self.vocabularyPersistence = VocabularyPersistenceManager.shared
        self.progressPersistence = ProgressPersistenceManager.shared
        
        // Network & Sync
        self.networkMonitor = NetworkMonitor.shared
        self.syncManager = OfflineSyncManager.shared
        
        print("✅ AppEnvironment initialized with persistence & offline support")
    }
    
    // MARK: - Factory Methods
    
    /// Crée un environnement de test avec des données mockées
    static func test() -> AppEnvironment {
        return AppEnvironment()
    }
}

// MARK: - SwiftUI Integration
// Note: AppEnvironment est injecté via .environmentObject() dans onykrouaApp.swift
// Les vues utilisent @EnvironmentObject var env: AppEnvironment
