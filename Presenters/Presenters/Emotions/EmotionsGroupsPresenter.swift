import UIKit
import StoreKit
import UseCases
import Utils

public enum EmotionsGroupsPresenterObjects {

    public struct Emotion: Equatable {

        // MARK: - Fileprivate

        fileprivate init(event: EmotionsGroupsUseCaseObjects.Emotion) {
            name = event.name
            meaning = event.meaning
            color = event.color
        }

        // MARK: - Public

        public let name: String
        public let meaning: String
        public let color: String
    }
}

public protocol EmotionsGroupsPresenterOutput: AnyObject {
    func show(title: String)
    func show(clearButton: String)
    func show(nextButton: String)
    func show(clearButtonEnabled: Bool)
    func show(nextButtonEnabled: Bool)
    func show(groupNames: [String])
    func show(selectedGroupIndex: Int)
    func show(notFound: String)
    func show(emotions: [EmotionsGroupsPresenterObjects.Emotion], selectedNames: [String], color: UIColor, label: Bool)
    func show(selectedEmotionsNames: String, color: UIColor)
    func show(message: String, button: String)
    func show(shareAlertMessage: String, okButton: String, cancelButton: String)
    func show(share: UIActivityItemSource)
    func show(legacy: Bool)
}

public protocol EmotionsGroupsRouter: AnyObject {
    func routeEventName(selectedEmotions: [String], color: String)
    func routeNotFound()
    func routeCancel()
}

public protocol EmotionsGroupsPresenter {
    func eventViewReady()
    func eventSwipeLeft()
    func eventSwipeRight()
    func eventClear()
    func eventNext()
    func event(indexChange: Int)
    func event(select: String)
    func event(search: String?)
    func eventWillShowInfo(emotion: String)
    func eventDidHideInfo()
    func eventShare()
    func eventCancelShare()
    func eventNotFound()
    var cancelSearchButton: String { get }
}

public final class EmotionsGroupsPresenterImpl {

    // MARK: - Public

    public weak var output: EmotionsGroupsPresenterOutput!
    public weak var router: EmotionsGroupsRouter!
    public var useCase: EmotionsGroupsUseCase!

    public init() {}
}

extension EmotionsGroupsPresenterImpl: EmotionsGroupsPresenter {
    public var cancelSearchButton: String {
        "Готово"
    }

    public func eventShare() {
        useCase.eventShare()
    }

    public func eventCancelShare() {
        useCase.eventCancelShare()
    }

    public func eventWillShowInfo(emotion: String) {
        useCase.eventWillShowInfo(emotion: emotion)
    }

    public func eventDidHideInfo() {
        useCase.eventDidHideInfo()
    }

    public func eventNext() {
        useCase.eventNext()
    }

    public func eventClear() {
        useCase.eventClear()
    }

    public func eventViewReady() {
        output.show(title: "Выберите эмоции")

        switch useCase.mode {
        case .log:
            output.show(clearButton: "Очистить")
            output.show(nextButton: "Записать")
            output.show(notFound: "Моей эмоции нет в списке")
        case .edit:
            output.show(clearButton: "Отмена")
            output.show(nextButton: "Сохранить")
        }

        useCase.eventOutputReady()
    }

    public func event(indexChange: Int) {
        useCase.event(indexChange: indexChange)
    }

    public func event(select: String) {
        useCase.event(select: select)
    }

    public func eventSwipeLeft() {
        useCase.eventNextIndex()
    }

    public func eventSwipeRight() {
        useCase.eventPrevIndex()
    }

    public func eventNotFound() {
        useCase.eventNotFound()
    }

    public func event(search: String?) {
        useCase.event(search: search)
    }
}

extension EmotionsGroupsPresenterImpl: EmotionsGroupsUseCaseOutput {
    public func presentShareInfo() {
        output.show(shareAlertMessage: "Может быть это приложение будет полезно кому-то из ваших друзей?", okButton: "Поделиться приложением", cancelButton: "Не сейчас")
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

    public func presentFirstLaunch() {
        output.show(message: "Задержите палец на эмоции, чтобы увидеть её описание", button: "OK")
    }

    public func presentSecondLaunch() {
        output.show(message: "Вкладки можно преключать свайпом влево или вправо", button: "OK")
    }

    public func present(clearAvailable: Bool) {
        output.show(clearButtonEnabled: clearAvailable)
    }

    public func present(nextAvailable: Bool) {
        output.show(nextButtonEnabled: nextAvailable)
    }

    public func presentNext(selectedEmotions: [String], color: String) {
        router.routeEventName(selectedEmotions: selectedEmotions, color: color)
    }

    public func present(groups: [String]) {
        output.show(groupNames: groups)
    }

    public func present(emotions: [EmotionsGroupsUseCaseObjects.Emotion], selected: [String], color: String, label: Bool) {
        let emotions = emotions.map(EmotionsGroupsPresenterObjects.Emotion.init)
        output.show(emotions: emotions, selectedNames: selected, color: UIColor(hex: color), label: label)
    }

    public func present(selectedEmotions: [String], color: String) {
        output.show(selectedEmotionsNames: selectedEmotions.joined(separator: ", "), color: UIColor(hex: color))
    }

    public func present(selectedGroupIndex: Int) {
        output.show(selectedGroupIndex: selectedGroupIndex)
    }

    public func presentNotFound() {
        router.routeNotFound()
    }

    public func present(legacy: Bool) {
        output.show(legacy: legacy)
    }

    public func presentCancel() {
        router.routeCancel()
    }
}
