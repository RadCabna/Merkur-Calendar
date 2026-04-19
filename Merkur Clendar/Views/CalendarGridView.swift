import SwiftUI

struct CalendarGridView: View {
    let viewModel: EventsViewModel

    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    private var dotSize: CGFloat { screenHeight * 0.02 }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.poppinsSemiBold(size: screenHeight * 0.018))
                        .foregroundStyle(Color("gold"))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, screenHeight * 0.014)

            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(Array(viewModel.calendarDays.enumerated()), id: \.offset) { _, date in
                    dayCell(for: date)
                }
            }
            .goldBorder(cornerRadius: 2, lineWidth: 1)
        }
    }

    @ViewBuilder
    private func dayCell(for date: Date?) -> some View {
        let isSelected = date.map { viewModel.isSelected($0) } ?? false
        let dots = date.map { viewModel.eventTypes(for: $0) } ?? []

        ZStack {
            if isSelected {
                Rectangle().fill(Color.white)
            } else {
                Rectangle().fill(Color.white.opacity(0.05))
            }

            if let date {
                VStack(spacing: 3) {
                    HStack {
                        Spacer()
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.poppinsSemiBold(size: screenHeight * 0.016))
                            .foregroundStyle(isSelected ? Color.black : .white)
                            .padding(.top, 4)
                            .padding(.trailing, 4)
                    }

                    Spacer(minLength: 0)

                    HStack(spacing: 3) {
                        ForEach(Array(dots.prefix(3).enumerated()), id: \.offset) { _, type in
                            Circle()
                                .fill(type.dotColor)
                                .overlay { Circle().stroke(Color("gold"), lineWidth: 1) }
                                .frame(width: dotSize, height: dotSize)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 5)
                }
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .overlay {
            Rectangle()
                .stroke(Color("gold"), lineWidth: 1)
        }
        .onTapGesture {
            if let date { viewModel.selectDate(date) }
        }
    }
}

#Preview {
    ZStack {
        Image("appBG").resizable().ignoresSafeArea()
        CalendarGridView(viewModel: .preview)
            .padding()
    }
}
