import XCTest
@testable import onykroua

final class ErrorManagerTests: XCTestCase {
    
    var errorManager: ErrorManager!
    
    override func setUpWithError() throws {
        errorManager = ErrorManager()
    }
    
    override func tearDownWithError() throws {
        errorManager.clear()
        errorManager = nil
    }
    
    // MARK: - Initialization Tests
    
    func testErrorManager_InitialState_IsClean() throws {
        // Then
        XCTAssertNil(errorManager.currentError, "Should not have error initially")
        XCTAssertFalse(errorManager.showError, "Should not show error initially")
        XCTAssertFalse(errorManager.hasRetryAction, "Should not have retry action initially")
    }
    
    // MARK: - Error Handling Tests
    
    func testHandle_AppError_SetsCurrentError() throws {
        // Given
        let testError = AppError.jsonLoadFailed("test.json")
        
        // When
        errorManager.handle(testError)
        
        // Then
        XCTAssertNotNil(errorManager.currentError, "Should set current error")
        XCTAssertEqual(errorManager.currentError?.localizedDescription, "Impossible de charger le fichier test.json")
        XCTAssertTrue(errorManager.showError, "Should show error")
    }
    
    func testHandle_GenericError_ConvertsToAppError() throws {
        // Given
        let genericError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Generic error"])
        
        // When
        errorManager.handle(genericError)
        
        // Then
        XCTAssertNotNil(errorManager.currentError, "Should set current error")
        if case .unknown(let message) = errorManager.currentError {
            XCTAssertEqual(message, "Generic error", "Should convert generic error to unknown case")
        } else {
            XCTFail("Should be unknown error case")
        }
        XCTAssertTrue(errorManager.showError, "Should show error")
    }
    
    func testHandle_WithRetryAction_SetsRetryAction() throws {
        // Given
        let testError = AppError.networkError
        var retryCalled = false
        let retryAction = { retryCalled = true }
        
        // When
        errorManager.handle(testError, retryAction: retryAction)
        
        // Then
        XCTAssertTrue(errorManager.hasRetryAction, "Should have retry action")
        
        // When - Retry
        errorManager.retry()
        
        // Then
        XCTAssertTrue(retryCalled, "Retry action should be called")
        XCTAssertNil(errorManager.currentError, "Error should be cleared after retry")
        XCTAssertFalse(errorManager.showError, "Should not show error after retry")
    }
    
    func testHandle_WithoutRetryAction_NoRetryAction() throws {
        // Given
        let testError = AppError.dataCorrupted
        
        // When
        errorManager.handle(testError)
        
        // Then
        XCTAssertFalse(errorManager.hasRetryAction, "Should not have retry action")
    }
    
    // MARK: - Clear Tests
    
    func testClear_ResetsAllState() throws {
        // Given
        let testError = AppError.fileNotFound("missing.json")
        errorManager.handle(testError, retryAction: {})
        
        // When
        errorManager.clear()
        
        // Then
        XCTAssertNil(errorManager.currentError, "Should clear current error")
        XCTAssertFalse(errorManager.showError, "Should not show error")
        XCTAssertFalse(errorManager.hasRetryAction, "Should clear retry action")
    }
    
    // MARK: - Retry Tests
    
    func testRetry_WithRetryAction_ExecutesAndClears() throws {
        // Given
        let testError = AppError.decodingError("Invalid JSON")
        var retryCalled = false
        let retryAction = { retryCalled = true }
        
        errorManager.handle(testError, retryAction: retryAction)
        
        // When
        errorManager.retry()
        
        // Then
        XCTAssertTrue(retryCalled, "Should execute retry action")
        XCTAssertNil(errorManager.currentError, "Should clear error")
        XCTAssertFalse(errorManager.showError, "Should not show error")
        XCTAssertFalse(errorManager.hasRetryAction, "Should clear retry action")
    }
    
    func testRetry_WithoutRetryAction_DoesNotCrash() throws {
        // Given
        let testError = AppError.networkError
        errorManager.handle(testError)
        
        // When & Then - Should not crash
        XCTAssertNoThrow(errorManager.retry(), "Retry without action should not crash")
        
        // Should still clear the error
        XCTAssertNil(errorManager.currentError, "Should clear error even without retry action")
        XCTAssertFalse(errorManager.showError, "Should not show error after retry")
    }
    
    // MARK: - AppError Tests
    
