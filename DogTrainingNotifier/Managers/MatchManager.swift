import Foundation
import SwiftUI

@MainActor
final class MatchManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var matches: [Match] = []
    @Published var selectedType: MatchType?
    @Published var searchText = ""
    @Published var selectedEnrollmentStatus: EnrollmentStatus?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var registeredMatches: [Match] = []
    
    // MARK: - Private Properties
    private let orwejaService: OrwejaService
    
    // MARK: - Initialization
    init(orwejaService: OrwejaService = OrwejaService()) {
        self.orwejaService = orwejaService
    }
    
    // MARK: - Public Methods
    func fetchMatches() async {
        isLoading = true
        error = nil
        
        do {
            matches = try await orwejaService.fetchMatches()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func filteredMatches() -> [Match] {
        matches.filter { match in
            var typeMatches = true
            var statusMatches = true
            var searchMatches = true
            
            if let selectedType = selectedType {
                typeMatches = match.type == selectedType
            }
            
            if let selectedStatus = selectedEnrollmentStatus {
                statusMatches = match.enrollmentStatus == selectedStatus
            }
            
            if !searchText.isEmpty {
                searchMatches = match.title.localizedCaseInsensitiveContains(searchText) ||
                              match.location.localizedCaseInsensitiveContains(searchText) ||
                              match.organizingClub.localizedCaseInsensitiveContains(searchText)
            }
            
            return typeMatches && statusMatches && searchMatches
        }.sorted { $0.matchDate < $1.matchDate }
    }
    
    func upcomingMatches() -> [Match] {
        matches.filter { $0.enrollmentStatus == .upcoming }
               .sorted { $0.matchDate < $1.matchDate }
    }
    
    func retryFetch() {
        Task {
            await fetchMatches()
        }
    }
    
    func registerForMatch(_ match: Match) async {
        guard !isRegistered(for: match) else { return }
        registeredMatches.append(match)
    }
    
    func unregisterFromMatch(_ match: Match) async {
        registeredMatches.removeAll { $0.id == match.id }
    }
    
    func isRegistered(for match: Match) -> Bool {
        registeredMatches.contains { $0.id == match.id }
    }
    
    // MARK: - Helper Methods
    private func clearError() {
        error = nil
    }
    
    private func setError(_ error: Error) {
        self.error = error
    }
}
