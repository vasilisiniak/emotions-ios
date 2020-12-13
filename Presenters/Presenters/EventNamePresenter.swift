import UIKit
import UseCases

public protocol EventNamePresenterOutput: class {
    func show(title: String)
    func show(backButton: String)
    func show(addButton: String)
    func show(addButtonEnabled: Bool)
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
    public func eventViewDidAppear() {
        useCase.eventViewDidAppear()
    }
    
    public func event(descriptionChanged: String?) {
        useCase.event(descriptionChanged: descriptionChanged)
    }
    
    public func eventAddTap() {
        useCase.eventAddTap()
    }
    
    public func eventViewReady() {
        useCase.eventViewReady()
    }
    
    public func eventBackTap() {
        useCase.eventBackTap()
    }
}

extension EventNamePresenterImpl: EventNameUseCaseOutput {
    public func present(addButton: String) {
        output.show(addButton: addButton)
    }
    
    public func present(addButtonEnabled: Bool) {
        output.show(addButtonEnabled: addButtonEnabled)
    }
    
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
