import Foundation

extension Date {
    func nearestFullHourInTheFuture() -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute, .second], from: self)
        guard let minute = components.minute else {return nil}
        guard let second = components.second else {return nil}
        if minute == 0 && second == 0 {
            return self
        }
        components.hour = 1
        components.minute = -minute
        components.second = -second
        return calendar.date(byAdding: components, to: self)
    }
}
