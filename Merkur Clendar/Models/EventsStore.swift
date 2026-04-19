import SwiftUI

@Observable
final class EventsStore {
    var events: [AppEvent] = []

    private var storageKey: String
    private var seededKey: String

    init(username: String = "") {
        storageKey = username.isEmpty ? "merkur_events" : "merkur_events_\(username)"
        seededKey  = username.isEmpty ? "merkur_seeded" : "merkur_seeded_\(username)"
        load()
        if !UserDefaults.standard.bool(forKey: seededKey) {
            seedDefaultEvents()
        }
    }

    func add(_ event: AppEvent) {
        events.append(event)
        save()
    }

    func remove(id: UUID) {
        events.removeAll { $0.id == id }
        save()
    }

    var nextEvent: AppEvent? {
        let now = Date()
        return events
            .filter { $0.date >= now }
            .sorted { $0.date < $1.date }
            .first
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(events) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([AppEvent].self, from: data)
        else { return }
        events = decoded
    }

    private func seedDefaultEvents() {
        let cal = Calendar.current
        let defaults: [(comps: DateComponents, type: EventType, title: String, location: String, prize: String)] = [
            (
                DateComponents(year: 2026, month: 6, day: 15, hour: 19, minute: 0),
                .tournament,
                "Merkur Spring Poker Classic",
                "Merkur Casino — Main Hall",
                "$10,000"
            ),
            (
                DateComponents(year: 2026, month: 6, day: 25, hour: 20, minute: 0),
                .event,
                "Slots Jackpot Showdown",
                "Merkur Casino — Slots Arena",
                "$5,000"
            ),
            (
                DateComponents(year: 2026, month: 7, day: 11, hour: 21, minute: 0),
                .vip,
                "VIP Blackjack Night",
                "Merkur Casino — VIP Lounge",
                "$15,000"
            ),
            (
                DateComponents(year: 2026, month: 7, day: 25, hour: 18, minute: 30),
                .tournament,
                "Rookie Roulette Cup",
                "Merkur Casino — Roulette Room",
                "$1,000"
            )
        ]

        for item in defaults {
            guard let date = cal.date(from: item.comps) else { continue }
            events.append(AppEvent(
                date: date,
                eventType: item.type,
                title: item.title,
                location: item.location,
                prizePool: item.prize
            ))
        }

        save()
        UserDefaults.standard.set(true, forKey: seededKey)
    }
}
