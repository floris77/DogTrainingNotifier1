import Foundation
import SwiftUI

public struct Match: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let type: MatchType
    public let location: String
    public let address: String
    public let startTime: String?
    public let matchDate: Date
    public let description: String
    public let enrollmentStartDate: Date?
    public let enrollmentEndDate: Date?
    public let maxParticipants: Int
    public let currentParticipants: Int
    public let additionalInfo: String?
    public let requirements: String?
    public let price: Double?
    public let organizingClub: String
    public let coOrganizer: String?
    public let latitude: Double?
    public let longitude: Double?
    
    public init(
        id: String,
        title: String,
        type: MatchType,
        location: String,
        address: String,
        startTime: String?,
        matchDate: Date,
        description: String,
        enrollmentStartDate: Date?,
        enrollmentEndDate: Date?,
        maxParticipants: Int,
        currentParticipants: Int,
        additionalInfo: String?,
        requirements: String?,
        price: Double?,
        organizingClub: String,
        coOrganizer: String?,
        latitude: Double?,
        longitude: Double?
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.location = location
        self.address = address
        self.startTime = startTime
        self.matchDate = matchDate
        self.description = description
        self.enrollmentStartDate = enrollmentStartDate
        self.enrollmentEndDate = enrollmentEndDate
        self.maxParticipants = maxParticipants
        self.currentParticipants = currentParticipants
        self.additionalInfo = additionalInfo
        self.requirements = requirements
        self.price = price
        self.organizingClub = organizingClub
        self.coOrganizer = coOrganizer
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public var enrollmentStatus: EnrollmentStatus {
        if let startDate = enrollmentStartDate {
            if Date() < startDate {
                return .upcoming
            }
        }
        
        if let endDate = enrollmentEndDate {
            if Date() > endDate {
                return .closed
            }
        }
        
        if currentParticipants >= maxParticipants && maxParticipants > 0 {
            return .full
        }
        
        return .open
    }
}

public enum MatchType: String, Codable, Hashable, CaseIterable {
    case map = "MAP"
    case sjp = "SJP"
    case veldproef = "Veldproef"
    case workingTest = "Working Test"
    case jeugdproef = "Jeugdproef"
}

public enum EnrollmentStatus: Codable, Hashable {
    case open
    case closed
    case full
    case upcoming
    
    public var description: String {
        switch self {
        case .open:
            return "Open voor inschrijving"
        case .closed:
            return "Gesloten"
        case .full:
            return "Vol"
        case .upcoming:
            return "Binnenkort open"
        }
    }
    
    public var color: Color {
        switch self {
        case .open:
            return .green
        case .closed:
            return .red
        case .full:
            return .orange
        case .upcoming:
            return .blue
        }
    }
}
