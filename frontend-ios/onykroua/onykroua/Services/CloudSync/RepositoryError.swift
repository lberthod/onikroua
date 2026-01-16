import Foundation

enum RepositoryError: LocalizedError {
    case userNotAuthenticated
    case dataNotFound
    case syncFailed(String)
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User is not authenticated"
        case .dataNotFound:
            return "Data not found in cache"
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        case .invalidData:
            return "Invalid data format"
        }
    }
}
