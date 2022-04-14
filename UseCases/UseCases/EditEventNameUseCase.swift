import Foundation
import Model

public final class EditEventNameUseCaseImpl {

    private struct Event: Equatable {
        var date: Date
        var name: String
        var details: String?

        var valid: Bool { !name.isEmpty }
    }

    // MARK: - Private

    private let eventsProvider: EmotionEventsProvider
    private let groupsProvider: EmotionsGroupsProvider
    private let analytics: AnalyticsManager
    private let original: Event
    private var current: Event
    private let selectedEmotions: [String]
    private let color: String

    private func onChange() {
        let hasChanges = (original != current)
        output.present(addAvailable: hasChanges && current.valid)
    }

    private func color(_ emotion: String) -> String {
        let groups = groupsProvider.emotionsGroups
        let group = groups.first { $0.emotions.contains { $0.name == emotion } } ?? groups[0]
        return group.color
    }

    private func presentEmotions() {
        let emotions = selectedEmotions.map { EventNameUseCaseObjects.Emotion($0, color($0)) }
        output.present(selectedEmotions: emotions, color: color)
    }

    // MARK: - Public

    public weak var output: EventNameUseCaseOutput!

    public init(
        eventsProvider: EmotionEventsProvider,
        groupsProvider: EmotionsGroupsProvider,
        analytics: AnalyticsManager,
        name: String,
        details: String?,
        date: Date,
        selectedEmotions: [String],
        color: String
    ) {
        self.eventsProvider = eventsProvider
        self.groupsProvider = groupsProvider
        self.analytics = analytics
        self.selectedEmotions = selectedEmotions
        self.color = color

        original = Event(date: date, name: name, details: details)
        current = original
    }
}

extension EditEventNameUseCaseImpl: EventNameUseCase {
    public var mode: EventNameUseCaseObjects.Mode { .edit }

    public func eventOutputReady() {
        presentEmotions()
        output.present(date: original.date, name: original.name, details: original.details)
        output.presentCancelSaveButtons()
        output.present(addAvailable: false)
    }

    public func eventCancel() {
        output.presentCancel()
    }

    public func event(nameChanged: String?) {
        current.name = nameChanged ?? ""
        onChange()
    }

    public func event(detailsChanged: String?) {
        current.details = detailsChanged
        onChange()
    }

    public func event(dateChanged: Date) {
        current.date = dateChanged
        onChange()
    }

    public func eventAdd() {
        let event = EmotionEvent(date: current.date, name: current.name, details: current.details, emotions: selectedEmotions.joined(separator: ", "), color: color)
        eventsProvider.update(event: event, for: original.date)
        analytics.track(.eventEdited(hasDetails: (current.details?.isEmpty == false)))
        output.presentEvents()
    }
}
