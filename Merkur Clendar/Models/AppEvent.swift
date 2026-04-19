import SwiftUI

enum EventType: String, Codable {
    case event = "EVENT"
    case tournament = "TOURNAMENT"
    case vip = "VIP"

    var imageName: String {
        switch self {
        case .event: "image_event"
        case .tournament: "image_tournament"
        case .vip: "image_vip"
        }
    }

    var dotColor: Color {
        switch self {
        case .vip: Color(red: 0.0, green: 0.88, blue: 0.35)
        case .tournament: Color(red: 0.22, green: 0.38, blue: 1.0)
        case .event: Color(red: 0.95, green: 0.12, blue: 0.82)
        }
    }
}

struct AppEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var eventType: EventType
    var title: String
    var location: String
    var prizePool: String
    var customImageData: Data?

    var day: Int { Calendar.current.component(.day, from: date) }

    var month: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        return fmt.string(from: date).uppercased()
    }

    var weekday: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE"
        return fmt.string(from: date).uppercased()
    }

    var time: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }

    init(date: Date, eventType: EventType, title: String, location: String, prizePool: String, customImageData: Data? = nil) {
        self.id = UUID()
        self.date = date
        self.eventType = eventType
        self.title = title
        self.location = location
        self.prizePool = prizePool
        self.customImageData = customImageData
    }
}
