import Foundation

public struct EmotionEvent {
    
    // MARK: - Public
    
    public let date: Date
    public let name: String
    public let emotions: String
    public let color: String
    
    public init(date: Date, name: String, emotions: String, color: String) {
        self.date = date
        self.name = name
        self.emotions = emotions
        self.color = color
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
