import SwiftUI

struct MatchListView: View {
    @EnvironmentObject private var matchManager: MatchManager
    @State private var showingFilters = false
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if matchManager.isLoading {
                    ProgressView("Wedstrijden laden...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
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
                                NavigationLink(destination: MatchDetailView(match: match)) {
                                    MatchRowView(match: match)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await matchManager.fetchMatches()
                    }
                    .overlay {
                        if matchManager.isLoading {
                            ProgressView("Wedstrijden laden...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(.systemBackground))
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
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    MatchListView()
        .environmentObject(MatchManager())
}
