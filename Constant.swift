import Foundation

enum Constants {
    enum DateFormatters {
        static let defaultFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            formatter.locale = Locale(identifier: "nl_NL")
            formatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
            return formatter
        }()
        
        static let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.locale = Locale(identifier: "nl_NL")
            formatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
            return formatter
        }()
    }
    
    enum Calendar {
        static let current = Foundation.Calendar(identifier: .gregorian)
    }
    
    enum TimeIntervals {
        static let day: TimeInterval = 86400
        static let week: TimeInterval = 604800
        static let month: TimeInterval = 2592000
    }
    
    enum Enrollment {
        static let defaultStartDaysBeforeMatch = 30
        static let defaultEndDaysBeforeMatch = 7
    }
}
