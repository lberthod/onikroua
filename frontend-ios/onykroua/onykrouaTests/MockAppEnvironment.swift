import Foundation
@testable import onykroua

// MARK: - Mock AppEnvironment for Testing

class MockAppEnvironment: AppEnvironment {
    // Override with mock services for testing
    override init() {
        super.init()
    }
    
    // Mock implementations can be added here
    static func mock() -> AppEnvironment {
        return AppEnvironment.test()
    }
}

// MARK: - Mock VocabularyDataManager

class MockVocabularyDataManager: VocabularyDataManager {
    var mockWords: [VocabWord] = []
    var mockCategories: [VocabCategory] = []
    var shouldFailLoading = false
    
    override func loadVocabularyAsync(language: String) {
        if shouldFailLoading {
            Task { @MainActor in
                isLoading = false
                loadingError = AppError.jsonLoadFailed("mock_error.json")
            }
            return
        }
        
        Task { @MainActor in
            isLoading = false
            // Load mock data
            if language == "it" {
                // Set mock Italian data
            } else {
                // Set mock Spanish data
            }
        }
    }
}

// MARK: - Mock ErrorManager

class MockErrorManager: ErrorManager {
    var capturedErrors: [AppError] = []
    
    override func handle(_ error: Error, retryAction: (() -> Void)? = nil) {
        if let appError = error as? AppError {
            capturedErrors.append(appError)
        }
        super.handle(error, retryAction: retryAction)
    }
}
