import Foundation
import Model

public enum EmotionEventsUseCaseObjects {

    public struct Event {

        // MARK: - Fileprivate

        fileprivate init(event: EmotionEvent) {
            date = event.date
            name = event.name
            details = event.details
            emotions = event.emotions
            color = event.color
        }

        // MARK: - Public

        public let date: Date
        public let name: String
        public let details: String?
        public let emotions: String
        public let color: String
    }
}

public protocol EmotionEventsUseCaseOutput: AnyObject {
    func present(events: [EmotionEventsUseCaseObjects.Event], expanded: Bool)
    func present(noData: Bool)
    func present(blur: Bool)
    func present(shareEvent: EmotionEventsUseCaseObjects.Event)
    func present(editEvent: EmotionEventsUseCaseObjects.Event)
    func presentEmotions()
    func presentSwipeInfo()
    func presentFaceIdError()
    func present(url: String)
}

public protocol EmotionEventsUseCase {
    func eventOutputReady()
    func eventOutputToBeShown()
    func eventOutputIsShown(info: String)
    func event(shareEvent: EmotionEventsUseCaseObjects.Event)
    func event(deleteEvent: EmotionEventsUseCaseObjects.Event)
    func event(editEvent: EmotionEventsUseCaseObjects.Event)
    func eventToggleExpand()
    func eventAdd()
    func eventInfoTap()
    func eventStartUnsafe()
    func eventEndUnsafe(info: String)
    func eventFaceIdInfo()
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
    private let lock: LockManager
    private let analytics: AnalyticsManager
    private let eventsProvider: EmotionEventsProvider
    private let faceIdInfo: String
    private var token: AnyObject?

    private func presentEvents() {
        let events = eventsProvider.events
            .map(EmotionEventsUseCaseObjects.Event.init(event:))
            .sorted { $0.date > $1.date }
        output.present(events: events, expanded: settings.useExpandedDiary)
        output.present(noData: events.count == 0)
    }

    private func unlockEvents(info: String) {
        lock.evaluate(info: info) { [output] available, passed in
            DispatchQueue.main.async {
                guard available else {
                    output?.presentFaceIdError()
                    return
                }
                if passed {
                    output?.present(blur: false)
                }
                else {
                    output?.presentEmotions()
                }
            }
        }
    }

    // MARK: - Public

    public weak var output: EmotionEventsUseCaseOutput!

    public init(
        settings: Settings,
        lock: LockManager,
        analytics: AnalyticsManager,
        eventsProvider: EmotionEventsProvider,
        faceIdInfo: String
    ) {
        self.settings = settings
        self.lock = lock
        self.analytics = analytics
        self.eventsProvider = eventsProvider
        self.faceIdInfo = faceIdInfo

        self.eventsProvider.add { [weak self] in self?.presentEvents() }
        token = self.settings.add { [weak self] _ in self?.presentEvents() }
    }
}

extension EmotionEventsUseCaseImpl: EmotionEventsUseCase {
    public func eventOutputToBeShown() {
        if settings.useFaceId {
            output.present(blur: true)
        }
        else {
            output.present(blur: false)
        }
    }

    public func eventOutputIsShown(info: String) {
        guard settings.useFaceId else { return }
        unlockEvents(info: info)
    }

    public func eventStartUnsafe() {
        output.present(blur: settings.protectSensitiveData)
    }

    public func eventEndUnsafe(info: String) {
        if settings.useFaceId {
            output.present(blur: true)
            unlockEvents(info: info)
        }
        else {
            output.present(blur: false)
        }
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
        presentEvents()
    }

    public func event(editEvent: EmotionEventsUseCaseObjects.Event) {
        analytics.track(.editEvent)
        output.present(editEvent: editEvent)
    }

    public func eventFaceIdInfo() {
        output.present(url: faceIdInfo)
    }

    public func eventInfoTap() {
        output.presentSwipeInfo()
    }

    public func eventToggleExpand() {
        analytics.track(.toggleExpand)
    }
}
