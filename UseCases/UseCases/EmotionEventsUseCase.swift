import Foundation
import Model

public enum EmotionEventsUseCaseObjects {

    public struct Event {

        public struct Emotion {

            // MARK: - Fileprivate

            fileprivate init(_ name: String, _ color: String) {
                self.name = name
                self.color = color
            }

            // MARK: - Public

            public let name: String
            public let color: String
        }

        // MARK: - Fileprivate

        fileprivate init(event: EmotionEvent, emotions: [Emotion]) {
            date = event.date
            name = event.name
            details = event.details
            color = event.color
            self.emotions = emotions
        }

        // MARK: - Public

        public let date: Date
        public let name: String
        public let details: String?
        public let emotions: [Emotion]
        public let color: String
    }

    public enum Mode {
        case normal
        case deleted
    }
}

public protocol EmotionEventsUseCaseOutput: AnyObject {
    func present(events: [EmotionEventsUseCaseObjects.Event], expanded: Bool)
    func present(noData: Bool)
    func present(blur: Bool)
    func present(trash: Bool)
    func present(shareEvent: EmotionEventsUseCaseObjects.Event)
    func present(editEvent: EmotionEventsUseCaseObjects.Event)
    func presentEmotions()
    func presentSwipeInfo()
    func presentTrashInfo()
    func presentDeleteInfo()
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
    func event(restoreEvent: EmotionEventsUseCaseObjects.Event)
    func event(duplicateEvent: EmotionEventsUseCaseObjects.Event)
    func eventToggleExpand()
    func eventAdd()
    func eventInfoTap()
    func eventStartUnsafe()
    func eventEndUnsafe(info: String)
    func eventFaceIdInfo()
    func eventDeleteAll()

    var mode: EmotionEventsUseCaseObjects.Mode { get }
    var legacy: Bool { get }
}

public final class EmotionEventsUseCaseImpl {

    private enum Constants {
        static let FirstEventDisplay = "UseCases.EmotionEventsUseCaseImpl.FirstEventDisplay"
        static let TrashFirstEventDisplay = "UseCases.EmotionEventsUseCaseImpl.TrashFirstEventDisplay"
        static let FirstEventDelete = "UseCases.EmotionEventsUseCaseImpl.FirstEventDelete"
    }

    // MARK: - Private

    private var firstEventDisplay: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.FirstEventDisplay) }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.FirstEventDisplay)
            UserDefaults.standard.synchronize()
        }
    }

    private var trashFirstEventDisplay: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.TrashFirstEventDisplay) }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.TrashFirstEventDisplay)
            UserDefaults.standard.synchronize()
        }
    }

    private var firstEventDelete: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.FirstEventDelete) }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.FirstEventDelete)
            UserDefaults.standard.synchronize()
        }
    }

    private let settings: Settings
    private let lock: LockManager
    private let analytics: AnalyticsManager
    private let eventsProvider: EmotionEventsProvider
    private let groupsProvider: EmotionsGroupsProvider
    private let faceIdInfo: String
    private var token: AnyObject?

    private var erase: Bool {
        switch mode {
        case .normal: return settings.eraseImmediately
        case .deleted: return true
        }
    }

    private var showTrash: Bool {
        switch mode {
        case .normal: return !settings.eraseImmediately && !eventsProvider.deletedEvents.isEmpty
        case .deleted: return false
        }
    }

    private var events: [EmotionEvent] {
        switch mode {
        case .normal: return eventsProvider.events
        case .deleted: return eventsProvider.deletedEvents
        }
    }

    private func color(_ emotion: String) -> String {
        let groups = groupsProvider.emotionsGroups
        let group = groups.first { $0.emotions.contains { $0.name == emotion } } ?? groups[0]
        return group.color
    }

    private func presentEvents() {
        let events = self.events
            .map { event -> EmotionEventsUseCaseObjects.Event in
                let emotions = event.emotions
                    .components(separatedBy: ", ")
                    .map { EmotionEventsUseCaseObjects.Event.Emotion($0, color($0)) }
                return EmotionEventsUseCaseObjects.Event(event: event, emotions: emotions)
            }
            .sorted { $0.date > $1.date }
        output.present(events: events, expanded: settings.useExpandedDiary)
        output.present(noData: events.count == 0)
        output.present(trash: showTrash)
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

    public let mode: EmotionEventsUseCaseObjects.Mode

    public weak var output: EmotionEventsUseCaseOutput!

    public init(
        mode: EmotionEventsUseCaseObjects.Mode,
        settings: Settings,
        lock: LockManager,
        analytics: AnalyticsManager,
        eventsProvider: EmotionEventsProvider,
        groupsProvider: EmotionsGroupsProvider,
        faceIdInfo: String
    ) {
        self.mode = mode
        self.settings = settings
        self.lock = lock
        self.analytics = analytics
        self.eventsProvider = eventsProvider
        self.groupsProvider = groupsProvider
        self.faceIdInfo = faceIdInfo

        self.eventsProvider.add { [weak self] in self?.presentEvents() }
        token = self.settings.add { [weak self] _ in self?.presentEvents() }
    }
}

extension EmotionEventsUseCaseImpl: EmotionEventsUseCase {
    public var legacy: Bool { settings.useLegacyDiary }

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

        switch mode {
        case .normal:
            if !firstEventDisplay && eventsProvider.events.count > 0 {
                firstEventDisplay = true
                output.presentSwipeInfo()
            }
        case .deleted:
            if !trashFirstEventDisplay {
                trashFirstEventDisplay = true
                output.presentTrashInfo()
            }
        }
    }

    public func event(shareEvent: EmotionEventsUseCaseObjects.Event) {
        analytics.track(.shareEvent)
        output.present(shareEvent: shareEvent)
    }

    public func event(deleteEvent: EmotionEventsUseCaseObjects.Event) {
        if !firstEventDelete {
            firstEventDelete = true
            settings.eraseImmediately = false
            output.presentDeleteInfo()
        }

        if erase {
            analytics.track(.eraseEvent)
            eventsProvider.erase(event: events.first { $0.date == deleteEvent.date }!)
        }
        else {
            analytics.track(.deleteEvent)
            eventsProvider.delete(event: events.first { $0.date == deleteEvent.date }!)
        }
        presentEvents()
    }

    public func event(restoreEvent: EmotionEventsUseCaseObjects.Event) {
        analytics.track(.restoreEvent)
        eventsProvider.restore(event: events.first { $0.date == restoreEvent.date }!)
        presentEvents()
    }

    public func event(editEvent: EmotionEventsUseCaseObjects.Event) {
        analytics.track(.editEvent)
        output.present(editEvent: editEvent)
    }

    public func event(duplicateEvent: EmotionEventsUseCaseObjects.Event) {
        analytics.track(.duplicateEvent)
        eventsProvider.duplicate(event: events.first { $0.date == duplicateEvent.date }!)
        presentEvents()
        let newEvent = events
            .sorted { $0.date > $1.date }
            .first!
        let emotions = newEvent.emotions
            .components(separatedBy: ", ")
            .map { EmotionEventsUseCaseObjects.Event.Emotion($0, color($0)) }
        output.present(editEvent: EmotionEventsUseCaseObjects.Event(event: newEvent, emotions: emotions))
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

    public func eventDeleteAll() {
        switch mode {
        case .normal:
            fatalError()
        case .deleted:
            analytics.track(.eraseAll)
            eventsProvider.eraseAll()
            presentEvents()
        }
    }
}
