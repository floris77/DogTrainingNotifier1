import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var matchManager: MatchManager
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Algemeen")) {
                    Toggle("Notificaties inschakelen", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                }
                
                if notificationsEnabled {
                    Section(header: Text("Notificaties voor")) {
                        Text("Wanneer inschrijving opent")
                        Text("24 uur voor wedstrijd")
                        Text("1 week voor wedstrijd")
                    }
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Notificatie instellingen")
            .navigationBarItems(trailing: Button("Gereed") { dismiss() })
            .alert("Notificatie toestemming", isPresented: $showingPermissionAlert) {
                Button("Instellingen", role: .none) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Annuleren", role: .cancel) {
                    notificationsEnabled = false
                }
            } message: {
                Text("Om notificaties te ontvangen moet je toestemming geven in de instellingen.")
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    showingPermissionAlert = true
                }
            }
        }
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
            .environmentObject(MatchManager())
    }
}
