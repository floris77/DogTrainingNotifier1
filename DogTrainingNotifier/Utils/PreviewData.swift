import Foundation

struct PreviewData {
    static let sampleMatches: [Match] = [
        Match(
            id: "1",
            title: "SJP Haarlemmermeer",
            type: .sjp,
            location: "Haarlemmermeer",
            address: "Hoofdweg 1234",
            startTime: "09:00",
            matchDate: Date(),
            description: "Sample description",
            enrollmentStartDate: Date().addingTimeInterval(-86400),
            enrollmentEndDate: Date().addingTimeInterval(86400),
            maxParticipants: 20,
            currentParticipants: 10,
            additionalInfo: nil,
            requirements: nil,
            price: 45.0,
            organizingClub: "KNJV Haarlemmermeer",
            coOrganizer: "NOJG",
            latitude: nil,
            longitude: nil
        ),
        Match(
            id: "2",
            title: "MAP Proef Drenthe",
            type: .map,
            location: "Drenthe",
            address: "Jachtweg 56",
            startTime: "10:00",
            matchDate: Date().addingTimeInterval(86400 * 7),
            description: "MAP Proef",
            enrollmentStartDate: Date().addingTimeInterval(86400),
            enrollmentEndDate: Date().addingTimeInterval(86400 * 5),
            maxParticipants: 15,
            currentParticipants: 5,
            additionalInfo: nil,
            requirements: nil,
            price: 55.0,
            organizingClub: "KNJV Drenthe",
            coOrganizer: nil,
            latitude: nil,
            longitude: nil
        ),
        Match(
            id: "3",
            title: "Working Test Friesland",
            type: .workingTest,
            location: "Leeuwarden",
            address: "Sportlaan 123",
            startTime: "08:30",
            matchDate: Date().addingTimeInterval(-86400 * 2),
            description: "Working Test voor alle klassen",
            enrollmentStartDate: Date().addingTimeInterval(-86400 * 30),
            enrollmentEndDate: Date().addingTimeInterval(-86400 * 3),
            maxParticipants: 25,
            currentParticipants: 25,
            additionalInfo: "Lunch inbegrepen",
            requirements: "B-diploma vereist",
            price: 65.0,
            organizingClub: "KC Friesland",
            coOrganizer: "KNJV Friesland",
            latitude: nil,
            longitude: nil
        )
    ]
}
