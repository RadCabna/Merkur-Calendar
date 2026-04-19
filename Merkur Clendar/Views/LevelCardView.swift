import SwiftUI

struct LevelCardView: View {
    let profile: UserProfile

    private var cornerRadius: CGFloat { screenHeight * 0.022 }
    private var cardPadding: CGFloat { screenHeight * 0.015 }
    private var iconSize: CGFloat { screenHeight * 0.1 }
    private var barHeight: CGFloat { screenHeight * 0.013 }

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
        VStack(spacing: screenHeight * 0.018) {
            HStack(alignment: .center, spacing: screenHeight * 0.018) {
                Image(profile.loyaltyLevel.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)

                VStack(alignment: .leading, spacing: screenHeight * 0.00) {
                    Text("YOUR LEVEL")
                        .font(.poppinsSemiBold(size: screenHeight * 0.014))
                        .foregroundStyle(Color("gold"))
                    Text(profile.loyaltyLevel.title)
                        .font(.poppinsSemiBold(size: screenHeight * 0.034))
                        .foregroundStyle(Color("gold"))
                    HStack(spacing: 5) {
                        Image("starIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.018)
                        Text("\(profile.xp.formatted()) XP")
                            .font(.poppinsSemiBold(size: screenHeight * 0.018))
                            .foregroundStyle(.white)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(profile.loyaltyLevel.rangeLabel)
                        .font(.poppinsSemiBold(size: screenHeight * 0.014))
                        .foregroundStyle(Color("gold"))
                    Text("POINTS")
                        .font(.poppinsExtraLight(size: screenHeight * 0.012))
                        .foregroundStyle(.white.opacity(0.65))
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color("gold").opacity(0.5), lineWidth: 1)
                }
            }

            VStack(spacing: screenHeight * 0.002) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.black)
                            .frame(height: barHeight)
                        Capsule()
                            .fill(Color("gold"))
                            .frame(width: geo.size.width * profile.xpProgress, height: barHeight * 0.65)
                    }
                }
                .frame(height: barHeight)

                HStack {
                    Text("\(profile.loyaltyLevel.minXP.formatted()) XP")
                    Spacer()
                    Text("\(profile.loyaltyLevel.maxXP == Int.max ? "∞" : profile.loyaltyLevel.maxXP.formatted()) XP")
                }
                .font(.poppinsExtraLight(size: screenHeight * 0.013))
                .foregroundStyle(.white)
            }
        }
        .padding(cardPadding)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .goldBorder(cornerRadius: cornerRadius, lineWidth: 4)
    }
}

#Preview {
    ZStack {
        Image("appBG").resizable().ignoresSafeArea()
        LevelCardView(profile: UserProfile(name: "ALEX", xp: 0))
            .padding()
    }
}
