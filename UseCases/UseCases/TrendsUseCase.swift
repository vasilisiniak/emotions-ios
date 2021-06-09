import Model

public protocol TrendsUseCaseOutput: AnyObject {
    func present(colors: [String])
    func present(noData: Bool)
    func presentEmotions()
}

public protocol TrendsUseCase {
    func eventOutputReady()
    func eventAdd()
}

public final class TrendsUseCaseImpl {
    
    // MARK: - Private
    
    private let eventsProvider: EmotionEventsProvider
    
    private func presentColors() {
        let colors = eventsProvider.events
            .sorted { $0.date < $1.date }
            .map(\.color)
        output.present(colors: colors)
        output.present(noData: colors.count < 2)
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
    public func eventAdd() {
        output.presentEmotions()
    }
    
    public func eventOutputReady() {
        presentColors()
    }
}
