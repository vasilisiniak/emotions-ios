import Foundation

public protocol EmotionEventsProvider {
    var events: [EmotionEvent] { get }
    func log(event: EmotionEvent)
}

public class EmotionEventsProviderImpl {
    
    // MARK: - Public
    
    public var events: [EmotionEvent] = [
        EmotionEvent(date: Date(), name: "Купил мотоцикл", emotions: "Радость, Горе, Огорчение"),
        EmotionEvent(date: Date(), name: "Приехала e-dostavka", emotions: "Радость, Горе, Огорчение, Радость, Горе, Огорчение, Радость, Горе, Огорчение, Радость, Горе, Огорчение"),
        EmotionEvent(date: Date(), name: "Купил мотоцикл и приехала e-dostavka и ещё много много всякого", emotions: "Радость, Горе, Огорчение"),
        EmotionEvent(date: Date(), name: "Купил мотоцикл и приехала e-dostavka и ещё много много всякого 2", emotions: "Радость, Горе, Огорчение, Радость, Горе, Огорчение, Радость, Горе, Огорчение, Радость, Горе, Огорчение")
    ]
    
    public init() {}
}

extension EmotionEventsProviderImpl: EmotionEventsProvider {
    public func log(event: EmotionEvent) {
    }
}
