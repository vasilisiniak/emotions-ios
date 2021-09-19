import UIKit
import UseCases

public protocol EventNamePresenterOutput: AnyObject {
    func show(title: String)
    func show(backButton: String)
    func show(addButton: String)
    func show(addButtonEnabled: Bool)
    func show(selectedEmotions: String)
    func show(emotion: String)
    func show(color: UIColor)
    func showKeyboard()
}

public protocol EventNameRouter: AnyObject {
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

public final class EventNamePresenterImpl {

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
        useCase.eventOutputReady()
    }

    public func eventBackTap() {
        useCase.eventBack()
    }
}

extension EventNamePresenterImpl: EventNameUseCaseOutput {
    public func presentBackAddButtons() {
        output.show(backButton: "❮Назад")
        output.show(addButton: "Добавить")
    }

    public func presentCancelSaveButtons() {
        output.show(backButton: "Отмена")
        output.show(addButton: "Сохранить")
    }

    public func presentEmotions() {
        router.routeEmotions()
    }

    public func present(emotion: String) {
        output.show(emotion: emotion)
    }

    public func present(addAvailable: Bool) {
        output.show(addButtonEnabled: addAvailable)
    }

    public func present(selectedEmotions: [String], color: String) {
        output.show(selectedEmotions: selectedEmotions.joined(separator: ", "))
        output.show(color: UIColor(hex: color))
    }

    public func presentBack() {
        router.routeBack()
    }
}
