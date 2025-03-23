import SwiftUI

struct UpcomingView: View {
    @EnvironmentObject private var matchManager: MatchManager
    
    var body: some View {
        NavigationView {
            List {
                if matchManager.upcomingMatches().isEmpty {
                    Text("Geen aankomende wedstrijden")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(matchManager.upcomingMatches()) { match in
                        NavigationLink(destination: MatchDetailView(match: match)) {
                            MatchRowView(match: match)
                        }
                    }
                }
            }
            .navigationTitle("Aankomende wedstrijden")
            .refreshable {
                await matchManager.fetchMatches()
            }
        }
    }
}

#Preview {
    NavigationView {
        UpcomingView()
            .environmentObject(MatchManager())
    }
}
