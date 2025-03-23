import SwiftUI

struct MatchRowView: View {
    let match: Match
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(match.type.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                enrollmentStatusBadge
            }
            
            Text(match.title)
                .font(.headline)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "calendar")
                Text(match.date.formatted(date: .abbreviated, time: .shortened))
                
                Spacer()
                
                Image(systemName: "location")
                Text(match.location)
                    .lineLimit(1)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            if match.isEnrolled {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Ingeschreven")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var enrollmentStatusBadge: some View {
        Text(match.enrollmentStatus.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(enrollmentStatusColor.opacity(0.2))
            .foregroundColor(enrollmentStatusColor)
            .cornerRadius(8)
    }
    
    private var enrollmentStatusColor: Color {
        switch match.enrollmentStatus {
        case .open:
            return .green
        case .closed:
            return .red
        case .waitlist:
            return .orange
        }
    }
}

#Preview {
    List {
        MatchRowView(match: Match.preview)
    }
    .listStyle(.plain)
} 