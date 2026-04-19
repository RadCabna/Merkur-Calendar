import Foundation
import PhotosUI
import SwiftUI

@Observable
final class CreateEventViewModel {
    var eventName = ""
    var eventDate: Date? = nil
    var eventTime: Date? = nil
    var location = ""
    var category: EventCategory? = nil
    var prizePool = ""
    var isFree = false
    var buyIn = ""
    var maxPlayers = ""
    var dressCode: DressCode? = nil
    var eventDescription = ""
    var visibility: EventVisibility = .public

    var pickerDate = Date()
    var showDatePicker = false
    var showTimePicker = false
    var showPhotoPicker = false
    var selectedPhotoItem: PhotosPickerItem? = nil
    var selectedImage: UIImage? = nil

    var showErrors = false

    var isFormValid: Bool {
        !eventName.isEmpty &&
        !location.isEmpty &&
        eventDate != nil &&
        eventTime != nil &&
        (isFree || !prizePool.isEmpty) &&
        category != nil
    }

    var nameError:     Bool { showErrors && eventName.isEmpty }
    var locationError: Bool { showErrors && location.isEmpty }
    var dateError:     Bool { showErrors && eventDate == nil }
    var timeError:     Bool { showErrors && eventTime == nil }
    var prizeError:    Bool { showErrors && !isFree && prizePool.isEmpty }
    var categoryError: Bool { showErrors && category == nil }

    @discardableResult
    func save(to store: EventsStore) -> Bool {
        guard !eventName.isEmpty, let date = eventDate else { return false }

        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: date)
        if let time = eventTime {
            let t = cal.dateComponents([.hour, .minute], from: time)
            comps.hour = t.hour
            comps.minute = t.minute
        } else {
            comps.hour = 0
            comps.minute = 0
        }
        let combined = cal.date(from: comps) ?? date

        let eventType: EventType
        switch category {
        case .tournament: eventType = .tournament
        case .vipDinner:  eventType = .vip
        case .promoEvent: eventType = .event
        case nil:         eventType = .event
        }

        let imageData = selectedImage.flatMap { $0.jpegData(compressionQuality: 0.7) }
        let event = AppEvent(
            date: combined,
            eventType: eventType,
            title: eventName,
            location: location,
            prizePool: isFree ? "Free" : prizePool,
            customImageData: imageData
        )
        store.add(event)
        return true
    }

    var isDateToday: Bool {
        guard let date = eventDate else { return true }
        return Calendar.current.isDateInToday(date)
    }

    var dateDisplayString: String {
        guard let date = eventDate else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "dd MMM yyyy"
        return fmt.string(from: date)
    }

    var timeDisplayString: String {
        guard let time = eventTime else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: time)
    }
}
