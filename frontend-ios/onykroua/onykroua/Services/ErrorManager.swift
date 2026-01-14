import Foundation
import SwiftUI

// MARK: - App Errors

enum AppError: LocalizedError, Equatable {
    case jsonLoadFailed(String)
    case fileNotFound(String)
    case decodingError(String)
    case networkError
    case dataCorrupted
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .jsonLoadFailed(let filename):
            return "Impossible de charger le fichier \(filename)"
        case .fileNotFound(let filename):
            return "Fichier \(filename) introuvable"
        case .decodingError(let details):
            return "Erreur de lecture des données: \(details)"
        case .networkError:
            return "Problème de connexion réseau"
        case .dataCorrupted:
            return "Les données sont corrompues"
        case .unknown(let message):
            return "Erreur inattendue: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .jsonLoadFailed, .fileNotFound:
            return "Veuillez réinstaller l'application"
        case .decodingError, .dataCorrupted:
            return "Essayez de redémarrer l'application"
        case .networkError:
            return "Vérifiez votre connexion internet"
        case .unknown:
            return "Réessayez plus tard"
        }
    }
}

// MARK: - Error Manager

class ErrorManager: ObservableObject {
    @Published var currentError: AppError?
    @Published var showError = false
    
    private var retryAction: (() -> Void)?
    
    var hasRetryAction: Bool {
        retryAction != nil
    }
    
    func handle(_ error: Error, retryAction: (() -> Void)? = nil) {
        let appError: AppError
        
        if let err = error as? AppError {
            appError = err
        } else {
            appError = .unknown(error.localizedDescription)
        }
        
        // Toujours afficher l'erreur, sans aucune vérification
        self.currentError = appError
        self.retryAction = retryAction
        self.showError = true
        
        print("❌ Error: \(appError.localizedDescription)")
    }
    
    func retry() {
        retryAction?()
        clear()
    }
    
    func clear() {
        currentError = nil
        showError = false
        retryAction = nil
    }
}
