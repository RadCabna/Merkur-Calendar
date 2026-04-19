import Foundation

@Observable
final class EventsViewModel {
    var displayMonth: Date
    var selectedDate: Date?
    var events: [AppEvent] = []

    init() {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: Date())
        self.displayMonth = cal.date(from: comps) ?? Date()
    }

    var monthYearTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: displayMonth).uppercased()
    }

    var calendarDays: [Date?] {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: displayMonth)
        guard let firstDay = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else {
            return []
        }
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for dayNum in range {
            var dayComps = comps
            dayComps.day = dayNum
            days.append(calendar.date(from: dayComps))
        }
        let remainder = days.count % 7
        if remainder != 0 {
            days += Array(repeating: nil, count: 7 - remainder)
        }
        return days
    }

    var selectedDateEvents: [AppEvent] {
        guard let date = selectedDate else { return [] }
        return events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func eventTypes(for date: Date) -> [EventType] {
        let types = events
            .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .map { $0.eventType }
        var seen = Set<String>()
        return types.filter { seen.insert($0.rawValue).inserted }
    }

    func isSelected(_ date: Date) -> Bool {
        guard let selected = selectedDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selected)
    }

    func selectDate(_ date: Date) {
        if let selected = selectedDate, Calendar.current.isDate(selected, inSameDayAs: date) {
            selectedDate = nil
        } else {
            selectedDate = date
        }
    }

    func previousMonth() {
        guard let prev = Calendar.current.date(byAdding: .month, value: -1, to: displayMonth) else { return }
        displayMonth = prev
        selectedDate = nil
    }

    func nextMonth() {
        guard let next = Calendar.current.date(byAdding: .month, value: 1, to: displayMonth) else { return }
        displayMonth = next
        selectedDate = nil
    }

    static var preview: EventsViewModel {
        let vm = EventsViewModel()
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month], from: vm.displayMonth)

        comps.day = 9; comps.hour = 20; comps.minute = 0
        if let d = cal.date(from: comps) {
            vm.events.append(AppEvent(date: d, eventType: .vip, title: "VIP Night", location: "Grand Casino", prizePool: "10000"))
        }
        comps.day = 15; comps.hour = 18; comps.minute = 30
        if let d = cal.date(from: comps) {
            vm.events.append(AppEvent(date: d, eventType: .tournament, title: "High Roller Tournament", location: "Main Hall", prizePool: "50000"))
        }
        comps.day = 24; comps.hour = 21; comps.minute = 0
        if let d = cal.date(from: comps) {
            vm.events.append(AppEvent(date: d, eventType: .tournament, title: "Poker Championship", location: "Grand Poker Room", prizePool: "75000"))
        }
        comps.day = 28; comps.hour = 19; comps.minute = 0
        if let d = cal.date(from: comps) {
            vm.events.append(AppEvent(date: d, eventType: .event, title: "Special Evening", location: "Event Hall", prizePool: "5000"))
        }
        return vm
    }
}
