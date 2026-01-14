import SwiftUI

@main
struct onykrouaApp: App {
    @StateObject private var appEnvironment = AppEnvironment.shared
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
                    .environmentObject(appEnvironment)
            } else {
                ContentView()
                    .environmentObject(appEnvironment)
            }
        }
    }
}
