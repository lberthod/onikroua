import Foundation

// MARK: - App Error Handling

enum AppError: LocalizedError {
    case networkError(String)
    case authenticationError(String)
    case validationError(String)
    case fileNotFound(String)
    case jsonLoadFailed(String)
    case decodingError(String)
    case databaseError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Erreur réseau: \(message)"
        case .authenticationError(let message):
            return "Erreur d'authentification: \(message)"
        case .validationError(let message):
            return "Erreur de validation: \(message)"
        case .fileNotFound(let filename):
            return "Fichier introuvable: \(filename)"
        case .jsonLoadFailed(let filename):
            return "Impossible de charger: \(filename)"
        case .decodingError(let message):
            return "Erreur de décodage: \(message)"
        case .databaseError(let message):
            return "Erreur de base de données: \(message)"
        case .unknownError:
            return "Une erreur inconnue s'est produite"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Vérifiez votre connexion internet et réessayez"
        case .authenticationError:
            return "Veuillez vous reconnecter"
        case .validationError:
            return "Veuillez vérifier les données saisies"
        case .fileNotFound, .jsonLoadFailed:
            return "Veuillez réinstaller l'application"
        case .decodingError:
            return "Les données sont corrompues, veuillez réinstaller"
        case .databaseError:
            return "Redémarrez l'application"
        case .unknownError:
            return "Veuillez réessayer plus tard"
        }
    }
    
    var userFriendlyMessage: String {
        return "\(errorDescription ?? "Erreur")\n\(recoverySuggestion ?? "")"
    }
}

// MARK: - Error Logger

class ErrorLogger {
    static let shared = ErrorLogger()
    
    private init() {}
    
    func log(_ error: Error, context: String? = nil) {
        #if DEBUG
        print("❌ ERROR [\(context ?? "Unknown")]:")
        print("   Type: \(type(of: error))")
        print("   Description: \(error.localizedDescription)")
        if let appError = error as? AppError {
            print("   Recovery: \(appError.recoverySuggestion ?? "None")")
        }
        print("   Timestamp: \(Date())")
        print("---")
        #endif
        
        // En production, envoyer à un service d'analytics
        // Analytics.logError(error, context: context)
    }
    
    func logWarning(_ message: String, context: String? = nil) {
        #if DEBUG
        print("⚠️ WARNING [\(context ?? "Unknown")]: \(message)")
        #endif
    }
    
    func logInfo(_ message: String, context: String? = nil) {
        #if DEBUG
        print("ℹ️ INFO [\(context ?? "Unknown")]: \(message)")
        #endif
    }
}

// MARK: - Result Extensions

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var isFailure: Bool {
        return !isSuccess
    }
    
    var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
