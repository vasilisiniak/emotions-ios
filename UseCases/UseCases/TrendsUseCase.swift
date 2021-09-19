import Foundation
import WidgetKit
import Model

public protocol TrendsUseCaseOutput: AnyObject {
    func present(colors: [String])
    func present(range: (min: Date, max: Date))
    func present(selectedRange: (min: Date?, max: Date?))
    func present(noData: Bool, becauseOfRange: Bool)
    func presentEmotions()
}

public protocol TrendsUseCase {
    func eventOutputReady()
    func eventAdd()
    func event(selectedRange: (min: Date?, max: Date?))
}

public final class TrendsUseCaseImpl {

    // MARK: - Private

    private let eventsProvider: EmotionEventsProvider
    private let settings: Settings

    private func presentColors() {
        let events = eventsProvider.events
        guard events.count > 1 else {
            output.present(colors: [])
            output.present(noData: true, becauseOfRange: false)
            return
        }

        let filteredEvents = events.filtered(range: settings.range)
        guard filteredEvents.count > 1 else {
            output.present(colors: [])
            output.present(noData: true, becauseOfRange: true)
            return
        }

        output.present(colors: filteredEvents.map(\.color))
        output.present(noData: false, becauseOfRange: false)
    }

    private func presentRange() {
        let events = eventsProvider.events.sorted { $0.date < $1.date }
        guard events.count > 0 else {
            output.present(range: (min: Date(), max: Date()))
            return
        }
        output.present(range: (min: events.first!.date, max: events.last!.date))
    }

    // MARK: - Public

    public weak var output: TrendsUseCaseOutput!

    public init(eventsProvider: EmotionEventsProvider, settings: Settings) {
        self.eventsProvider = eventsProvider
        self.settings = settings
        self.eventsProvider.add { [weak self] in
            self?.presentRange()
            self?.presentColors()
        }
    }
}

extension TrendsUseCaseImpl: TrendsUseCase {
    public func eventAdd() {
        output.presentEmotions()
    }

    public func eventOutputReady() {
        presentRange()
        presentColors()
        output.present(selectedRange: settings.range)
    }

    public func event(selectedRange: (min: Date?, max: Date?)) {
        settings.range = selectedRange
        WidgetCenter.shared.reloadAllTimelines()
        presentColors()
    }
}
