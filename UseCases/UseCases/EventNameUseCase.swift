import Foundation
import Model

public enum EventNameUseCaseObjects {

    public enum Mode {
        case create
        case edit
    }

    public struct Emotion {

        // MARK: - Internal

        init(_ name: String, _ color: String) {
            self.name = name
            self.color = color
        }

        // MARK: - Public

        public let name: String
        public let color: String
    }
}

public protocol EventNameUseCaseOutput: AnyObject {
    func present(selectedEmotions: [EventNameUseCaseObjects.Emotion], color: String)
    func present(date: Date, name: String?, details: String?)
    func present(addAvailable: Bool)
    func presentCancel()
    func presentEmotions()
    func presentEvents()
    func presentBackAddButtons()
    func presentCancelSaveButtons()
}

public protocol EventNameUseCase {
    func eventOutputReady()
    func eventCancel()
    func event(nameChanged: String?)
    func event(detailsChanged: String?)
    func event(dateChanged: Date)
    func eventAdd()
    var mode: EventNameUseCaseObjects.Mode { get }
}

public final class EventNameUseCaseImpl {

    // MARK: - Private

    private let eventsProvider: EmotionEventsProvider
    private let groupsProvider: EmotionsGroupsProvider
    private let analytics: AnalyticsManager
    private let state: StateManager
    private let selectedEmotions: [String]
    private let color: String
    private var name: String?
    private var details: String?
    private var date = Date()

    private func color(_ emotion: String) -> String {
        let groups = groupsProvider.emotionsGroups
        let group = groups.first { $0.emotions.contains { $0.name == emotion } } ?? groups[0]
        return group.color
    }

    private func presentEmotions() {
        let emotions = selectedEmotions.map { EventNameUseCaseObjects.Emotion($0, color($0)) }
        output.present(selectedEmotions: emotions, color: color)
    }

    private func saveState() {
        state.emotionNameState = (name: name, details: details, date: date)
    }

    // MARK: - Public

    public weak var output: EventNameUseCaseOutput!

    public init(
        eventsProvider: EmotionEventsProvider,
        groupsProvider: EmotionsGroupsProvider,
        analytics: AnalyticsManager,
        state: StateManager,
        selectedEmotions: [String],
        color: String
    ) {
        self.eventsProvider = eventsProvider
        self.groupsProvider = groupsProvider
        self.analytics = analytics
        self.state = state
        self.selectedEmotions = selectedEmotions
        self.color = color

        name = state.emotionNameState?.name
        details = state.emotionNameState?.details
        date = state.emotionNameState?.date ?? Date()
    }
}

extension EventNameUseCaseImpl: EventNameUseCase {
    public var mode: EventNameUseCaseObjects.Mode { .create }

    public func eventOutputReady() {
        presentEmotions()
        output.present(date: date, name: name, details: details)
        output.presentBackAddButtons()
        output.present(addAvailable: (name ?? "").count > 0)
    }

    public func eventCancel() {
        state.emotionNameState = nil
        output.presentCancel()
    }

    public func event(nameChanged: String?) {
        name = nameChanged
        saveState()
        output.present(addAvailable: (name ?? "").count > 0)
    }

    public func event(detailsChanged: String?) {
        details = detailsChanged
        saveState()
    }

    public func event(dateChanged: Date) {
        date = dateChanged
        saveState()
    }

    public func eventAdd() {
        let event = EmotionEvent(date: date, name: name!, details: details, emotions: selectedEmotions.joined(separator: ", "), color: color)
        eventsProvider.log(event: event)
        state.emotionNameState = nil
        analytics.track(.eventCreated(hasDetails: (details?.isEmpty == false)))
        output.presentEmotions()
    }
}
