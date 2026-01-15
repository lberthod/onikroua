import SwiftUI

struct FirebaseSyncStatusView: View {
    @ObservedObject var syncService: FirebaseSyncService
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    var body: some View {
        HStack(spacing: 8) {
            if syncService.isSyncing {
                ProgressView()
                    .scaleEffect(0.7)
                
                Text("☁️ Synchronisation...")
                    .font(.caption)
                    .foregroundColor(.blue)
            } else if let lastSync = syncService.lastSyncDate {
                Image(systemName: "checkmark.icloud.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text("Synchronisé \(lastSync.relativeDescription)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if firebaseManager.isSignedIn {
                Image(systemName: "icloud")
                    .foregroundColor(.gray)
                    .font(.caption)
                
                Text("En attente de synchronisation")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(syncService.isSyncing ? Color.blue.opacity(0.1) : Color(.systemGray6))
        )
    }
}

struct CloudSyncBadge: View {
    @ObservedObject var syncService: FirebaseSyncService
    
    var body: some View {
        HStack(spacing: 4) {
            if syncService.isSyncing {
                ProgressView()
                    .scaleEffect(0.6)
            } else if syncService.lastSyncDate != nil {
                Image(systemName: "checkmark.icloud.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "icloud")
                    .foregroundColor(.gray)
            }
        }
        .font(.caption)
    }
}

struct SyncSettingsView: View {
    @ObservedObject var syncService: FirebaseSyncService
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var showSyncDetails = false
    @State private var isSyncing = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Synchronisation Cloud")
                        .font(.headline)
                    
                    if firebaseManager.isSignedIn {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("Connecté")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text("Non connecté")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if let lastSync = syncService.lastSyncDate {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Dernière sync")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(lastSync.relativeDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            
            if firebaseManager.isSignedIn {
                Button(action: { performManualSync() }) {
                    HStack {
                        if isSyncing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        Text(isSyncing ? "Synchronisation..." : "Synchroniser maintenant")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isSyncing)
                
                Button(action: { showSyncDetails = true }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Détails de la synchronisation")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            } else {
                Text("Connectez-vous pour synchroniser vos données sur tous vos appareils")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .sheet(isPresented: $showSyncDetails) {
            SyncDetailsView(syncService: syncService)
        }
    }
    
    private func performManualSync() {
        isSyncing = true
        Task {
            do {
                // Récupérer le contexte model et la progression
                // Note: Ceci devrait être passé depuis la vue parente
                print("🔄 Manual sync initiated")
                await MainActor.run {
                    isSyncing = false
                }
            } catch {
                print("❌ Manual sync failed: \(error.localizedDescription)")
                await MainActor.run {
                    isSyncing = false
                }
            }
        }
    }
}

struct SyncDetailsView: View {
    @ObservedObject var syncService: FirebaseSyncService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("État de la synchronisation") {
                    HStack {
                        Text("Statut")
                        Spacer()
                        if syncService.isSyncing {
                            HStack(spacing: 4) {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("En cours")
                                    .foregroundColor(.blue)
                            }
                        } else {
                            Text("Inactive")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let lastSync = syncService.lastSyncDate {
                        HStack {
                            Text("Dernière synchronisation")
                            Spacer()
                            Text(lastSync.formatted())
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let error = syncService.syncError {
                        HStack(alignment: .top) {
                            Text("Erreur")
                            Spacer()
                            Text(error.localizedDescription)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                
                Section("Données synchronisées") {
                    SyncDataRow(icon: "person.fill", title: "Profil utilisateur", isSynced: true)
                    SyncDataRow(icon: "star.fill", title: "Progression XP", isSynced: true)
                    SyncDataRow(icon: "trophy.fill", title: "Achievements", isSynced: true)
                    SyncDataRow(icon: "book.fill", title: "Vocabulaire appris", isSynced: true)
                    SyncDataRow(icon: "checkmark.circle.fill", title: "Quiz complétés", isSynced: true)
                    SyncDataRow(icon: "flame.fill", title: "Série de jours", isSynced: true)
                }
                
                Section("Informations") {
                    Text("Toutes vos données sont automatiquement synchronisées sur le cloud Firebase. Vous pouvez accéder à votre progression depuis n'importe quel appareil.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Synchronisation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SyncDataRow: View {
    let icon: String
    let title: String
    let isSynced: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            if isSynced {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
            }
        }
    }
}
