import Foundation
import Model

public final class EditEventNameUseCaseImpl {

    // MARK: - Private

    private let provider: EmotionEventsProvider
    private let emotion: String
    private let date: Date
    private let selectedEmotions: [String]
    private let color: String
    private var description: String?

    // MARK: - Public

    public weak var output: EventNameUseCaseOutput!

    public init(provider: EmotionEventsProvider, emotion: String, date: Date, selectedEmotions: [String], color: String) {
        self.provider = provider
        self.selectedEmotions = selectedEmotions
        self.emotion = emotion
        self.date = date
        self.color = color
    }
}

extension EditEventNameUseCaseImpl: EventNameUseCase {
    public func eventOutputReady() {
        output.present(selectedEmotions: selectedEmotions, color: color)
        output.present(emotion: emotion)
        output.presentCancelSaveButtons()
        output.present(addAvailable: false)
    }

    public func eventBack() {
        output.presentBack()
    }

    public func event(descriptionChanged: String?) {
        description = descriptionChanged
        output.present(addAvailable: (description ?? "").count > 0 && (description != emotion))
    }

    public func eventAdd() {
        let event = EmotionEvent(date: date, name: description!, emotions: selectedEmotions.joined(separator: ", "), color: color)
        provider.update(event: event)
        output.presentEmotions()
    }
}
