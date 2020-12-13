import UIKit
import UseCases

public protocol EventNamePresenterOutput: class {
    func show(title: String)
    func show(backButton: String)
    func show(placeholder: String)
    func show(selectedEmotions: String)
    func showKeyboard()
}

public protocol EventNameRouter: class {
    func routeBack()
}

public protocol EventNamePresenter: EventNameEventsHandler {}

public class EventNamePresenterImpl: EventNamePresenter {
    
    // MARK: - Public
    
    public weak var output: EventNamePresenterOutput!
    public weak var router: EventNameRouter!
    public var useCase: EventNameUseCase!
    
    public init() {}
}

extension EventNamePresenterImpl: EventNameEventsHandler {
    public func eventViewReady() {
        useCase.eventViewReady()
    }
    
    public func eventBackTap() {
        useCase.eventBackTap()
    }
}

extension EventNamePresenterImpl: EventNameUseCaseOutput {
    public func present(title: String) {
        output.show(title: title)
    }
    
    public func present(backButton: String) {
        output.show(backButton: backButton)
    }
    
    public func present(placeholder: String) {
        output.show(placeholder: placeholder)
    }
    
    public func present(selectedEmotions: [String]) {
        output.show(selectedEmotions: selectedEmotions.joined(separator: ", "))
    }
    
    public func presentKeyboard() {
        output.showKeyboard()
    }
    
    public func presentBack() {
        router.routeBack()
    }
}
