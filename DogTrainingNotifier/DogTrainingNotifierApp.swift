import SwiftUI

@main
struct DogTrainingNotifierApp: App {
    @StateObject private var matchManager = MatchManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(matchManager)
        }
    }
}
