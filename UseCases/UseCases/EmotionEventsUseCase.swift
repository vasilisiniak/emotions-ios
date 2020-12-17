import Foundation
import Model

public enum EmotionEventsUseCaseObjects {
    
    public struct Event {
        
        // MARK: - Fileprivate
        
        fileprivate init(event: EmotionEvent) {
            self.date = event.date
            self.name = event.name
            self.emotions = event.emotions
        }
        
        // MARK: - Public
        
        public let date: Date
        public let name: String
        public let emotions: String
    }
}

public protocol EmotionEventsUseCaseOutput: class {
    func present(events: [EmotionEventsUseCaseObjects.Event])
}

public protocol EmotionEventsEventsHandler {
    func eventViewReady()
}

public protocol EmotionEventsUseCase: EmotionEventsEventsHandler {}

public class EmotionEventsUseCaseImpl {
    
    // MARK: - Private
    
    private let eventsProvider: EmotionEventsProvider
    
    // MARK: - Public
    
    public weak var output: EmotionEventsUseCaseOutput!
    public init(eventsProvider: EmotionEventsProvider) {
        self.eventsProvider = eventsProvider
    }
}

extension EmotionEventsUseCaseImpl: EmotionEventsUseCase {
    public func eventViewReady() {
        let events = eventsProvider.events.map { EmotionEventsUseCaseObjects.Event(event: $0) }
        output.present(events: events)
    }
}
