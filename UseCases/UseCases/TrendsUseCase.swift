import Foundation
import Model

public enum TrendsUseCaseObjects {

    public struct Stat {

        // MARK: - Public

        public let name: String
        public let color: String
        public let frequency: Double
    }
}

public protocol TrendsUseCaseOutput: AnyObject {
    func present(colors: [String])
    func present(stats: [TrendsUseCaseObjects.Stat])
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
    private let emotionsProvider: EmotionsGroupsProvider
    private let settings: Settings

    private func presentData() {
        let events = eventsProvider.events
        guard events.count > 1 else {
            output.present(colors: [])
            output.present(stats: [])
            output.present(noData: true, becauseOfRange: false)
            return
        }

        let filteredEvents = events.filtered(range: settings.range)
        guard filteredEvents.count > 1 else {
            output.present(colors: [])
            output.present(stats: [])
            output.present(noData: true, becauseOfRange: true)
            return
        }

        let emotions = filteredEvents.flatMap { $0.emotions.components(separatedBy: ", ") }
        let stats = emotionsProvider.emotionsGroups.map { group -> TrendsUseCaseObjects.Stat in
            let names = group.emotions.map(\.name)
            let filtered = emotions.filter { names.contains($0) }
            return TrendsUseCaseObjects.Stat(
                name: group.name,
                color: group.color,
                frequency: Double(filtered.count) / Double(emotions.count)
            )
        }

        output.present(colors: filteredEvents.map(\.color))
        output.present(stats: stats)
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

    public init(eventsProvider: EmotionEventsProvider, emotionsProvider: EmotionsGroupsProvider, settings: Settings) {
        self.eventsProvider = eventsProvider
        self.emotionsProvider = emotionsProvider
        self.settings = settings
        self.eventsProvider.add { [weak self] in
            self?.presentRange()
            self?.presentData()
        }
    }
}

extension TrendsUseCaseImpl: TrendsUseCase {
    public func eventAdd() {
        output.presentEmotions()
    }

    public func eventOutputReady() {
        presentRange()
        presentData()
        output.present(selectedRange: settings.range)
    }

    public func event(selectedRange: (min: Date?, max: Date?)) {
        settings.range = selectedRange
        presentData()
    }
}
