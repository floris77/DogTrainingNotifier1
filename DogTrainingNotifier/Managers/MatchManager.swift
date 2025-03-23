import Foundation
import SwiftUI

enum MatchError: LocalizedError {
    case networkError
    case invalidData
    case locationError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Er is een probleem met de internetverbinding. Controleer je verbinding en probeer het opnieuw."
        case .invalidData:
            return "De wedstrijdgegevens zijn niet correct. Probeer het later opnieuw."
        case .locationError:
            return "Er is een probleem met de locatie. Controleer of locatietoegang is ingeschakeld."
        }
    }
}

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
    private var isOffline = false
    
    // MARK: - Initialization
    init(orwejaService: OrwejaService = OrwejaService()) {
        self.orwejaService = orwejaService
    }
    
    // MARK: - Public Methods
    func fetchMatches() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let oldMatches = Set(matches.map(\.id))
            matches = try await orwejaService.fetchMatches()
            lastRefreshDate = Date()
            isOffline = false
            cacheMatches()
        } catch {
            self.error = MatchError.networkError
            isOffline = true
            loadCachedMatches()
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
    
    private func cacheMatches() {
        if let encoded = try? JSONEncoder().encode(matches) {
            userDefaults.set(encoded, forKey: "cachedMatches")
        }
    }
    
    private func loadCachedMatches() {
        if let data = userDefaults.data(forKey: "cachedMatches"),
           let decoded = try? JSONDecoder().decode([Match].self, from: data) {
            matches = decoded
        }
    }
}
