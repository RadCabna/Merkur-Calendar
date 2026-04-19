import SwiftUI

struct LoyaltyProgressView: View {
    let currentLevel: LoyaltyLevel

    private var cornerRadius: CGFloat { screenHeight * 0.022 }
    private var cardPadding: CGFloat { screenHeight * 0.02 }

    private var cardBackground: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.03, green: 0.06, blue: 0.17), location: 0),
                .init(color: Color(red: 0.07, green: 0.14, blue: 0.33), location: 0.45),
                .init(color: Color(red: 0.04, green: 0.08, blue: 0.22), location: 0.75),
                .init(color: Color(red: 0.02, green: 0.05, blue: 0.15), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.015) {
            Text("LOYALTY PROGRESS")
                .font(.poppinsSemiBold(size: screenHeight * 0.017))
                .foregroundStyle(Color("gold"))

            HStack(spacing: screenHeight * 0.01) {
                ForEach(LoyaltyLevel.allCases, id: \.self) { level in
                    loyaltyBadge(for: level)
                }
            }
        }
        .padding(cardPadding)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .goldBorder(cornerRadius: cornerRadius, lineWidth: 4)
    }

    @ViewBuilder
    private func loyaltyBadge(for level: LoyaltyLevel) -> some View {
        let isActive = level == currentLevel

        VStack(spacing: screenHeight * 0.004) {
            Image(level.iconName)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight * 0.082)
                .shadow(
                    color: isActive ? Color("gold").opacity(0.6) : .clear,
                    radius: 10
                )

            Text(level.title)
                .font(.poppinsSemiBold(size: screenHeight * 0.013))
                .foregroundStyle(isActive ? Color("gold") : .white)

            Text(level.rangeLabel)
                .font(.poppinsExtraLight(size: screenHeight * 0.011))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, screenHeight * 0.015)
        .background {
            if isActive {
                RoundedRectangle(cornerRadius: screenHeight * 0.015)
                    .fill(LinearGradient.goldActiveFill)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: screenHeight * 0.015)
                .stroke(LinearGradient.goldBorder, lineWidth: 1.5)
                .opacity(isActive ? 1 : 0)
        }
    }
}

#Preview {
    ZStack {
        Image("appBG").resizable().ignoresSafeArea()
        LoyaltyProgressView(currentLevel: .lone)
            .padding()
    }
}
