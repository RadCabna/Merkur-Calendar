import SwiftUI

struct EventListView: View {
    @Environment(EventsStore.self) private var eventsStore
    @State private var viewModel = EventListViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("appBG")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, screenHeight * 0.02)
                    .padding(.top, screenHeight * 0.015)
                    .padding(.bottom, screenHeight * 0.02)

                sortFilter
                    .padding(.horizontal, screenHeight * 0.02)
                    .padding(.bottom, screenHeight * 0.025)

                let sorted = viewModel.sortedEvents(eventsStore.events)
                if sorted.isEmpty {
                    Spacer()
                    Text("No upcoming events")
                        .font(.poppinsExtraLight(size: screenHeight * 0.02))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: screenHeight * 0.018) {
                            ForEach(sorted) { event in
                                EventCardView(event: event)
                            }
                        }
                        .padding(.horizontal, screenHeight * 0.02)
                        .padding(.bottom, screenHeight * 0.16)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: screenHeight * 0.012)
                        .fill(Color(red: 0.05, green: 0.08, blue: 0.22).opacity(0.85))
                        .frame(width: screenHeight * 0.055, height: screenHeight * 0.044)
                        .goldBorder(cornerRadius: screenHeight * 0.012, lineWidth: 1.5)

                    Text("←")
                        .font(.poppinsSemiBold(size: screenHeight * 0.024))
                        .foregroundStyle(Color("gold"))
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Event List")
                .font(.poppinsSemiBold(size: screenHeight * 0.028))
                .foregroundStyle(Color("gold"))

            Spacer()

            Color.clear
                .frame(width: screenHeight * 0.055, height: screenHeight * 0.044)
        }
    }

    private var sortFilter: some View {
        HStack(spacing: screenHeight * 0.01) {
            ForEach(EventListViewModel.SortMode.allCases, id: \.title) { mode in
                sortChip(mode)
            }
        }
        .padding(screenHeight * 0.009)
        .background {
            Capsule()
                .fill(Color(red: 0.02, green: 0.03, blue: 0.1))
        }
        .overlay {
            Capsule()
                .stroke(Color("gold").opacity(0.55), lineWidth: 1)
        }
    }

    @ViewBuilder
    private func sortChip(_ mode: EventListViewModel.SortMode) -> some View {
        let isSelected = viewModel.sortMode == mode
        Button {
            viewModel.sortMode = mode
        } label: {
            Text(mode.title)
                .font(.poppinsSemiBold(size: screenHeight * 0.016))
                .foregroundStyle(isSelected ? .white : Color("gold").opacity(0.6))
                .frame(maxWidth: .infinity)
                .frame(height: screenHeight * 0.048)
                .background(Color(red: 0.05, green: 0.08, blue: 0.2))
                .clipShape(Capsule())
                .overlay {
                    if isSelected {
                        ZStack {
                            Capsule()
                                .strokeBorder(Color("gold").opacity(0.45), lineWidth: 10)
                                .blur(radius: 7)
                            Capsule()
                                .stroke(Color("gold").opacity(0.85), lineWidth: 1.2)
                        }
                        .clipShape(Capsule())
                    } else {
                        Capsule()
                            .stroke(Color(red: 0.22, green: 0.32, blue: 0.6), lineWidth: 1.2)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let store = EventsStore()
    let comps1 = DateComponents(year: 2026, month: 5, day: 9,  hour: 22, minute: 0)
    let comps2 = DateComponents(year: 2026, month: 5, day: 24, hour: 18, minute: 0)
    let comps3 = DateComponents(year: 2026, month: 5, day: 31, hour: 20, minute: 0)
    let cal = Calendar.current
    store.add(AppEvent(date: cal.date(from: comps1)!, eventType: .vip,        title: "VIP Granny Dinner",  location: "Granny Poker Club", prizePool: "0"))
    store.add(AppEvent(date: cal.date(from: comps2)!, eventType: .tournament, title: "High Roller Night",   location: "Grand Poker Room",  prizePool: "50,000"))
    store.add(AppEvent(date: cal.date(from: comps3)!, eventType: .event,      title: "Viva Las Vegas",     location: "Poker Home",        prizePool: "10,000"))

    return NavigationStack {
        EventListView()
    }
    .environment(store)
}
