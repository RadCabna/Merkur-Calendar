import SwiftUI

struct BottomBarView: View {
    let viewModel: MainTabViewModel
    let onCreateTap: () -> Void

    private var barHeight: CGFloat { screenHeight * 0.105 }
    private var createSize: CGFloat { screenHeight * 0.077 }
    private var iconHeight: CGFloat { barHeight * 0.38 }
    private var labelSize: CGFloat { screenHeight * 0.013 }

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
                tabButton(.home)
                tabButton(.events)
                Color.clear.frame(width: createSize + 32)
                tabButton(.bonuses)
                tabButton(.profile)
            }
            .frame(height: barHeight)
            .background {
                Image("bottomBarBack")
                    .resizable()
            }

            Button(action: onCreateTap) {
                VStack(spacing: 4) {
                    Image("plusButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: createSize, height: createSize)
                    Text("CREATE")
                        .font(.poppinsSemiBold(size: labelSize))
                        .foregroundStyle(.white)
                        .offset(y: (barHeight * 0.08))
                }
            }
            .buttonStyle(.plain)
            .offset(y: -(barHeight * 0.3))
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func tabButton(_ tab: Tab) -> some View {
        let isActive = viewModel.selectedTab == tab

        Button {
            viewModel.selectedTab = tab
        } label: {
            VStack(spacing: screenHeight * 0.004) {
                Image(isActive ? tab.activeImage : tab.inactiveImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconHeight)
                    .shadow(
                        color: isActive ? Color("gold").opacity(0.75) : .clear,
                        radius: 8, x: 0, y: 0
                    )
                Text(tab.title)
                    .font(.poppinsSemiBold(size: labelSize))
                    .foregroundStyle(isActive ? Color("gold") : .white)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    @Previewable @State var vm = MainTabViewModel()

    ZStack(alignment: .bottom) {
        Image("appBG")
            .resizable()
            .ignoresSafeArea()
        BottomBarView(viewModel: vm, onCreateTap: {})
            .padding(.bottom, 8)
    }
}
