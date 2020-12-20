import Model

public protocol TrendsUseCaseOutput: class {
    func present(colors: [String])
}

public protocol TrendsUseCase {
    func eventOutputReady()
}

public final class TrendsUseCaseImpl {
    
    // MARK: - Private
    
    private let eventsProvider: EmotionEventsProvider
    
    private func presentColors() {
        let colors = eventsProvider.events
            .sorted { $0.date.compare($1.date) == .orderedAscending }
            .map { $0.color }
        output.present(colors: colors)
    }
    
    // MARK: - Public
    
    public weak var output: TrendsUseCaseOutput!
    
    public init(eventsProvider: EmotionEventsProvider) {
        self.eventsProvider = eventsProvider
        self.eventsProvider.add { [weak self] in
            self?.presentColors()
        }
    }
}

extension TrendsUseCaseImpl: TrendsUseCase {
    public func eventOutputReady() {
        presentColors()
    }
}
