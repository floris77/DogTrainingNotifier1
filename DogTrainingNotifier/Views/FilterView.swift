import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var matchManager: MatchManager
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Type wedstrijd")) {
                    Picker("Type", selection: $matchManager.selectedType) {
                        Text("Alle").tag(MatchType?.none)
                        ForEach(MatchType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(Optional(type))
                        }
                    }
                }
                
                Section(header: Text("Status")) {
                    Picker("Status", selection: $matchManager.selectedEnrollmentStatus) {
                        Text("Alle").tag(EnrollmentStatus?.none)
                        ForEach(EnrollmentStatus.allCases, id: \.self) { status in
                            Text(status.description).tag(Optional(status))
                        }
                    }
                }
                
                Section(header: Text("Zoeken")) {
                    TextField("Zoek op titel, locatie of club", text: $matchManager.searchText)
                }
            }
            .navigationTitle("Filters")
            .navigationBarItems(trailing: Button("Gereed") {
                dismiss()
            })
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = MatchManager()
        FilterView()
            .environmentObject(manager)
    }
}
