import SwiftUI

extension LinearGradient {
    static var goldBorder: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color("gold").opacity(0.6), location: 0),
                .init(color: Color("gold").opacity(0.08), location: 0.5),
                .init(color: Color("gold").opacity(0.7), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var goldActiveFill: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color("gold").opacity(0.45), location: 0),
                .init(color: Color("gold").opacity(0.06), location: 0.5),
                .init(color: Color("gold").opacity(0.55), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension View {
    // Gradient stroke — for cards, calendar, navigator, etc.
    func goldBorder(cornerRadius: CGFloat, lineWidth: CGFloat = 1.5) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(LinearGradient.goldBorder, lineWidth: lineWidth)
        }
    }

    func goldCapsuleBorder(lineWidth: CGFloat = 1.5) -> some View {
        overlay {
            Capsule().stroke(LinearGradient.goldBorder, lineWidth: lineWidth)
        }
    }

    // Inner-glow border — sharp outer edge, blur goes inward only (CreateEventView only)
    func goldGlowBorder(cornerRadius: CGFloat) -> some View {
        let r = RoundedRectangle(cornerRadius: cornerRadius)
        return overlay {
            ZStack {
                r.strokeBorder(Color("gold").opacity(0.4), lineWidth: 12)
                    .blur(radius: 8)
                r.strokeBorder(Color("gold").opacity(0.55), lineWidth: 1.5)
            }
            .clipShape(r)
        }
    }

    func goldGlowCapsuleBorder() -> some View {
        overlay {
            ZStack {
                Capsule()
                    .strokeBorder(Color("gold").opacity(0.4), lineWidth: 12)
                    .blur(radius: 5)
                Capsule()
                    .strokeBorder(Color("gold").opacity(0.0), lineWidth: 1.5)
            }
            .clipShape(Capsule())
        }
    }
}
