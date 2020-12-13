public protocol LogEventUseCaseOutput: class {
    func presentEmotions()
}

public protocol LogEventEventsHandler {
    func eventViewReady()
}

public protocol LogEventUseCase: LogEventEventsHandler {}

public class LogEventUseCaseImpl: LogEventUseCase {
    
    // MARK: - Public
    
    public weak var output: LogEventUseCaseOutput!
    
    public init() {}
}

extension LogEventUseCaseImpl: LogEventEventsHandler {
    public func eventViewReady() {
        output.presentEmotions()
    }
}
