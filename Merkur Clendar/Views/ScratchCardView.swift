import SwiftUI

struct ScratchCardView: View {
    let cardType: BonusType
    let isRevealed: Bool
    let timeRemaining: String
    var onReveal: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isFlyingOut: Bool = false
    @State private var localRevealed: Bool = false

    private var cardWidth: CGFloat { screenWidth * 0.9 }
    private var cardHeight: CGFloat { screenHeight * 0.221 }
    private var cornerRadius: CGFloat { screenHeight * 0.022 }

    var body: some View {
        ZStack {
            // Bonus image — smaller, natural proportions, stays in place
            Image(cardType.cardImageName)
                .resizable()
                .scaledToFit()
                .frame(width: cardWidth * 0.65)
                .allowsHitTesting(false)

            // ultraThinMaterial overlay — full card size, only this slides
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)

                if localRevealed {
                    countdownContent.transition(.opacity)
                } else {
                    scratchContent.transition(.opacity)
                }

                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(LinearGradient.goldBorder, lineWidth: 1.5)
            }
            .frame(width: cardWidth, height: cardHeight)
            .offset(x: overlayOffset)
            .gesture(
                localRevealed ? nil :
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        if abs(value.translation.width) > 80 {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                                isFlyingOut = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                                onReveal()
                                dragOffset = 0
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    isFlyingOut = false
                                    localRevealed = true
                                }
                            }
                        } else {
                            withAnimation(.spring()) { dragOffset = 0 }
                        }
                    }
            )
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .frame(maxWidth: .infinity)
        .onAppear { localRevealed = isRevealed }
        .onChange(of: isRevealed) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.3)) { localRevealed = true }
                dragOffset = 0
                isFlyingOut = false
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    localRevealed = false
                    dragOffset = 0
                    isFlyingOut = false
                }
            }
        }
    }

    private var overlayOffset: CGFloat {
        isFlyingOut ? (dragOffset >= 0 ? screenWidth * 1.5 : -screenWidth * 1.5) : dragOffset
    }

    private var scratchContent: some View {
        Image("scratchText")
            .resizable()
            .scaledToFit()
            .frame(height: screenHeight * 0.1)
            .allowsHitTesting(false)
    }

    private var countdownContent: some View {
        VStack(spacing: screenHeight * 0.012) {
            Text("Until The Next Attempt At")
                .font(.poppinsExtraLight(size: screenHeight * 0.018))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            Text(timeRemaining)
                .font(.poppinsSemiBold(size: screenHeight * 0.034))
                .foregroundStyle(Color("gold"))
                .monospacedDigit()
        }
        .padding(.horizontal, screenHeight * 0.02)
    }
}

#Preview {
    ZStack {
        Color(red: 0.04, green: 0.06, blue: 0.18).ignoresSafeArea()
        ScratchCardView(
            cardType: .cashBonus,
            isRevealed: false,
            timeRemaining: "23:59:59",
            onReveal: {}
        )
        .padding()
    }
}