    func testAppError_LocalizedDescriptions() throws {
        // Test all error cases
        let jsonError = AppError.jsonLoadFailed("test.json")
        XCTAssertEqual(jsonError.localizedDescription, "Impossible de charger le fichier test.json")
        
        let fileError = AppError.fileNotFound("missing.json")
        XCTAssertEqual(fileError.localizedDescription, "Fichier missing.json introuvable")
        
        let decodingError = AppError.decodingError("Invalid format")
        XCTAssertEqual(decodingError.localizedDescription, "Erreur de lecture des données: Invalid format")
        
        let networkError = AppError.networkError
        XCTAssertEqual(networkError.localizedDescription, "Problème de connexion réseau")
        
        let dataError = AppError.dataCorrupted
        XCTAssertEqual(dataError.localizedDescription, "Les données sont corrompues")
        
        let unknownError = AppError.unknown("Something went wrong")
        XCTAssertEqual(unknownError.localizedDescription, "Erreur inattendue: Something went wrong")
    }
    
    func testAppError_RecoverySuggestions() throws {
        // Test recovery suggestions
        let jsonError = AppError.jsonLoadFailed("test.json")
        XCTAssertEqual(jsonError.recoverySuggestion, "Veuillez réinstaller l'application")
        
        let fileError = AppError.fileNotFound("missing.json")
        XCTAssertEqual(fileError.recoverySuggestion, "Veuillez réinstaller l'application")
        
        let decodingError = AppError.decodingError("Invalid format")
        XCTAssertEqual(decodingError.recoverySuggestion, "Essayez de redémarrer l'application")
        
        let dataError = AppError.dataCorrupted
        XCTAssertEqual(dataError.recoverySuggestion, "Essayez de redémarrer l'application")
        
        let networkError = AppError.networkError
        XCTAssertEqual(networkError.recoverySuggestion, "Vérifiez votre connexion internet")
        
        let unknownError = AppError.unknown("Something went wrong")
        XCTAssertEqual(unknownError.recoverySuggestion, "Réessayez plus tard")
    }
    
    func testAppError_Equatable() throws {
        // Test equality
        let error1 = AppError.jsonLoadFailed("test.json")
        let error2 = AppError.jsonLoadFailed("test.json")
        let error3 = AppError.jsonLoadFailed("other.json")
        
        XCTAssertEqual(error1, error2, "Same errors should be equal")
        XCTAssertNotEqual(error1, error3, "Different errors should not be equal")
        
        // Test different types
        let jsonError = AppError.jsonLoadFailed("test.json")
        let networkError = AppError.networkError
        XCTAssertNotEqual(jsonError, networkError, "Different error types should not be equal")
    }
    
    // MARK: - Multiple Error Tests
    
    func testHandleMultipleErrors_OverridesPrevious() throws {
        // Given
        let firstError = AppError.networkError
        let secondError = AppError.dataCorrupted
        
        // When
        errorManager.handle(firstError)
        XCTAssertEqual(errorManager.currentError, firstError, "First error should be set")
        
        errorManager.handle(secondError)
        
        // Then
        XCTAssertEqual(errorManager.currentError, secondError, "Second error should override first")
        XCTAssertTrue(errorManager.showError, "Should still show error")
    }
    
    func testHandleSameError_UpdatesState() throws {
        // Given
        let testError = AppError.jsonLoadFailed("test.json")
        
        // When
        errorManager.handle(testError)
        let firstShowTime = errorManager.showError
        
        errorManager.handle(testError)
        let secondShowTime = errorManager.showError
        
        // Then
        XCTAssertTrue(firstShowTime, "Should show error first time")
        XCTAssertTrue(secondShowTime, "Should still show error second time")
        XCTAssertEqual(errorManager.currentError, testError, "Should maintain current error")
    }
    
    // MARK: - Edge Cases Tests
    
    func testHandleNilError_DoesNotCrash() throws {
        // When & Then - Should not crash with nil error
        XCTAssertNoThrow(errorManager.handle(AppError.unknown("")), "Should handle empty error")
    }
    
    func testClearWithoutError_DoesNotCrash() throws {
        // When & Then - Should not crash when clearing clean state
        XCTAssertNoThrow(errorManager.clear(), "Clear without error should not crash")
    }
    
    func testRetryWithoutError_DoesNotCrash() throws {
        // When & Then - Should not crash when retrying without error
        XCTAssertNoThrow(errorManager.retry(), "Retry without error should not crash")
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_HandleError() throws {
        let testError = AppError.networkError
        
        measure {
            errorManager.handle(testError)
            errorManager.clear()
        }
    }
    
    func testPerformance_MultipleErrors() throws {
        let errors: [AppError] = [
            .jsonLoadFailed("test1.json"),
            .fileNotFound("test2.json"),
            .decodingError("Invalid"),
            .networkError,
            .dataCorrupted,
            .unknown("Test")
        ]
        
        measure {
            for error in errors {
                errorManager.handle(error)
                errorManager.clear()
            }
        }
    }
}
