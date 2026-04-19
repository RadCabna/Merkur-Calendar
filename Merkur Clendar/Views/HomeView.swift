import SwiftUI

struct HomeView: View {
    var onViewAll: () -> Void = {}
    @State private var viewModel = HomeViewModel()
    @Environment(EventsStore.self) private var eventsStore
    @Environment(AuthViewModel.self) private var authVM

    var body: some View {
        ZStack {
            Image("appBG")
                .resizable()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: screenHeight * 0.025) {
                    UserHeaderView(
                        profile: viewModel.userProfile,
                        username: authVM.currentUser?.username,
                        photoData: authVM.currentUser?.photoData
                    )
                    LevelCardView(profile: viewModel.userProfile)
                    if let event = eventsStore.nextEvent {
                        VStack(alignment: .leading, spacing: screenHeight * 0.012) {
                            HStack {
                                Text("NEXT EVENT")
                                    .font(.poppinsSemiBold(size: screenHeight * 0.02))
                                    .foregroundStyle(Color("gold"))
                                Spacer()
                                Button("VIEW ALL", action: onViewAll)
                                    .font(.poppinsSemiBold(size: screenHeight * 0.016))
                                    .foregroundStyle(Color("gold"))
                                    .buttonStyle(.plain)
                            }
                            NextEventCardView(event: event)
                        }
                    }
                    LoyaltyProgressView(currentLevel: viewModel.userProfile.loyaltyLevel)
                }
                .padding(.horizontal, screenHeight * 0.02)
                .padding(.top, screenHeight * 0.025)
                .padding(.bottom, screenHeight * 0.16)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    HomeView()
        .environment(EventsStore())
        .environment(AuthViewModel())
}
