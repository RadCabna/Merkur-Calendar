import Foundation

enum EventCategory: CaseIterable {
    case tournament, vipDinner, promoEvent

    var title: String {
        switch self {
        case .tournament: "Tournament"
        case .vipDinner: "VIP Dinner"
        case .promoEvent: "Promo Event"
        }
    }

    var imageName: String {
        switch self {
        case .tournament: "tournamentButton"
        case .vipDinner: "vipButton"
        case .promoEvent: "eventButton"
        }
    }
}

enum DressCode: CaseIterable {
    case casual, smart, blackTie

    var title: String {
        switch self {
        case .casual: "CASUAL"
        case .smart: "SMART"
        case .blackTie: "BLACK TIE"
        }
    }
}

enum EventVisibility: CaseIterable {
    case `public`, vipOnly, invitationOnly

    var title: String {
        switch self {
        case .public: "PUBLIC"
        case .vipOnly: "VIP ONLY"
        case .invitationOnly: "INVITATION ONLY"
        }
    }
}
