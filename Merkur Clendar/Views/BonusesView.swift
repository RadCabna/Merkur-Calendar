import SwiftUI
import CoreImage.CIFilterBuiltins

struct BonusesView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var viewModel = BonusViewModel()
    @State private var qrReward: BonusReward? = nil

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var cornerRadius: CGFloat { screenHeight * 0.022 }

    var body: some View {
        ZStack {
            Image("appBG")
                .resizable()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: screenHeight * 0.028) {
                    pageHeader

                    ScratchCardView(
                        cardType: viewModel.currentCardType,
                        isRevealed: viewModel.isRevealed,
                        timeRemaining: viewModel.timeRemaining,
                        onReveal: { viewModel.revealBonus() }
                    )

                    if !viewModel.wonRewards.isEmpty {
                        prizesSection
                        lastPrizesSection
                    }
                }
                .padding(.horizontal, screenHeight * 0.02)
                .padding(.top, screenHeight * 0.015)
                .padding(.bottom, screenHeight * 0.16)
            }

            if let reward = qrReward {
                qrOverlay(reward: reward)
                    .transition(.opacity.combined(with: .scale(scale: 0.93)))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onReceive(timer) { _ in viewModel.tick() }
        .onAppear {
            viewModel = BonusViewModel(username: authVM.currentUser?.username ?? "")
        }
        .animation(.easeInOut(duration: 0.22), value: qrReward == nil)
    }

    // MARK: - Page Header

    private var pageHeader: some View {
        HStack {
            Color.clear.frame(width: screenHeight * 0.044)
            Spacer()
            Text("Bonuses")
                .font(.poppinsSemiBold(size: screenHeight * 0.028))
                .foregroundStyle(Color("gold"))
            Spacer()
            Color.clear.frame(width: screenHeight * 0.044)
        }
        .padding(.top, screenHeight * 0.01)
    }

    // MARK: - Prizes Section (all won bonuses as images)

    private var prizesSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            Text("Prizes")
                .font(.poppinsSemiBold(size: screenHeight * 0.022))
                .foregroundStyle(.white)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: screenHeight * 0.012
            ) {
                ForEach(viewModel.wonRewards) { reward in
                    Image(reward.type.cardImageName)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.014))
                }
            }
        }
    }

    // MARK: - Last Prizes Section (most recent only)

    private var lastPrizesSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            Text("Last Prizes")
                .font(.poppinsSemiBold(size: screenHeight * 0.022))
                .foregroundStyle(.white)

            if let reward = viewModel.wonRewards.first {
                lastPrizeRow(reward: reward)
            }
        }
    }

    private func lastPrizeRow(reward: BonusReward) -> some View {
        let rowHeight: CGFloat = screenHeight * 0.092
        let btnSize: CGFloat = screenHeight * 0.058
        let btnCorner: CGFloat = screenHeight * 0.012

        return HStack(spacing: 0) {
            Image(reward.type.cardImageName)
                .resizable()
                .scaledToFit()
                .frame(height: rowHeight * 0.82)
                .padding(.horizontal, screenHeight * 0.016)
                .frame(maxWidth: .infinity, alignment: .center)

            Button {
                withAnimation { qrReward = reward }
            } label: {
                Image("qrImage")
                    .resizable()
                    .scaledToFit()
                    .padding(screenHeight * 0.011)
                    .frame(width: btnSize, height: btnSize)
                    .background(Color(red: 0.05, green: 0.08, blue: 0.22))
                    .clipShape(RoundedRectangle(cornerRadius: btnCorner))
                    .goldBorder(cornerRadius: btnCorner, lineWidth: 1.5)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, screenHeight * 0.008)

            Button {
                withAnimation { viewModel.deleteReward(id: reward.id) }
            } label: {
                Image("deleteImage")
                    .resizable()
                    .scaledToFit()
                    .padding(screenHeight * 0.012)
                    .frame(width: btnSize, height: btnSize)
                    .background(Color(red: 0.05, green: 0.08, blue: 0.22))
                    .clipShape(RoundedRectangle(cornerRadius: btnCorner))
                    .goldBorder(cornerRadius: btnCorner, lineWidth: 1.5)
            }
            .buttonStyle(.plain)
            .padding(.trailing, screenHeight * 0.01)
        }
        .frame(height: rowHeight)
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.07, green: 0.11, blue: 0.32).opacity(0.95), location: 0),
                    .init(color: Color(red: 0.03, green: 0.05, blue: 0.18).opacity(0.95), location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .goldBorder(cornerRadius: cornerRadius, lineWidth: 2.5)
    }

    // MARK: - QR Overlay

    @ViewBuilder
    private func qrOverlay(reward: BonusReward) -> some View {
        ZStack {
            Color.black.opacity(0.78)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { qrReward = nil } }

            VStack(spacing: screenHeight * 0.032) {
                Text(reward.type.description)
                    .font(.poppinsSemiBold(size: screenHeight * 0.024))
                    .foregroundStyle(Color("gold"))
                    .multilineTextAlignment(.center)

                Image(uiImage: makeQRCode(from: reward.type.qrCodeData))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth * 0.62)

                Button {
                    withAnimation { qrReward = nil }
                } label: {
                    Text("USE")
                        .font(.poppinsSemiBold(size: screenHeight * 0.024))
                        .foregroundStyle(.black)
                        .frame(width: screenWidth * 0.62)
                        .frame(height: screenHeight * 0.065)
                        .background(Color("gold"))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, screenHeight * 0.04)
        }
    }

    private func makeQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return UIImage() }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
        let colored = scaled.applyingFilter("CIFalseColor", parameters: [
            "inputColor0": CIColor(red: 0.94, green: 0.74, blue: 0.08),
            "inputColor1": CIColor(red: 0.05, green: 0.08, blue: 0.22)
        ])
        guard let cgImage = context.createCGImage(colored, from: colored.extent) else { return UIImage() }
        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    BonusesView()
        .environment(AuthViewModel())
}
