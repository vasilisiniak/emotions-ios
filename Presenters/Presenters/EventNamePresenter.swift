import UIKit
import UseCases

public enum EventNamePresenterObjects {

    public struct Emotion {

        // MARK: - Fileprivate

        fileprivate init(emotion: EventNameUseCaseObjects.Emotion) {
            name = emotion.name
            color = UIColor(hex: emotion.color)
        }

        fileprivate init(_ name: String, _ color: UIColor) {
            self.name = name
            self.color = color
        }

        // MARK: - Public

        public let name: String
        public let color: UIColor
    }
}

public protocol EventNamePresenterOutput: AnyObject {
    func show(title: String, name: String, details: String)
    func show(backButton: String)
    func show(addButton: String)
    func show(addButtonEnabled: Bool)
    func show(selectedEmotions: [EventNamePresenterObjects.Emotion])
    func show(date: Date, name: String?, details: String?)
    func show(color: UIColor)
    func showKeyboard()
}

public protocol EventNameRouter: AnyObject {
    func routeCancel()
    func routeEmotions()
    func routeEdit(emotions: [String])
    func routeEvents()
}

public protocol EventNamePresenter {
    func eventViewReady()
    func eventViewDidAppear()
    func eventCancelTap()
    func eventAddTap()
    func event(nameChanged: String?)
    func event(detailsChanged: String?)
    func event(dateChanged: Date)
    func event(emotionsChanged: [String], color: String)
    func eventEmotionsTap()
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

        output.show(title: title, name: "Событие", details: "Подробности, мысли, переживания...")
        useCase.eventOutputReady()
    }

    public func eventCancelTap() {
        useCase.eventCancel()
    }

    public func event(emotionsChanged: [String], color: String) {
        useCase.event(emotionsChanged: emotionsChanged, color: color)
    }

    public func eventEmotionsTap() {
        switch useCase.mode {
        case .edit: useCase.eventEditEmotions()
        case .create: break
        }
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

    public func presentEvents() {
        router.routeEvents()
    }

    public func present(date: Date, name: String?, details: String?) {
        output.show(date: date, name: name, details: details)
    }

    public func present(addAvailable: Bool) {
        output.show(addButtonEnabled: addAvailable)
    }

    public func present(selectedEmotions: [EventNameUseCaseObjects.Emotion], color: String) {
        var emotions = selectedEmotions.map(EventNamePresenterObjects.Emotion.init(emotion:))

        switch useCase.mode {
        case .create: break
        case .edit: emotions += [EventNamePresenterObjects.Emotion("Изменить", UIColor.secondarySystemBackground)]
        }

        output.show(selectedEmotions: emotions)
        output.show(color: UIColor(hex: color))
    }

    public func presentCancel() {
        router.routeCancel()
    }

    public func presentEdit(emotions: [String]) {
        router.routeEdit(emotions: emotions)
    }
}
