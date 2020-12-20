import UIKit
import UseCases

public protocol LogEventPresenterOutput: class {
    func showEmotions()
    func show(message: String, button: String)
}

public protocol LogEventPresenter {
    func eventViewReady()
    func eventEventCreated()
}

public final class LogEventPresenterImpl {
    
    // MARK: - Public
    
    public weak var output: LogEventPresenterOutput!
    public var useCase: LogEventUseCase!
    
    public init() {}
}

extension LogEventPresenterImpl: LogEventPresenter {
    public func eventEventCreated() {
        useCase.eventEventCreated()
    }
    
    public func eventViewReady() {
        useCase.eventOutputReady()
    }
}

extension LogEventPresenterImpl: LogEventUseCaseOutput {
    public func presentFirstCreation() {
        output.show(message: "Запись сделана. Её можно увидеть на вкладке дневника", button: "OK")
    }

    public func presentSecondCreation() {
        output.show(message: "Теперь доступнка цветовая карта эмоций. Её можно увидеть на соответствующей вкладке", button: "OK")
    }

    public func presentEmotions() {
        output.showEmotions()
    }
}
