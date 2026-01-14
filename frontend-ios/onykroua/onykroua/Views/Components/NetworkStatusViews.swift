import SwiftUI

// MARK: - Offline Banner View

struct OfflineBanner: View {
    @ObservedObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.white)
                
                Text("Mode hors ligne")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Vos données sont sauvegardées")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.orange)
            .transition(.move(edge: .top))
        }
    }
}

// MARK: - Connection Quality Indicator

struct ConnectionQualityIndicator: View {
    @ObservedObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(networkMonitor.connectionQuality.color)
                .frame(width: 8, height: 8)
            
            Text(networkMonitor.connectionQuality.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}
