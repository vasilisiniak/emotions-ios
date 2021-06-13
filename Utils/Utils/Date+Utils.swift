import Foundation

extension Date {
    public var dateOnly: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
}
