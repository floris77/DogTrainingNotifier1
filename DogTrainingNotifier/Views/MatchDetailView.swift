import SwiftUI
import MapKit

struct MatchDetailView: View {
    @EnvironmentObject private var matchManager: MatchManager
    let match: Match
    @State private var region: MKCoordinateRegion
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    init(match: Match) {
        self.match = match
        let coordinate = CLLocationCoordinate2D(latitude: match.latitude ?? 0, longitude: match.longitude ?? 0)
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Match Type and Date
                HStack {
                    Text(match.type.rawValue)
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                    Text(match.matchDate, style: .date)
                        .font(.subheadline)
                }
                
                // Title
                Text(match.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                // Location and Map
                if let latitude = match.latitude, let longitude = match.longitude {
                    Map(coordinateRegion: $region, annotationItems: [match]) { match in
                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    }
                    .frame(height: 200)
                    .cornerRadius(10)
                }
                
                // Address
                if !match.address.isEmpty {
                    Text(match.address)
                        .font(.subheadline)
                }
                
                // Description
                if !match.description.isEmpty {
                    Text("Beschrijving")
                        .font(.headline)
                    Text(match.description)
                }
                
                // Requirements
                if !match.requirements.isEmpty {
                    Text("Vereisten")
                        .font(.headline)
                    Text(match.requirements)
                }
                
                // Additional Info
                if !match.additionalInfo.isEmpty {
                    Text("Extra informatie")
                        .font(.headline)
                    Text(match.additionalInfo)
                }
                
                // Enrollment Status
                VStack(alignment: .leading) {
                    Text("Inschrijving")
                        .font(.headline)
                    Text(match.enrollmentStatus.description)
                        .foregroundColor(match.enrollmentStatus.color)
                }
                
                // Price
                if let price = match.price {
                    Text("Prijs: €\(String(format: "%.2f", price))")
                        .font(.subheadline)
                }
                
                // Organization
                VStack(alignment: .leading) {
                    Text("Organisatie")
                        .font(.headline)
                    Text(match.organizingClub)
                    if let coOrganizer = match.coOrganizer {
                        Text("Mede-organisator: \(coOrganizer)")
                    }
                }
                
                // Registration Button
                if match.enrollmentStatus == .open {
                    Button {
                        Task {
                            if matchManager.isRegistered(for: match) {
                                await matchManager.unregisterFromMatch(match)
                                alertTitle = "Uitgeschreven"
                                alertMessage = "Je bent uitgeschreven voor deze wedstrijd"
                            } else {
                                await matchManager.registerForMatch(match)
                                alertTitle = "Ingeschreven"
                                alertMessage = "Je bent ingeschreven voor deze wedstrijd"
                            }
                            showingAlert = true
                        }
                    } label: {
                        Text(matchManager.isRegistered(for: match) ? "Uitschrijven" : "Inschrijven")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}

struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = MatchManager()
        let sampleMatch = Match(
            id: UUID().uuidString,
            title: "Sample Match",
            type: .map,
            location: "Amsterdam",
            address: "Amstelpark 1, 1083 HZ Amsterdam",
            startTime: "10:00",
            matchDate: Date(),
            description: "A sample match description",
            enrollmentStartDate: Date(),
            enrollmentEndDate: Date().addingTimeInterval(86400),
            maxParticipants: 20,
            currentParticipants: 10,
            additionalInfo: "Additional information",
            requirements: "Must have a dog",
            price: 50.0,
            organizingClub: "Sample Club",
            coOrganizer: "Co-organizer",
            latitude: 52.3376,
            longitude: 4.8886
        )
        
        MatchDetailView(match: sampleMatch)
            .environmentObject(manager)
    }
}
