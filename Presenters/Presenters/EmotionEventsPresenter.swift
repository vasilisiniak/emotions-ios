import UseCases

public enum EmotionEventsPresenterObjects {
    
    public struct EventsGroup {
        
        public struct Event {
            
            // MARK: - Fileprivate
            
            init(event: EmotionEventsUseCaseObjects.Event) {
                self.time = "14:40"
                self.name = event.name
                self.emotions = event.emotions
            }
            
            // MARK: - Public
            
            public let time: String
            public let name: String
            public let emotions: String
        }
        
        // MARK: - Public
        
        public let date: String
        public let events: [Event]
    }
}

public protocol EmotionEventsPresenterOutput: class {
    func show(eventsGroups: [EmotionEventsPresenterObjects.EventsGroup])
}

public protocol EmotionEventsPresenter: EmotionEventsEventsHandler {}

public class EmotionEventsPresenterImpl {
    
    // MARK: - Public
    
    public weak var output: EmotionEventsPresenterOutput!
    public var useCase: EmotionEventsUseCase!
    
    public init() {}
}

extension EmotionEventsPresenterImpl: EmotionEventsPresenter {
    public func eventViewReady() {
        useCase.eventViewReady()
    }
}

extension EmotionEventsPresenterImpl: EmotionEventsUseCaseOutput {
    public func present(events: [EmotionEventsUseCaseObjects.Event]) {
        let events = events.map { EmotionEventsPresenterObjects.EventsGroup.Event(event: $0) }
        let groups = [
            EmotionEventsPresenterObjects.EventsGroup(date: "14 апреля, суббота", events: events),
            EmotionEventsPresenterObjects.EventsGroup(date: "14 апреля, суббота", events: events),
            EmotionEventsPresenterObjects.EventsGroup(date: "14 апреля, суббота", events: events),
            EmotionEventsPresenterObjects.EventsGroup(date: "14 апреля, суббота", events: events),
            EmotionEventsPresenterObjects.EventsGroup(date: "14 апреля, суббота", events: events)
        ]
        output.show(eventsGroups: groups)
    }
}
