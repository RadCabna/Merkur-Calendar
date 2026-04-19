import SwiftUI

struct MainTabView: View {
    @State private var viewModel = MainTabViewModel()
    @Environment(AuthViewModel.self) private var authVM
    @Environment(EventsStore.self) private var eventsStore

    private var barHeight: CGFloat { screenHeight * 0.105 }
    private var createSize: CGFloat { screenHeight * 0.077 }

    var body: some View {
        ZStack(alignment: .bottom) {
            Image("appBG")
                .resizable()
                .ignoresSafeArea()

            NavigationStack {
                Group {
                    switch viewModel.selectedTab {
                    case .home:    HomeView(onViewAll: { viewModel.showEventList = true })
                    case .events:  EventsView()
                    case .bonuses: BonusesView()
                    case .profile: ProfileView()
                    }
                }
                .transaction(value: viewModel.selectedTab) { $0.animation = nil }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: barHeight + createSize * 0.5)
            }

            BottomBarView(
                viewModel: viewModel,
                onCreateTap: { viewModel.showCreate = true }
            )
            .padding(.bottom, 8)
        }
        .fullScreenCover(isPresented: $viewModel.showCreate) {
            CreateEventView()
                .environment(eventsStore)
        }
        .fullScreenCover(isPresented: $viewModel.showEventList) {
            EventListView()
                .environment(eventsStore)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AuthViewModel())
        .environment(EventsStore())
}
