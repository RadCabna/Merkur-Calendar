import SwiftUI

struct RootView: View {
    @State private var authVM = AuthViewModel()
    @State private var eventsStore = EventsStore()

    var body: some View {
        Group {
            if authVM.isLoggedIn {
                MainTabView()
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
        .environment(authVM)
        .environment(eventsStore)
        .onChange(of: authVM.isLoggedIn) { _, loggedIn in
            if loggedIn {
                eventsStore = EventsStore(username: authVM.currentUser?.username ?? "")
            }
        }
        .onAppear {
            if authVM.isLoggedIn {
                eventsStore = EventsStore(username: authVM.currentUser?.username ?? "")
            }
        }
    }
}

#Preview {
    RootView()
}
