import UIKit
import UseCases

public protocol LogEventPresenterOutput: class {
    func showEmotions()
}

public protocol LogEventPresenter {
    func eventViewReady()
}

public class LogEventPresenterImpl {
    
    // MARK: - Public
    
    public weak var output: LogEventPresenterOutput!
    public var useCase: LogEventUseCase!
    
    public init() {}
}

extension LogEventPresenterImpl: LogEventPresenter {
    public func eventViewReady() {
        useCase.eventOutputReady()
    }
}

extension LogEventPresenterImpl: LogEventUseCaseOutput {
    public func presentEmotions() {
        output.showEmotions()
    }
}
