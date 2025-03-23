import SwiftUI

struct MatchListView: View {
    @EnvironmentObject private var matchManager: MatchManager
    @State private var showingFilters = false
    @State private var showingError = false
    @State private var selectedMatch: Match?
    
    var body: some View {
        NavigationView {
            ZStack {
                if matchManager.isLoading {
                    LoadingView(message: "Wedstrijden laden...")
                } else {
                    List {
                        if let error = matchManager.error {
                            ErrorView(error: error) {
                                Task {
                                    await matchManager.fetchMatches()
                                }
                            }
                        } else if matchManager.filteredMatches.isEmpty {
                            EmptyStateView(
                                title: "Geen wedstrijden gevonden",
                                message: hasActiveFilters ?
                                    "Probeer andere filters" :
                                    "Trek omlaag om te verversen"
                            )
                        } else {
                            ForEach(matchManager.filteredMatches) { match in
                                MatchRowView(match: match)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedMatch = match
                                    }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await matchManager.fetchMatches()
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
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView()
            }
            .sheet(item: $selectedMatch) { match in
                MatchDetailView(match: match)
            }
        }
    }
    
    private var hasActiveFilters: Bool {
        !matchManager.searchText.isEmpty ||
        matchManager.selectedType != nil ||
        matchManager.selectedEnrollmentStatus != nil
    }
}

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Opnieuw proberen", action: retryAction)
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    MatchListView()
        .environmentObject(MatchManager())
}
