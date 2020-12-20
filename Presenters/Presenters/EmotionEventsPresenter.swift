import Foundation
import UIKit
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
                date = event.date
                timeString = Event.timeFormatter.string(from: event.date)
                dateString = Event.dateFormatter.string(from: event.date)
                name = event.name
                emotions = event.emotions
                color = UIColor(hex: event.color)
            }
            
            // MARK: - Public
            
            public let timeString: String
            public let name: String
            public let emotions: String
            public let color: UIColor
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
    func delete(indexPath: IndexPath)
}

public final class EmotionEventsPresenterImpl {
    
    // MARK: - Private
    
    private var events: [EmotionEventsUseCaseObjects.Event] = []
    private var groups: [EmotionEventsPresenterObjects.EventsGroup] = []
    
    // MARK: - Public
    
    public weak var output: EmotionEventsPresenterOutput!
    public var useCase: EmotionEventsUseCase!
    
    public init() {}
}

extension EmotionEventsPresenterImpl: EmotionEventsPresenter {
    public func eventViewReady() {
        useCase.eventOutputReady()
    }
    
    public func delete(indexPath: IndexPath) {
        let event = groups[indexPath.section].events[indexPath.row]
        useCase.delete(event: events.first { $0.date == event.date }!)
    }
}

extension EmotionEventsPresenterImpl: EmotionEventsUseCaseOutput {
    public func present(events: [EmotionEventsUseCaseObjects.Event]) {
        self.events = events
        let events = events.map { EmotionEventsPresenterObjects.EventsGroup.Event(event: $0) }
        let groupedEvents = Dictionary(grouping: events) { $0.dateString }
        groups = groupedEvents
            .map { EmotionEventsPresenterObjects.EventsGroup(date: $0.value.first!.date, dateString: $0.key, events: $0.value) }
            .sorted { $0.date.compare($1.date) == .orderedDescending }
        output.show(eventsGroups: groups)
    }
}
