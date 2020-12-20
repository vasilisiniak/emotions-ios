import Foundation
import Model

public enum EmotionEventsUseCaseObjects {
    
    public struct Event {
        
        // MARK: - Fileprivate
        
        fileprivate init(event: EmotionEvent) {
            date = event.date
            name = event.name
            emotions = event.emotions
            color = event.color
        }
        
        // MARK: - Public
        
        public let date: Date
        public let name: String
        public let emotions: String
        public let color: String
    }
}

public protocol EmotionEventsUseCaseOutput: class {
    func present(events: [EmotionEventsUseCaseObjects.Event])
}

public protocol EmotionEventsUseCase {
    func eventOutputReady()
    func delete(event: EmotionEventsUseCaseObjects.Event)
}

public final class EmotionEventsUseCaseImpl {
    
    // MARK: - Private
    
    private let eventsProvider: EmotionEventsProvider
    
    private func presentEvents() {
        let events = eventsProvider.events
            .map { EmotionEventsUseCaseObjects.Event(event: $0) }
            .sorted { $0.date.compare($1.date) == .orderedDescending }
        output.present(events: events)
    }
    
    // MARK: - Public
    
    public weak var output: EmotionEventsUseCaseOutput!
    
    public init(eventsProvider: EmotionEventsProvider) {
        self.eventsProvider = eventsProvider
        self.eventsProvider.add { [weak self] in
            self?.presentEvents()
        }
    }
}

extension EmotionEventsUseCaseImpl: EmotionEventsUseCase {
    public func eventOutputReady() {
        presentEvents()
    }
    
    public func delete(event: EmotionEventsUseCaseObjects.Event) {
        eventsProvider.delete(event: eventsProvider.events.first { $0.date == event.date }!)
        presentEvents()
    }
}
