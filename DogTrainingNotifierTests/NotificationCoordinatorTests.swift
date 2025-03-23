import XCTest
import UserNotifications
@testable import DogTrainingNotifier

final class NotificationCoordinatorTests: XCTestCase {
    var coordinator: NotificationCoordinator!
    var mockNotificationCenter: MockUNUserNotificationCenter!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        mockNotificationCenter = MockUNUserNotificationCenter()
        mockUserDefaults = UserDefaults(suiteName: "testDefaults")!
        coordinator = NotificationCoordinator(
            notificationCenter: mockNotificationCenter,
            userDefaults: mockUserDefaults
        )
    }
    
    override func tearDown() {
        coordinator = nil
        mockNotificationCenter = nil
        mockUserDefaults = nil
        super.tearDown()
    }
    
    func testRequestAuthorization() async throws {
        // Given
        mockNotificationCenter.authorizationStatus = .notDetermined
        mockNotificationCenter.shouldGrantAuthorization = true
        
        // When
        let granted = try await coordinator.requestAuthorization()
        
        // Then
        XCTAssertTrue(granted)
        XCTAssertTrue(mockNotificationCenter.didRequestAuthorization)
    }
    
    func testScheduleMatchNotifications() {
        // Given
        let match = Match(
            title: "Test Match",
            type: .map,
            location: "Location",
            address: "Address",
            startTime: Date(),
            matchDate: Date().addingTimeInterval(86400),
            description: "Description",
            enrollmentStartDate: Date().addingTimeInterval(3600),
            enrollmentEndDate: Date().addingTimeInterval(7200),
            maxParticipants: 10,
            organizingClub: "Club"
        )
        mockUserDefaults.set(true, forKey: "notificationsEnabled")
        mockUserDefaults.set(true, forKey: "notifyEnrollmentStart")
        mockUserDefaults.set(true, forKey: "notifyEnrollmentEnd")
        mockUserDefaults.set(true, forKey: "notifyMatchStart")
        
        // When
        coordinator.scheduleMatchNotifications(for: match)
        
        // Then
        XCTAssertEqual(mockNotificationCenter.pendingNotificationRequests.count, 4)
    }
    
    func testRemoveMatchNotifications() {
        // Given
        let match = Match(
            title: "Test Match",
            type: .map,
            location: "Location",
            address: "Address",
            startTime: Date(),
            matchDate: Date(),
            description: "Description",
            enrollmentStartDate: Date(),
            enrollmentEndDate: Date(),
            maxParticipants: 10,
            organizingClub: "Club"
        )
        
        // When
        coordinator.removeMatchNotifications(for: match)
        
        // Then
        XCTAssertEqual(mockNotificationCenter.removedNotificationIdentifiers.count, 5)
    }
}

// MARK: - Mock UNUserNotificationCenter
class MockUNUserNotificationCenter: UNUserNotificationCenter {
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var shouldGrantAuthorization = false
    var didRequestAuthorization = false
    var pendingNotificationRequests: [UNNotificationRequest] = []
    var removedNotificationIdentifiers: [String] = []
    
    override func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        let settings = MockUNNotificationSettings(authorizationStatus: authorizationStatus)
        completionHandler(settings)
    }
    
    override func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        didRequestAuthorization = true
        completionHandler(shouldGrantAuthorization, nil)
    }
    
    override func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)? = nil) {
        pendingNotificationRequests.append(request)
        completionHandler?(nil)
    }
    
    override func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedNotificationIdentifiers.append(contentsOf: identifiers)
    }
}

class MockUNNotificationSettings: UNNotificationSettings {
    private let mockAuthorizationStatus: UNAuthorizationStatus
    
    init(authorizationStatus: UNAuthorizationStatus) {
        self.mockAuthorizationStatus = authorizationStatus
        super.init()
    }
    
    override var authorizationStatus: UNAuthorizationStatus {
        return mockAuthorizationStatus
    }
} 