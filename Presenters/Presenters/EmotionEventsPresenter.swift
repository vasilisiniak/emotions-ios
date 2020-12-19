import Foundation
import UseCases

public enum EmotionEventsPresenterObjects {
    
    public struct EventsGroup {
        
        public struct Event {
            
            // MARK: - Private
            
            static let timeFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ru_RU")
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                return formatter
            }()
            
            static let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ru_RU")
                formatter.dateFormat = "d MMMM, EEEE"
                return formatter
            }()
            
            // MARK: - Fileprivate
            
            let date: Date
            let dateString: String
            
            init(event: EmotionEventsUseCaseObjects.Event) {
                self.date = event.date
                self.timeString = Event.timeFormatter.string(from: event.date)
                self.dateString = Event.dateFormatter.string(from: event.date)
                self.name = event.name
                self.emotions = event.emotions
            }
            
            // MARK: - Public
            
            public let timeString: String
            public let name: String
            public let emotions: String
        }
        
        // MARK: - Fileprivate
        
        let date: Date
        
        // MARK: - Public
        
        public let dateString: String
        public let events: [Event]
    }
}

public protocol EmotionEventsPresenterOutput: class {
    func show(eventsGroups: [EmotionEventsPresenterObjects.EventsGroup])
}

public protocol EmotionEventsPresenter {
    func eventViewReady()
}

public final class EmotionEventsPresenterImpl {
    
    // MARK: - Public
    
    public weak var output: EmotionEventsPresenterOutput!
    public var useCase: EmotionEventsUseCase!
    
    public init() {}
}

extension EmotionEventsPresenterImpl: EmotionEventsPresenter {
    public func eventViewReady() {
        useCase.eventOutputReady()
    }
}

extension EmotionEventsPresenterImpl: EmotionEventsUseCaseOutput {
    public func present(events: [EmotionEventsUseCaseObjects.Event]) {
        let events = events.map { EmotionEventsPresenterObjects.EventsGroup.Event(event: $0) }
        let groupedEvents = Dictionary(grouping: events) { $0.dateString }
        let groups = groupedEvents
            .map { EmotionEventsPresenterObjects.EventsGroup(date: $0.value.first!.date, dateString: $0.key, events: $0.value) }
            .sorted { $0.date.compare($1.date) == .orderedDescending }
        output.show(eventsGroups: groups)
    }
}
