import Foundation

public struct EmotionEvent: Equatable {

    // MARK: - Internal

    init(date: Date, name: String, details: String?, emotions: String, color: String, deleted: Date?) {
        self.date = date
        self.name = name
        self.details = details
        self.emotions = emotions
        self.color = color
        self.deleted = deleted
    }

    // MARK: - Public

    public let date: Date
    public let name: String
    public let details: String?
    public let emotions: String
    public let color: String
    public let deleted: Date?

    public init(date: Date, name: String, details: String?, emotions: String, color: String) {
        self.init(date: date, name: name, details: details, emotions: emotions, color: color, deleted: nil)
    }
}

extension Array where Element == EmotionEvent {
    public func filtered(range: (min: Date?, max: Date?)) -> Self {
        var result = self.sorted { $0.date < $1.date }
        if let min = range.min {
            result = result.filter { min <= $0.date }
        }
        if let max = range.max {
            result = result.filter { $0.date <= max }
        }
        return result
    }
}
