import SwiftUI

struct MonthNavigatorView: View {
    let viewModel: EventsViewModel

    private var cornerRadius: CGFloat { screenHeight * 0.022 }

    var body: some View {
        HStack {
            Button { viewModel.previousMonth() } label: {
                Text("<--")
                    .font(.poppinsSemiBold(size: screenHeight * 0.02))
                    .foregroundStyle(Color("gold"))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(viewModel.monthYearTitle)
                .font(.poppinsSemiBold(size: screenHeight * 0.022))
                .foregroundStyle(Color("gold"))

            Spacer()

            Button { viewModel.nextMonth() } label: {
                Text("-->")
                    .font(.poppinsSemiBold(size: screenHeight * 0.02))
                    .foregroundStyle(Color("gold"))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, screenHeight * 0.025)
        .frame(height: screenHeight * 0.062)
        .background(Color(red: 0.04, green: 0.07, blue: 0.18))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .goldBorder(cornerRadius: cornerRadius, lineWidth: 4)
    }
}

#Preview {
    ZStack {
        Image("appBG").resizable().ignoresSafeArea()
        MonthNavigatorView(viewModel: .preview)
            .padding()
    }
}
