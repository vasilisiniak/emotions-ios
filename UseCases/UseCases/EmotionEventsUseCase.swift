import Foundation
import WidgetKit
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
    func present(noData: Bool)
    func present(shareEvent: EmotionEventsUseCaseObjects.Event)
    func presentEmotions()
}

public protocol EmotionEventsUseCase {
    func eventOutputReady()
    func event(shareEvent: EmotionEventsUseCaseObjects.Event)
    func event(deleteEvent: EmotionEventsUseCaseObjects.Event)
    func eventAdd()
}

public final class EmotionEventsUseCaseImpl {
    
    // MARK: - Private
    
    private let eventsProvider: EmotionEventsProvider
    
    private func presentEvents() {
        let events = eventsProvider.events
            .map(EmotionEventsUseCaseObjects.Event.init(event:))
            .sorted { $0.date > $1.date }
        output.present(events: events)
        output.present(noData: events.count == 0)
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
    public func eventAdd() {
        output.presentEmotions()
    }
    
    public func eventOutputReady() {
        presentEvents()
    }

    public func event(shareEvent: EmotionEventsUseCaseObjects.Event) {
        output.present(shareEvent: shareEvent)
    }
    
    public func event(deleteEvent: EmotionEventsUseCaseObjects.Event) {
        eventsProvider.delete(event: eventsProvider.events.first { $0.date == deleteEvent.date }!)
        WidgetCenter.shared.reloadAllTimelines()
        presentEvents()
    }
}
