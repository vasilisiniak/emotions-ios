import Foundation
import Model

public final class EditEventNameUseCaseImpl {

    // MARK: - Private

    private let provider: EmotionEventsProvider
    private let originalName: String
    private let originalDetails: String?
    private let date: Date
    private let selectedEmotions: [String]
    private let color: String
    private var name: String?
    private var details: String?

    func onChange() {
        let hasChanges = (name != originalName) || (details != originalDetails)
        let valid = (name?.isEmpty == false)
        output.present(addAvailable: valid && hasChanges)
    }

    // MARK: - Public

    public weak var output: EventNameUseCaseOutput!

    public init(provider: EmotionEventsProvider, name: String, details: String?, date: Date, selectedEmotions: [String], color: String) {
        self.provider = provider
        self.selectedEmotions = selectedEmotions
        self.name = name
        self.details = details
        self.originalName = name
        self.originalDetails = details
        self.date = date
        self.color = color
    }
}

extension EditEventNameUseCaseImpl: EventNameUseCase {
    public var mode: EventNameUseCaseMode { .edit }

    public func eventOutputReady() {
        output.present(selectedEmotions: selectedEmotions, color: color)
        output.present(name: originalName, details: originalDetails)
        output.presentCancelSaveButtons()
        output.present(addAvailable: false)
    }

    public func eventCancel() {
        output.presentCancel()
    }

    public func event(nameChanged: String?) {
        name = nameChanged
        onChange()
    }

    public func event(detailsChanged: String?) {
        details = detailsChanged
        onChange()
    }

    public func eventAdd() {
        let event = EmotionEvent(date: date, name: name!, details: details, emotions: selectedEmotions.joined(separator: ", "), color: color)
        provider.update(event: event)
        output.presentEmotions()
    }
}
