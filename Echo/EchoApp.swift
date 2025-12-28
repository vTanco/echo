import SwiftUI
import SwiftData

@main
struct EchoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            ComputeSession.self,
            EarningsRecord.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @Published var isComputeSessionActive: Bool = false
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Content View
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            ComputeSessionView()
                .tabItem {
                    Image(systemName: "cpu.fill")
                    Text("Compute")
                }
                .tag(1)
            
            EarningsHistoryView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Ganancias")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Ajustes")
                }
                .tag(3)
        }
        .tint(Color("AccentCyan"))
    }
}
