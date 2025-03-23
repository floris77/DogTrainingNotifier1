import SwiftUI

struct RegistrationsView: View {
    @EnvironmentObject private var matchManager: MatchManager
    
    var body: some View {
        NavigationView {
            List {
                if matchManager.registeredMatches.isEmpty {
                    Text("Geen inschrijvingen")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(matchManager.registeredMatches) { match in
                        MatchRowView(match: match)
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task {
                                        await matchManager.unregisterFromMatch(match)
                                    }
                                } label: {
                                    Label("Uitschrijven", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .navigationTitle("Mijn inschrijvingen")
            .refreshable {
                await matchManager.fetchMatches()
            }
        }
    }
}

struct RegistrationsView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationsView()
            .environmentObject(MatchManager())
    }
}
