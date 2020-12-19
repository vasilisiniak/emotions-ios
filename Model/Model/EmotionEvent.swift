import Foundation

public struct EmotionEvent {
    
    // MARK: - Public
    
    public let date: Date
    public let name: String
    public let emotions: String
    
    public init(date: Date, name: String, emotions: String) {
        self.date = date
        self.name = name
        self.emotions = emotions
    }
}
