import Foundation
import SwiftUI

@Observable
final class BonusViewModel {

    var wonRewards: [BonusReward] = []
    var isRevealed: Bool = false
    var currentCardType: BonusType = BonusType.allCases.randomElement()!
    var currentTime: Date = Date()

    private(set) var lastScratchDate: Date? = nil
    private var username: String

    private var rewardsKey: String { "merkur_bonuses_v5_\(username)" }
    private var lastScratchKey: String { "merkur_last_scratch_v5_\(username)" }
    private var cardTypeKey: String { "merkur_scratch_card_v5_\(username)" }

    var canScratch: Bool {
        guard let last = lastScratchDate else { return true }
        return currentTime.timeIntervalSince(last) >= 86400
    }

    var timeRemaining: String {
        guard let last = lastScratchDate else { return "00:00:00" }
        let next = last.addingTimeInterval(86400)
        let diff = max(0, Int(next.timeIntervalSince(currentTime)))
        let h = diff / 3600
        let m = (diff % 3600) / 60
        let s = diff % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    init(username: String = "") {
        self.username = username
        load()
        if canScratch && isRevealed {
            resetCard()
        }
    }

    func tick() {
        currentTime = Date()
        if canScratch && isRevealed {
            resetCard()
        }
    }

    func revealBonus() {
        guard canScratch && !isRevealed else { return }
        isRevealed = true
        lastScratchDate = Date()
        currentTime = Date()
        let reward = BonusReward(type: currentCardType)
        wonRewards.insert(reward, at: 0)
        save()
    }

    func deleteReward(id: UUID) {
        wonRewards.removeAll { $0.id == id }
        save()
    }

    private func resetCard() {
        currentCardType = BonusType.allCases.randomElement()!
        isRevealed = false
        saveCardType()
    }

    private func saveCardType() {
        UserDefaults.standard.set(currentCardType.rawValue, forKey: cardTypeKey)
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(wonRewards) {
            UserDefaults.standard.set(encoded, forKey: rewardsKey)
        }
        if let date = lastScratchDate {
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: lastScratchKey)
        }
        saveCardType()
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: rewardsKey),
           let decoded = try? JSONDecoder().decode([BonusReward].self, from: data) {
            wonRewards = decoded
        }
        let ts = UserDefaults.standard.double(forKey: lastScratchKey)
        if ts > 0 {
            lastScratchDate = Date(timeIntervalSince1970: ts)
            isRevealed = !canScratch
        }
        if let raw = UserDefaults.standard.string(forKey: cardTypeKey),
           let type = BonusType(rawValue: raw) {
            currentCardType = type
        }
    }
}
