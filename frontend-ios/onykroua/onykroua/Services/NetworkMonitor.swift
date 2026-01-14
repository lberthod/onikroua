    import Foundation
import Network
import SwiftUI

// MARK: - Network Monitor

@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isConnected: Bool = true
    @Published var connectionType: ConnectionType = .unknown
    @Published var isExpensive: Bool = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
        
        var icon: String {
            switch self {
            case .wifi: return "wifi"
            case .cellular: return "antenna.radiowaves.left.and.right"
            case .ethernet: return "cable.connector"
            case .unknown: return "network"
            }
        }
        
        var description: String {
            switch self {
            case .wifi: return "Wi-Fi"
            case .cellular: return "Cellulaire"
            case .ethernet: return "Ethernet"
            case .unknown: return "Inconnu"
            }
        }
    }
    
    private init() {
        startMonitoring()
    }
    
    // MARK: - Monitoring
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.updateConnectionStatus(path: path)
            }
        }
        
        monitor.start(queue: queue)
        print("📡 Network monitoring started")
    }
    
    func stopMonitoring() {
        monitor.cancel()
        print("📡 Network monitoring stopped")
    }
    
    private func updateConnectionStatus(path: NWPath) {
        isConnected = path.status == .satisfied
        isExpensive = path.isExpensive
        
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
        
        let status = isConnected ? "✅ Connected" : "❌ Disconnected"
        let type = connectionType.description
        print("📡 Network status: \(status) (\(type))")
    }
    
    // MARK: - Helper Methods
    
    var canPerformNetworkOperations: Bool {
        return isConnected
    }
    
    var shouldUseCache: Bool {
        return !isConnected || isExpensive
    }
    
    var connectionQuality: ConnectionQuality {
        if !isConnected {
            return .offline
        } else if isExpensive {
            return .poor
        } else if connectionType == .wifi {
            return .excellent
        } else if connectionType == .cellular {
            return .good
        } else {
            return .fair
        }
    }
    
    enum ConnectionQuality {
        case offline
        case poor
        case fair
        case good
        case excellent
        
        var color: Color {
            switch self {
            case .offline: return .red
            case .poor: return .orange
            case .fair: return .yellow
            case .good: return .green
            case .excellent: return .blue
            }
        }
        
        var description: String {
            switch self {
            case .offline: return "Hors ligne"
            case .poor: return "Mauvaise"
            case .fair: return "Moyenne"
            case .good: return "Bonne"
            case .excellent: return "Excellente"
            }
        }
    }
}

