import SwiftUI

@Observable
final class EventsStore {
    var events: [AppEvent] = []
    var registeredEventIDs: Set<UUID> = []

    private var storageKey: String
    private var seededKey: String
    private var registeredKey: String

    init(username: String = "") {
        storageKey    = username.isEmpty ? "merkur_events"     : "merkur_events_\(username)"
        seededKey     = username.isEmpty ? "merkur_seeded"     : "merkur_seeded_\(username)"
        registeredKey = username.isEmpty ? "merkur_registered" : "merkur_registered_\(username)"
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
        registeredEventIDs.remove(id)
        saveRegistered()
        save()
    }

    func toggleRegistration(for id: UUID) {
        if registeredEventIDs.contains(id) {
            registeredEventIDs.remove(id)
        } else {
            registeredEventIDs.insert(id)
        }
        saveRegistered()
    }

    func isRegistered(_ id: UUID) -> Bool {
        registeredEventIDs.contains(id)
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

    private func saveRegistered() {
        let ids = registeredEventIDs.map { $0.uuidString }
        UserDefaults.standard.set(ids, forKey: registeredKey)
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([AppEvent].self, from: data) {
            events = decoded
        }
        if let ids = UserDefaults.standard.stringArray(forKey: registeredKey) {
            registeredEventIDs = Set(ids.compactMap { UUID(uuidString: $0) })
        }
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
