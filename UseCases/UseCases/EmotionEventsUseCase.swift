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

public protocol EmotionEventsUseCase {
    func eventOutputReady()
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
}
