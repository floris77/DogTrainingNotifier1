import XCTest
@testable import DogTrainingNotifier

final class MatchManagerTests: XCTestCase {
    var matchManager: MatchManager!
    var mockOrwejaService: MockOrwejaService!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        mockOrwejaService = MockOrwejaService()
        mockUserDefaults = UserDefaults(suiteName: "testDefaults")!
        matchManager = MatchManager(
            orwejaService: mockOrwejaService,
            userDefaults: mockUserDefaults
        )
    }
    
    override func tearDown() {
        matchManager = nil
        mockOrwejaService = nil
        mockUserDefaults = nil
        super.tearDown()
    }
    
    func testFetchMatchesSuccess() async {
        // Given
        let expectedMatches = [
            Match(title: "Test Match 1", type: .map, location: "Location 1", address: "Address 1", startTime: Date(), matchDate: Date(), description: "Description 1", enrollmentStartDate: Date(), enrollmentEndDate: Date(), maxParticipants: 10, organizingClub: "Club 1"),
            Match(title: "Test Match 2", type: .sjp, location: "Location 2", address: "Address 2", startTime: Date(), matchDate: Date(), description: "Description 2", enrollmentStartDate: Date(), enrollmentEndDate: Date(), maxParticipants: 20, organizingClub: "Club 2")
        ]
        mockOrwejaService.mockMatches = expectedMatches
        
        // When
        await matchManager.fetchMatches()
        
        // Then
        XCTAssertEqual(matchManager.matches.count, 2)
        XCTAssertEqual(matchManager.matches[0].title, "Test Match 1")
        XCTAssertEqual(matchManager.matches[1].title, "Test Match 2")
        XCTAssertFalse(matchManager.isLoading)
        XCTAssertNil(matchManager.error)
    }
    
    func testFetchMatchesFailure() async {
        // Given
        mockOrwejaService.shouldFail = true
        
        // When
        await matchManager.fetchMatches()
        
        // Then
        XCTAssertTrue(matchManager.error is MatchError)
        XCTAssertFalse(matchManager.isLoading)
    }
    
    func testFilteredMatches() async {
        // Given
        let matches = [
            Match(title: "Test Match 1", type: .map, location: "Location 1", address: "Address 1", startTime: Date(), matchDate: Date(), description: "Description 1", enrollmentStartDate: Date(), enrollmentEndDate: Date(), maxParticipants: 10, organizingClub: "Club 1"),
            Match(title: "Test Match 2", type: .sjp, location: "Location 2", address: "Address 2", startTime: Date(), matchDate: Date(), description: "Description 2", enrollmentStartDate: Date(), enrollmentEndDate: Date(), maxParticipants: 20, organizingClub: "Club 2")
        ]
        mockOrwejaService.mockMatches = matches
        await matchManager.fetchMatches()
        
        // When
        matchManager.selectedType = .map
        let filteredMatches = matchManager.filteredMatches
        
        // Then
        XCTAssertEqual(filteredMatches.count, 1)
        XCTAssertEqual(filteredMatches[0].type, .map)
    }
    
    func testRegisterAndUnregisterMatch() async {
        // Given
        let match = Match(title: "Test Match", type: .map, location: "Location", address: "Address", startTime: Date(), matchDate: Date(), description: "Description", enrollmentStartDate: Date(), enrollmentEndDate: Date(), maxParticipants: 10, organizingClub: "Club")
        
        // When
        await matchManager.registerForMatch(match)
        XCTAssertTrue(matchManager.isRegistered(for: match))
        
        await matchManager.unregisterFromMatch(match)
        XCTAssertFalse(matchManager.isRegistered(for: match))
    }
}

// MARK: - Mock OrwejaService
class MockOrwejaService: OrwejaService {
    var mockMatches: [Match] = []
    var shouldFail = false
    
    override func fetchMatches() async throws -> [Match] {
        if shouldFail {
            throw MatchError.networkError
        }
        return mockMatches
    }
} 