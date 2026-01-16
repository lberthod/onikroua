import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var env: AppEnvironment
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Query private var onboardingEntries: [OnboardingData]
    @State private var showEmailSignIn = false
    
    private var progressTracker: ProgressTracker {
        env.progressTracker
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // User account section
                        if firebaseManager.isSignedIn {
                            userAccountSection
                        } else {
                            signInPromptSection
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Progression")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Niveau \(progressTracker.getUserLevel())")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(progressTracker.totalXP) XP")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                                
                                ProgressView(value: progressTracker.getProgressToNextLevel())
                                    .tint(.blue)
                                
                                Text("Niveau \(progressTracker.getUserLevel() + 1) dans \(100 - (progressTracker.totalXP % 100)) XP")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatItem(icon: "book.fill", value: "\(progressTracker.wordsLearned.count)", label: "Mots appris", color: .blue)
                            StatItem(icon: "flame.fill", value: "\(progressTracker.dailyStreak) j", label: "Streak", color: .orange)
                            StatItem(icon: "star.fill", value: "\(progressTracker.totalXP)", label: "XP Total", color: .yellow)
                            StatItem(icon: "heart.fill", value: "\(progressTracker.favorites.count)", label: "Favoris", color: .red)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🏆 Succès")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                BadgeCard(emoji: "👋", title: "Débutant", unlocked: true)
                                BadgeCard(emoji: "💪", title: "Motivé", unlocked: progressTracker.dailyStreak >= 3)
                                BadgeCard(emoji: "🔥", title: "En feu", unlocked: progressTracker.dailyStreak >= 7)
                                BadgeCard(emoji: "📚", title: "Lecteur", unlocked: progressTracker.wordsLearned.count >= 20)
                                BadgeCard(emoji: "⭐", title: "Expert", unlocked: progressTracker.totalXP >= 500)
                                BadgeCard(emoji: "🏆", title: "Champion", unlocked: progressTracker.totalXP >= 1000)
                            }
                            .padding(.horizontal)
                        }
                        
                        VStack(spacing: 0) {
                            ProfileRow(icon: "chart.bar.fill", title: "Statistiques détaillées", color: .green)
                            Divider().padding(.leading, 60)
                            ProfileRow(icon: "gear", title: "Paramètres", color: .gray)
                            Divider().padding(.leading, 60)
                            ProfileRow(icon: "info.circle.fill", title: "À propos", color: .blue)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        if let lastActivity = progressTracker.lastActivityDate {
                            Text("Dernière activité: \(formattedDate(lastActivity))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.vertical)
                }
                
                // Fixed button for anonymous users to sign out
                if firebaseManager.isSignedIn && firebaseManager.currentUser?.isAnonymous == true {
                    Button(action: {
                        signOutAndReset()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Quitter le mode invité")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(12)
                        .padding()
                        .shadow(color: .red.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInView()
                .environmentObject(firebaseManager)
        }
    }
    
    // MARK: - User Account Section (Connected)
    
    private var userAccountSection: some View {
        VStack(spacing: 24) {
            // User info with more detail
            VStack(spacing: 12) {
                if let photoURL = firebaseManager.currentUser?.photoURL {
                    AsyncImage(url: photoURL) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 4) {
                    if let displayName = firebaseManager.userDisplayName {
                        Text(displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                    } else if firebaseManager.currentUser?.isAnonymous == true {
                        Text("Utilisateur Invité")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    if let email = firebaseManager.userEmail {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(firebaseManager.currentUser?.isAnonymous == true ? Color.orange : Color.green)
                        .frame(width: 8, height: 8)
                    Text(firebaseManager.currentUser?.isAnonymous == true ? "Mode Invité" : "Compte vérifié")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            }
            .padding(.top)
            
            // Stats summary in the profile header
            HStack(spacing: 20) {
                VStack {
                    Text("\(progressTracker.totalXP)")
                        .font(.headline)
                    Text("XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider().frame(height: 30)
                
                VStack {
                    Text("\(progressTracker.getUserLevel())")
                        .font(.headline)
                    Text("Niveau")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider().frame(height: 30)
                
                VStack {
                    Text("\(progressTracker.dailyStreak)")
                        .font(.headline)
                    Text("Jours")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            
            // Sign out button
            Button(action: {
                signOutAndReset()
            }) {
                HStack {
                    Image(systemName: "arrow.right.square")
                    Text("Se déconnecter")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red)
                .cornerRadius(12)
                .shadow(color: .red.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private func signOutAndReset() {
        // 1. Sign out from Firebase
        try? firebaseManager.signOut()
        
        // 2. Reset onboarding status in SwiftData
        if let entry = onboardingEntries.first {
            entry.hasCompletedOnboarding = false
            try? modelContext.save()
        }
        
        // 3. Reset onboarding status in UserDefaults (fallback)
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        // 4. Close profile view
        dismiss()
    }
    
    // MARK: - Sign In Prompt (Not Connected)
    
    private var signInPromptSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)
                
                Text("Non connecté")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Connectez-vous pour synchroniser vos progrès sur tous vos appareils")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.vertical)
            
            VStack(spacing: 12) {
                // Sign In with Apple button
                SignInWithAppleButton {
                    print("User signed in with Apple!")
                }
                
                // Email Sign In button
                Button(action: { showEmailSignIn = true }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Connexion avec Email")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(16)
                }
                
                // Anonymous Sign In button
                Button(action: signInAnonymously) {
                    HStack {
                        Image(systemName: "person.fill.questionmark")
                        Text("Mode invité")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.gray)
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal, 32)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func signInAnonymously() {
        Task {
            do {
                try await firebaseManager.signInAnonymously()
            } catch {
                print("❌ Error signing in anonymously: \(error)")
            }
        }
    }
}

// MARK: - StatCard est maintenant défini de manière publique dans DashboardComponents.swift

struct BadgeCard: View {
    let emoji: String
    let title: String
    let unlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 40))
                .opacity(unlocked ? 1.0 : 0.3)
            
            Text(title)
                .font(.caption2)
                .fontWeight(unlocked ? .semibold : .regular)
                .foregroundColor(unlocked ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(unlocked ? Color.green.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(unlocked ? Color.green : Color.clear, lineWidth: 2)
        )
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding()
        .contentShape(Rectangle())
    }
}

#Preview {
    ProfileView()
}
