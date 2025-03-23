import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var matchManager: MatchManager
    
    var body: some View {
        TabView {
            MatchListView()
                .tabItem {
                    Label("Wedstrijden", systemImage: "list.bullet")
                }
            
            UpcomingView()
                .tabItem {
                    Label("Aankomend", systemImage: "calendar")
                }
            
            RegistrationsView()
                .tabItem {
                    Label("Inschrijvingen", systemImage: "person.fill")
                }
        }
        .task {
            await matchManager.fetchMatches()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MatchManager())
    }
}
