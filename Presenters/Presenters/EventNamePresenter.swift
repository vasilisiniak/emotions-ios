import UIKit
import UseCases

public protocol EventNamePresenterOutput: AnyObject {
    func show(title: String, name: String, details: String)
    func show(backButton: String)
    func show(addButton: String)
    func show(addButtonEnabled: Bool)
    func show(selectedEmotions: String)
    func show(date: Date, name: String, details: String?)
    func show(color: UIColor)
    func showKeyboard()
}

public protocol EventNameRouter: AnyObject {
    func routeCancel()
    func routeEmotions()
}

public protocol EventNamePresenter {
    func eventViewReady()
    func eventViewDidAppear()
    func eventCancelTap()
    func eventAddTap()
    func event(nameChanged: String?)
    func event(detailsChanged: String?)
    func event(dateChanged: Date)
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

    public func event(nameChanged: String?) {
        useCase.event(nameChanged: nameChanged)
    }

    public func event(detailsChanged: String?) {
        useCase.event(detailsChanged: detailsChanged)
    }

    public func event(dateChanged: Date) {
        useCase.event(dateChanged: dateChanged)
    }

    public func eventAddTap() {
        useCase.eventAdd()
    }

    public func eventViewReady() {
        let title: String
        switch useCase.mode {
        case .create: title = "Новая запись"
        case .edit: title = "Изменить запись"
        }

        output.show(title: title, name: "Что произошло?", details: "Подробности, мысли, переживания...")
        useCase.eventOutputReady()
    }

    public func eventCancelTap() {
        useCase.eventCancel()
    }
}

extension EventNamePresenterImpl: EventNameUseCaseOutput {
    public func presentBackAddButtons() {
        output.show(backButton: "Отмена")
        output.show(addButton: "Добавить")
    }

    public func presentCancelSaveButtons() {
        output.show(backButton: "Отмена")
        output.show(addButton: "Сохранить")
    }

    public func presentEmotions() {
        router.routeEmotions()
    }

    public func present(date: Date, name: String, details: String?) {
        output.show(date: date, name: name, details: details)
    }

    public func present(addAvailable: Bool) {
        output.show(addButtonEnabled: addAvailable)
    }

    public func present(selectedEmotions: [String], color: String) {
        output.show(selectedEmotions: selectedEmotions.joined(separator: ", "))
        output.show(color: UIColor(hex: color))
    }

    public func presentCancel() {
        router.routeCancel()
    }
}
