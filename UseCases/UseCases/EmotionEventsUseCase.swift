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

public protocol EmotionEventsUseCaseOutput: AnyObject {
    func present(events: [EmotionEventsUseCaseObjects.Event])
    func present(noData: Bool)
    func present(blur: Bool)
    func present(shareEvent: EmotionEventsUseCaseObjects.Event)
    func present(editEvent: EmotionEventsUseCaseObjects.Event)
    func presentEmotions()
    func presentSwipeInfo()
}

public protocol EmotionEventsUseCase {
    func eventOutputReady()
    func event(shareEvent: EmotionEventsUseCaseObjects.Event)
    func event(deleteEvent: EmotionEventsUseCaseObjects.Event)
    func event(editEvent: EmotionEventsUseCaseObjects.Event)
    func eventAdd()
    func eventStartUnsafe()
}

public final class EmotionEventsUseCaseImpl {

    private enum Constants {
        fileprivate static let FirstEventDisplay = "UseCases.EmotionEventsUseCaseImpl.FirstEventDisplay"
    }

    // MARK: - Private

    private var firstEventDisplay: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.FirstEventDisplay)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.FirstEventDisplay)
            UserDefaults.standard.synchronize()
        }
    }

    private let settings: Settings
    private let analytics: AnalyticsManager
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

    public init(settings: Settings, analytics: AnalyticsManager, eventsProvider: EmotionEventsProvider) {
        self.settings = settings
        self.analytics = analytics
        self.eventsProvider = eventsProvider
        self.eventsProvider.add { [weak self] in self?.presentEvents() }
    }
}

extension EmotionEventsUseCaseImpl: EmotionEventsUseCase {
    public func eventStartUnsafe() {
        output.present(blur: settings.protectSensitiveData)
    }

    public func eventAdd() {
        output.presentEmotions()
    }

    public func eventOutputReady() {
        presentEvents()

        if !firstEventDisplay && eventsProvider.events.count > 0 {
            firstEventDisplay = true
            output.presentSwipeInfo()
        }
    }

    public func event(shareEvent: EmotionEventsUseCaseObjects.Event) {
        analytics.track(.shareEvent)
        output.present(shareEvent: shareEvent)
    }

    public func event(deleteEvent: EmotionEventsUseCaseObjects.Event) {
        analytics.track(.deleteEvent)
        eventsProvider.delete(event: eventsProvider.events.first { $0.date == deleteEvent.date }!)
        WidgetCenter.shared.reloadAllTimelines()
        presentEvents()
    }

    public func event(editEvent: EmotionEventsUseCaseObjects.Event) {
        analytics.track(.editEvent)
        output.present(editEvent: editEvent)
    }
}
