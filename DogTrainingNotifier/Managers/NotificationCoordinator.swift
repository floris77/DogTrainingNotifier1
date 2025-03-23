import Foundation
import UserNotifications

@MainActor
final class NotificationCoordinator {
    private let notificationCenter: UNUserNotificationCenter
    private let userDefaults: UserDefaults
    
    init(
        notificationCenter: UNUserNotificationCenter = .current(),
        userDefaults: UserDefaults = .standard
    ) {
        self.notificationCenter = notificationCenter
        self.userDefaults = userDefaults
        
        // Set default values if not set
        if !userDefaults.contains(key: "notifyNewMatches") {
            userDefaults.set(true, forKey: "notifyNewMatches")
        }
        if !userDefaults.contains(key: "notifyEnrollmentStart") {
            userDefaults.set(true, forKey: "notifyEnrollmentStart")
        }
        if !userDefaults.contains(key: "notifyEnrollmentEnd") {
            userDefaults.set(true, forKey: "notifyEnrollmentEnd")
        }
        if !userDefaults.contains(key: "notifyMatchStart") {
            userDefaults.set(true, forKey: "notifyMatchStart")
        }
    }
    
    func requestAuthorization() async throws -> Bool {
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus != .authorized else { return true }
        
        return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    func scheduleMatchNotifications(for match: Match) {
        guard userDefaults.bool(forKey: "notificationsEnabled") else { return }
        
        // Enrollment start notification
        if userDefaults.bool(forKey: "notifyEnrollmentStart"),
           let startDate = match.enrollmentStartDate,
           startDate > Date() {
            scheduleNotification(
                identifier: "enrollment-start-\(match.id)",
                title: "Inschrijving opent",
                body: "De inschrijving voor '\(match.title)' opent nu",
                date: startDate
            )
            
            // Also schedule a 24-hour advance notice
            scheduleNotification(
                identifier: "enrollment-start-24h-\(match.id)",
                title: "Inschrijving opent binnenkort",
                body: "De inschrijving voor '\(match.title)' opent morgen",
                date: startDate.addingTimeInterval(-86400)
            )
        }
        
        // Enrollment end notification
        if userDefaults.bool(forKey: "notifyEnrollmentEnd"),
           let endDate = match.enrollmentEndDate,
           endDate > Date() {
            scheduleNotification(
                identifier: "enrollment-end-\(match.id)",
                title: "Inschrijving sluit",
                body: "De inschrijving voor '\(match.title)' sluit over 24 uur",
                date: endDate.addingTimeInterval(-86400)
            )
        }
        
        // Match date notification
        if userDefaults.bool(forKey: "notifyMatchStart") {
            scheduleNotification(
                identifier: "match-date-\(match.id)",
                title: "Wedstrijd herinnering",
                body: "De wedstrijd '\(match.title)' is morgen",
                date: match.matchDate.addingTimeInterval(-86400)
            )
        }
    }
    
    func scheduleNewMatchNotification(for match: Match) {
        guard userDefaults.bool(forKey: "notificationsEnabled"),
              userDefaults.bool(forKey: "notifyNewMatches") else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Nieuwe wedstrijd"
        content.body = "Er is een nieuwe \(match.type.description) toegevoegd: '\(match.title)'"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "new-match-\(match.id)",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request)
    }
    
    func removeMatchNotifications(for match: Match) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            "enrollment-start-\(match.id)",
            "enrollment-start-24h-\(match.id)",
            "enrollment-end-\(match.id)",
            "match-date-\(match.id)",
            "new-match-\(match.id)"
        ])
    }
    
    func handleNotificationPermissionChange() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            if settings.authorizationStatus != .authorized {
                // Show settings prompt
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    
    private func scheduleNotification(
        identifier: String,
        title: String,
        body: String,
        date: Date
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request)
    }
}

private extension UserDefaults {
    func contains(key: String) -> Bool {
        object(forKey: key) != nil
    }
} 