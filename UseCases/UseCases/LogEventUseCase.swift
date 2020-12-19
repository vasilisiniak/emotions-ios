public protocol LogEventUseCaseOutput: class {
    func presentEmotions()
}

public protocol LogEventUseCase {
    func eventOutputReady()
}

public final class LogEventUseCaseImpl {
    
    // MARK: - Public
    
    public weak var output: LogEventUseCaseOutput!
    public init() {}
}

extension LogEventUseCaseImpl: LogEventUseCase {
    public func eventOutputReady() {
        output.presentEmotions()
    }
}
