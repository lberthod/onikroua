import Foundation
import SwiftUI

// MARK: - App Errors

public enum AppError: LocalizedError, Equatable {
    case jsonLoadFailed(String)
    case fileNotFound(String)
    case decodingError(String)
    case networkError(String)
    case authenticationError(String)
    case validationError(String)
    case databaseError(String)
    case dataCorrupted
    case unknown(String)
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .jsonLoadFailed(let filename):
            return "Impossible de charger le fichier \(filename)"
        case .fileNotFound(let filename):
            return "Fichier \(filename) introuvable"
        case .decodingError(let details):
            return "Erreur de lecture des données: \(details)"
        case .networkError(let message):
            return "Erreur réseau: \(message)"
        case .authenticationError(let message):
            return "Erreur d'authentification: \(message)"
        case .validationError(let message):
            return "Erreur de validation: \(message)"
        case .databaseError(let message):
            return "Erreur de base de données: \(message)"
        case .dataCorrupted:
            return "Les données sont corrompues"
        case .unknown(let message):
            return "Erreur inattendue: \(message)"
        case .unknownError:
            return "Une erreur inconnue s'est produite"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .jsonLoadFailed, .fileNotFound:
            return "Veuillez réinstaller l'application"
        case .decodingError, .dataCorrupted:
            return "Essayez de redémarrer l'application"
        case .networkError:
            return "Vérifiez votre connexion internet"
        case .authenticationError:
            return "Veuillez vous reconnecter"
        case .validationError:
            return "Veuillez vérifier les données saisies"
        case .databaseError:
            return "Redémarrez l'application"
        case .unknown, .unknownError:
            return "Réessayez plus tard"
        }
    }
}

// MARK: - Error Manager

public final class ErrorManager: ObservableObject {
    @Published var currentError: AppError?
    @Published var showError = false
    
    private var retryAction: (() -> Void)?
    
    var hasRetryAction: Bool {
        retryAction != nil
    }
    
    public func handle(_ error: Error, retryAction: (() -> Void)? = nil) {
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
    
    public func retry() {
        retryAction?()
        clear()
    }
    
    public func clear() {
        currentError = nil
        showError = false
        retryAction = nil
    }
}
