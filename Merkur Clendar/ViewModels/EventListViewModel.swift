import SwiftUI

@Observable
final class EventListViewModel {

    enum SortMode: CaseIterable {
        case upcoming, prizePool

        var title: String {
            switch self {
            case .upcoming:  "UPCOMING"
            case .prizePool: "PRIZE POOL"
            }
        }
    }

    var sortMode: SortMode = .upcoming

    func sortedEvents(_ events: [AppEvent]) -> [AppEvent] {
        let now = Date()
        let upcoming = events.filter { $0.date >= now }
        switch sortMode {
        case .upcoming:
            return upcoming.sorted { $0.date < $1.date }
        case .prizePool:
            return upcoming.sorted { prizeValue($0.prizePool) > prizeValue($1.prizePool) }
        }
    }

    private func prizeValue(_ prize: String) -> Double {
        if prize.lowercased() == "free" { return 0 }
        let digits = prize.unicodeScalars.filter { CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".")).contains($0) }
        return Double(String(digits)) ?? 0
    }
}
