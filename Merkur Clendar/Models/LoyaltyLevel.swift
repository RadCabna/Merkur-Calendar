import Foundation

enum LoyaltyLevel: CaseIterable {
    case lone, alpha, leader, king

    var title: String {
        switch self {
        case .lone: "LONE"
        case .alpha: "ALPHA"
        case .leader: "LEADER"
        case .king: "KING"
        }
    }

    var minXP: Int {
        switch self {
        case .lone: 0
        case .alpha: 2000
        case .leader: 7000
        case .king: 20000
        }
    }

    var maxXP: Int {
        switch self {
        case .lone: 1999
        case .alpha: 6999
        case .leader: 19999
        case .king: Int.max
        }
    }

    var rangeLabel: String {
        switch self {
        case .king: "20,000+"
        default: "\(minXP.formatted()) – \(maxXP.formatted())"
        }
    }

    var iconName: String {
        switch self {
        case .lone: "loneIcon"
        case .alpha: "alphaIcon"
        case .leader: "leaderIcon"
        case .king: "kingIcon"
        }
    }
}
