import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var onboardingCoordinator: OnboardingCoordinator
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "Orweja Match Notificaties",
            subtitle: "Welkom bij de Orweja Match Notificatie App",
            description: "Mis nooit meer een inschrijving voor jachthondenproeven. Ontvang direct notificaties wanneer inschrijvingen openen voor de wedstrijden die jou interesseren.",
            imageName: "bell.badge.fill",
            color: AppTheme.primaryGreen
        ),
        OnboardingPage(
            title: "Persoonlijke Voorkeuren",
            subtitle: "Stel je voorkeuren in",
            description: "Geef aan welke type wedstrijden je interesseren (MAP, SJP, PJP, etc.) en in welke regio's je actief bent.",
            imageName: "slider.horizontal.3",
            color: AppTheme.secondaryGreen
        ),
        OnboardingPage(
            title: "Snel Inschrijven",
            subtitle: "Direct naar Orweja",
            description: "Vind alle relevante informatie en directe links naar de Orweja inschrijfpagina voor elke wedstrijd. Geen zoektocht meer op de Orweja website.",
            imageName: "link.circle.fill",
            color: AppTheme.primaryGreen
        )
    ]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                VStack(spacing: 20) {
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            onboardingCoordinator.hasCompletedOnboarding = true
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Volgende" : "Aan de slag")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryGreen)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(page.color)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(page.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(page.color)
                    
                    Text(page.subtitle)
                        .font(.title2)
                        .bold()
                    
                    Text(page.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(OnboardingCoordinator())
}
