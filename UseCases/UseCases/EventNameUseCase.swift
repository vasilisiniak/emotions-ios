import Foundation
import Model

public enum EventNameUseCaseMode {
    case create
    case edit
}

public protocol EventNameUseCaseOutput: AnyObject {
    func present(selectedEmotions: [String], color: String)
    func present(date: Date, name: String, details: String?)
    func present(addAvailable: Bool)
    func presentCancel()
    func presentEmotions()
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
    var mode: EventNameUseCaseMode { get }
}

public final class EventNameUseCaseImpl {

    // MARK: - Private

    private let provider: EmotionEventsProvider
    private let analytics: AnalyticsManager
    private let selectedEmotions: [String]
    private let color: String
    private var name: String?
    private var details: String?
    private var date = Date()

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
    public var mode: EventNameUseCaseMode { .create }

    public func eventOutputReady() {
        output.present(selectedEmotions: selectedEmotions, color: color)
        output.presentBackAddButtons()
        output.present(addAvailable: false)
    }

    public func eventCancel() {
        output.presentCancel()
    }

    public func event(nameChanged: String?) {
        name = nameChanged
        output.present(addAvailable: (name ?? "").count > 0)
    }

    public func event(detailsChanged: String?) {
        details = detailsChanged
    }

    public func event(dateChanged: Date) {
        date = dateChanged
    }

    public func eventAdd() {
        let event = EmotionEvent(date: date, name: name!, details: details, emotions: selectedEmotions.joined(separator: ", "), color: color)
        provider.log(event: event)
        analytics.track(.eventCreated(hasDetails: (details?.isEmpty == false)))
        output.presentEmotions()
    }
}
