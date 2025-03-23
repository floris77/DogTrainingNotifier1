import SwiftUI

struct MatchListView: View {
    @EnvironmentObject private var matchManager: MatchManager
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            List {
                if matchManager.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if matchManager.filteredMatches().isEmpty {
                    Text("Geen wedstrijden gevonden")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(matchManager.filteredMatches()) { match in
                        NavigationLink(destination: MatchDetailView(match: match)) {
                            MatchRowView(match: match)
                        }
                    }
                }
            }
            .navigationTitle("Wedstrijden")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView()
            }
            .refreshable {
                await matchManager.fetchMatches()
            }
        }
    }
}

struct MatchListView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = MatchManager()
        MatchListView()
            .environmentObject(manager)
            .task {
                await manager.fetchMatches()
            }
    }
}
