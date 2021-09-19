import UIKit
import StoreKit
import UseCases
import Utils

public protocol LogEventPresenterOutput: AnyObject {
    func showEmotions()
    func show(message: String, button: String)
    func showWidgetAlert(message: String, okButton: String, infoButton: String)
    func showShareAlert(message: String, okButton: String, cancelButton: String)
    func show(share: UIActivityItemSource)
}

public protocol LogEventPresenter {
    func eventViewReady()
    func eventEventCreated()
    func eventWidgetInfo()
    func eventShare()
    func eventCancelShare()
}

public final class LogEventPresenterImpl {

    // MARK: - Public

    public weak var output: LogEventPresenterOutput!
    public var useCase: LogEventUseCase!

    public init() {}
}

extension LogEventPresenterImpl: LogEventPresenter {
    public func eventCancelShare() {
        useCase.eventCancelShare()
    }

    public func eventShare() {
        useCase.eventShare()
    }

    public func eventEventCreated() {
        useCase.eventEventCreated()
    }

    public func eventViewReady() {
        useCase.eventOutputReady()
    }

    public func eventWidgetInfo() {
        useCase.eventWidgetInfo()
    }
}

extension LogEventPresenterImpl: LogEventUseCaseOutput {
    public func presentShareInfo() {
        output.showShareAlert(message: "Может быть это приложение будет полезно кому-то из ваших друзей?", okButton: "Поделиться приложением", cancelButton: "Не сейчас")
    }

    public func presentShareLater() {
        output.show(message: "Вы можете поделиться приложением позже на вкладке «О приложении»", button: "OK")
    }

    public func presentRate() {
        SKStoreReviewController.requestReview(in: UIApplication.shared.scene)
    }

    public func presentShare(item: UIActivityItemSource) {
        output.show(share: item)
    }

    public func presentDairyInfo() {
        output.show(message: "Запись сделана. Её можно увидеть на вкладке дневника", button: "OK")
    }

    public func presentColorMapInfo() {
        output.show(message: "Теперь доступна цветовая карта эмоций. Её можно увидеть на соответствующей вкладке", button: "OK")
    }

    public func presentWidgetInfo() {
        output.showWidgetAlert(message: "Можно добавить виджет с цветовой картой эмоций на экран «Домой»", okButton: "OK", infoButton: "Как это сделать")
    }

    public func presentWidgetHelp(link: String) {
        UIApplication.shared.open(URL(string: link)!)
    }

    public func presentEmotions() {
        output.showEmotions()
    }
}
