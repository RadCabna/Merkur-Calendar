import SwiftUI

struct EventsView: View {
    @State private var viewModel = EventsViewModel()
    @Environment(EventsStore.self) private var eventsStore

    var body: some View {
        ZStack {
            Image("appBG")
                .resizable()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: screenHeight * 0.022) {
                    Text("Events")
                        .font(.poppinsSemiBold(size: screenHeight * 0.038))
                        .foregroundStyle(Color("gold"))

                    MonthNavigatorView(viewModel: viewModel)

                    CalendarGridView(viewModel: viewModel)

                    legendRow

                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color("gold"), lineWidth: 1.5)
                        .frame(height: 7)

                    if !viewModel.selectedDateEvents.isEmpty {
                        VStack(spacing: screenHeight * 0.016) {
                            ForEach(viewModel.selectedDateEvents) { event in
                                EventCardView(event: event)
                            }
                        }
                    }
                }
                .padding(.horizontal, screenHeight * 0.02)
                .padding(.top, screenHeight * 0.025)
                .padding(.bottom, screenHeight * 0.16)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.events = eventsStore.events
        }
        .onChange(of: eventsStore.events) { _, newEvents in
            viewModel.events = newEvents
        }
    }

    private var legendRow: some View {
        HStack(spacing: 0) {
            ForEach([EventType.vip, .tournament, .event], id: \.rawValue) { type in
                HStack(spacing: screenHeight * 0.008) {
                    Circle()
                        .fill(type.dotColor)
                        .overlay { Circle().stroke(Color("gold"), lineWidth: 1.5) }
                        .frame(width: screenHeight * 0.025, height: screenHeight * 0.025)
                    Text("• \(type.rawValue)")
                        .font(.poppinsSemiBold(size: screenHeight * 0.014))
                        .foregroundStyle(Color("gold"))
                        .lineLimit(1)
                }
                if type != .event { Spacer() }
            }
        }
    }
}

#Preview {
    EventsView()
        .environment(EventsStore())
}
