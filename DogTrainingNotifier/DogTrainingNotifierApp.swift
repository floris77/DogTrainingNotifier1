import SwiftUI

@main
struct DogTrainingNotifierApp: App {
    @StateObject private var matchManager = MatchManagerWrapper()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(matchManager)
        }
    }
}
