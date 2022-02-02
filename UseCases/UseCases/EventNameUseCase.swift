import Foundation
import Model

public protocol EventNameUseCaseOutput: AnyObject {
    func present(selectedEmotions: [String], color: String)
    func present(emotion: String)
    func present(addAvailable: Bool)
    func presentCancel()
    func presentEmotions()
    func presentBackAddButtons()
    func presentCancelSaveButtons()
}

public protocol EventNameUseCase {
    func eventOutputReady()
    func eventCancel()
    func event(descriptionChanged: String?)
    func eventAdd()
}

public final class EventNameUseCaseImpl {

    // MARK: - Private

    private let provider: EmotionEventsProvider
    private let analytics: AnalyticsManager
    private let selectedEmotions: [String]
    private let color: String
    private var description: String?

    // MARK: - Public

    public weak var output: EventNameUseCaseOutput!

    public init(provider: EmotionEventsProvider, analytics: AnalyticsManager, selectedEmotions: [String], color: String) {
        self.provider = provider
        self.analytics = analytics
        self.selectedEmotions = selectedEmotions
        self.color = color
    }
}

extension EventNameUseCaseImpl: EventNameUseCase {
    public func eventOutputReady() {
        output.present(selectedEmotions: selectedEmotions, color: color)
        output.presentBackAddButtons()
        output.present(addAvailable: false)
    }

    public func eventCancel() {
        output.presentCancel()
    }

    public func event(descriptionChanged: String?) {
        description = descriptionChanged
        output.present(addAvailable: (description ?? "").count > 0)
    }

    public func eventAdd() {
        let event = EmotionEvent(date: Date(), name: description!, emotions: selectedEmotions.joined(separator: ", "), color: color)
        provider.log(event: event)
        analytics.track(.eventCreated)
        output.presentEmotions()
    }
}
