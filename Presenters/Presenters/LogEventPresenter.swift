import UIKit
import UseCases

public protocol LogEventPresenterOutput: class {
    func showEmotions()
}

public protocol LogEventPresenter: LogEventEventsHandler {}

public class LogEventPresenterImpl {
    
    // MARK: - Public
    
    public weak var output: LogEventPresenterOutput!
    public var useCase: LogEventUseCase!
    
    public init() {}
}

extension LogEventPresenterImpl: LogEventPresenter {}

extension LogEventPresenterImpl: LogEventEventsHandler {
    public func eventViewReady() {
        useCase.eventViewReady()
    }
}

extension LogEventPresenterImpl: LogEventUseCaseOutput {
    public func presentEmotions() {
        output.showEmotions()
    }
}
