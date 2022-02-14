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

    private let provider: EmotionEventsProvider
    private let original: Event
    private var current: Event
    private let selectedEmotions: [String]
    private let color: String

    func onChange() {
        let hasChanges = (original != current)
        output.present(addAvailable: hasChanges && current.valid)
    }

    // MARK: - Public

    public weak var output: EventNameUseCaseOutput!

    public init(provider: EmotionEventsProvider, name: String, details: String?, date: Date, selectedEmotions: [String], color: String) {
        self.provider = provider
        self.selectedEmotions = selectedEmotions
        self.color = color

        original = Event(date: date, name: name, details: details)
        current = original
    }
}

extension EditEventNameUseCaseImpl: EventNameUseCase {
    public var mode: EventNameUseCaseMode { .edit }

    public func eventOutputReady() {
        output.present(selectedEmotions: selectedEmotions, color: color)
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
        provider.update(event: event, for: original.date)
        output.presentEmotions()
    }
}
