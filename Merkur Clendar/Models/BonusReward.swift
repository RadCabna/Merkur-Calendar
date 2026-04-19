import Foundation

enum BonusType: String, Codable, CaseIterable {
    case cashBonus       = "scratch_001"
    case freeSpins       = "scratch_002"
    case vipPoints       = "scratch_003"
    case tournamentTicket = "scratch_004"

    var description: String {
        switch self {
        case .cashBonus:        return "$50 Cash Bonus"
        case .freeSpins:        return "25 Free Spins on Book of Ra"
        case .vipPoints:        return "1,000 VIP Points"
        case .tournamentTicket: return "Ticket to Slots Jackpot Showdown"
        }
    }

    var shortLabel: String {
        switch self {
        case .cashBonus:        return "CASH BONUS\n$50"
        case .freeSpins:        return "FREE SPINS\n25 Spins"
        case .vipPoints:        return "VIP POINTS\n1,000 Pts"
        case .tournamentTicket: return "TOURNAMENT\nTICKET"
        }
    }

    var qrCodeData: String {
        "https://merkur.casino/scratch/\(rawValue)"
    }

    var cardImageName: String {
        switch self {
        case .cashBonus:        return "bonus_1"
        case .freeSpins:        return "bonus_2"
        case .vipPoints:        return "bonus_3"
        case .tournamentTicket: return "bonus_4"
        }
    }
}

struct BonusReward: Identifiable, Codable {
    let id: UUID
    let type: BonusType
    let dateWon: Date

    init(type: BonusType) {
        self.id = UUID()
        self.type = type
        self.dateWon = Date()
    }
}
