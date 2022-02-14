import Foundation

extension Date {
    public var dateOnly: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }

    public var year: Int {
        Calendar.current.component(.year, from: self)
    }
}
