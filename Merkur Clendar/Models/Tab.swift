import Foundation

enum Tab: CaseIterable {
    case home, events, bonuses, profile

    var title: String {
        switch self {
        case .home: "HOME"
        case .events: "EVENTS"
        case .bonuses: "BONUSES"
        case .profile: "PROFILE"
        }
    }

    var activeImage: String {
        switch self {
        case .home: "homeOn"
        case .events: "eventsOn"
        case .bonuses: "bonusesOn"
        case .profile: "profileOn"
        }
    }

    var inactiveImage: String {
        switch self {
        case .home: "homeOff"
        case .events: "eventsOff"
        case .bonuses: "bonusesOff"
        case .profile: "profileOff"
        }
    }
}
