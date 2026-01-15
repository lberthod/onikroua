import SwiftUI

struct PermissionsScreen: View {
    @Binding var notificationsEnabled: Bool
    @Binding var preferredTime: Date?
    let onComplete: () -> Void
    
    @State private var selectedHour: Int = 19
    @State private var notificationManager = NotificationManager()
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("🔔")
                    .font(.system(size: 80))
                
                Text("Reste motivé avec des rappels")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Nous t'enverrons des rappels quotidiens pour maintenir ton streak")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            VStack(spacing: 20) {
                Toggle(isOn: $notificationsEnabled) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Notifications quotidiennes")
                                .font(.headline)
                            Text("Rappels pour maintenir ton streak")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                if notificationsEnabled {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.orange)
                            Text("Heure préférée pour étudier")
                                .font(.headline)
                            Spacer()
                        }
                        
                        Picker("Heure", selection: $selectedHour) {
                            ForEach(6..<24) { hour in
                                Text("\(hour):00")
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            
            VStack(spacing: 16) {
                OnboardingNotificationBenefit(
                    icon: "flame.fill",
                    text: "Ne perds jamais ton streak",
                    color: .orange
                )
                
                OnboardingNotificationBenefit(
                    icon: "trophy.fill",
                    text: "Sois notifié des badges débloqués",
                    color: .yellow
                )
                
                OnboardingNotificationBenefit(
                    icon: "chart.line.uptrend.xyaxis",
                    text: "Reçois tes progrès hebdomadaires",
                    color: .green
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                // Demander les notifications de manière asynchrone sans bloquer la transition
                Task {
                    if notificationsEnabled {
                        let granted = await notificationManager.requestAuthorization()
                        if granted {
                            notificationManager.scheduleDailyReminder(at: selectedHour)
                            notificationManager.scheduleStreakWarning()
                            
                            let calendar = Calendar.current
                            var components = DateComponents()
                            components.hour = selectedHour
                            components.minute = 0
                            preferredTime = calendar.date(from: components)
                        }
                    }
                }
                // Transition immédiate vers l'app principale
                onComplete()
            }) {
                HStack {
                    Text("C'est parti !")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Button(action: {
                onComplete()
            }) {
                Text("Pas maintenant")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct OnboardingNotificationBenefit: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}
