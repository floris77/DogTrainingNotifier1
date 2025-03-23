import SwiftUI

struct MatchRowView: View {
    let match: Match
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: match.matchDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(match.title)
                    .font(.headline)
                    .lineLimit(2)
                Spacer()
                Text(match.type.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "calendar")
                Text(formattedDate)
                if let startTime = match.startTime {
                    Text("om \(startTime)")
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "location")
                Text(match.location)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "person.2")
                Text(match.organizingClub)
                if let coOrganizer = match.coOrganizer {
                    Text("i.s.m. \(coOrganizer)")
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            HStack {
                Text(match.enrollmentStatus.description)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(match.enrollmentStatus.color.opacity(0.2))
                    .foregroundColor(match.enrollmentStatus.color)
                    .cornerRadius(8)
                
                Spacer()
                
                if let price = match.price {
                    Text("€ \(String(format: "%.2f", price))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct MatchRowView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMatch = Match(
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
        )
        
        MatchRowView(match: sampleMatch)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
