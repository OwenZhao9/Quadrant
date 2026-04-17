import SwiftUI

@main
struct QuadrantApp: App {
    @State private var taskStore = TaskStore()
    @State private var settingsStore = SettingsStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(taskStore)
                .environment(settingsStore)
                .preferredColorScheme(settingsStore.colorScheme)
        }
    }
}
