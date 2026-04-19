import Foundation

struct UserProfile {
    var name: String
    var xp: Int

    var loyaltyLevel: LoyaltyLevel {
        switch xp {
        case 0..<2000: .lone
        case 2000..<7000: .alpha
        case 7000..<20000: .leader
        default: .king
        }
    }

    var xpProgress: Double {
        guard loyaltyLevel != .king else { return 1.0 }
        let range = Double(loyaltyLevel.maxXP - loyaltyLevel.minXP)
        let earned = Double(xp - loyaltyLevel.minXP)
        return min(max(earned / range, 0), 1)
    }
}
