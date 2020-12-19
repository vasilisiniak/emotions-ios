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
    func routeEmotions()
}

public protocol EventNamePresenter {
    func eventViewReady()
    func eventViewDidAppear()
    func eventBackTap()
    func eventAddTap()
    func event(descriptionChanged: String?)
}

public class EventNamePresenterImpl {
    
    // MARK: - Public
    
    public weak var output: EventNamePresenterOutput!
    public weak var router: EventNameRouter!
    public var useCase: EventNameUseCase!
    
    public init() {}
}

extension EventNamePresenterImpl: EventNamePresenter {
    public func eventViewDidAppear() {
        output.showKeyboard()
    }
    
    public func event(descriptionChanged: String?) {
        useCase.event(descriptionChanged: descriptionChanged)
    }
    
    public func eventAddTap() {
        useCase.eventAdd()
    }
    
    public func eventViewReady() {
        output.show(title: "Введите событие")
        output.show(backButton: "❮Назад")
        output.show(addButton: "Добавить")
        output.show(addButtonEnabled: false)
        output.show(placeholder: "Описание события")
        useCase.eventOutputReady()
    }
    
    public func eventBackTap() {
        useCase.eventBack()
    }
}

extension EventNamePresenterImpl: EventNameUseCaseOutput {
    public func presentEmotions() {
        router.routeEmotions()
    }
    
    public func present(addAvailable: Bool) {
        output.show(addButtonEnabled: addAvailable)
    }
    
    public func present(selectedEmotions: [String]) {
        output.show(selectedEmotions: selectedEmotions.joined(separator: ", "))
    }
    
    public func presentBack() {
        router.routeBack()
    }
}
