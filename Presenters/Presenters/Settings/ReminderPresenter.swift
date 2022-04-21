import Foundation
import UseCases

fileprivate extension TimeInterval {
    var time: String { String(format: "%02d:%02d", Int(self) / 3600, (Int(self) % 3600) / 60) }
    var mins: String { "\(Int(self / 60))" }
}

public protocol ReminderPresenterOutput: AnyObject {
    func show(range: String)
    func show(interval: String)
}

public protocol ReminderRouter: AnyObject {
    func routeCancel()
}

public protocol ReminderPresenter {
    var title: String { get }
    var cancel: String { get }
    var add: String { get }

    var rangeInfo: String { get }
    var intervalInfo: String { get }

    var rangeLimit: (String, String) { get }
    var intervalLimit: (String, String) { get }

    var range: (Double, Double) { get }
    var interval: (Double, Double) { get }

    func event(range: (Double, Double))
    func event(interval: (Double, Double))

    func eventCancel()
    func eventCreate()
}

public final class ReminderPresenterImpl {

    // MARK: - Public

    public weak var output: ReminderPresenterOutput!
    public var useCase: ReminderUseCase!
    public weak var router: ReminderRouter!

    public init() {}
}

extension ReminderPresenterImpl: ReminderPresenter {
    public var title: String { "Новое правило" }
    public var cancel: String { "Отмена" }
    public var add: String { "Добавить" }

    public var rangeInfo: String { "Время суток, в которое отправлять уведомления" }
    public var intervalInfo: String { "Интервал между уведомлениями. Например, \"30 - 50 мин.\" означает, что между уведомлениями будет проходить случайный промежуток времени от 30 до 50 минут" }

    public var rangeLimit: (String, String) { (useCase.rangeLimit.0.time, useCase.rangeLimit.1.time) }
    public var intervalLimit: (String, String) { (useCase.intervalLimit.0.mins, useCase.intervalLimit.1.mins) }

    public var range: (Double, Double) { useCase.rangeValue }
    public var interval: (Double, Double) { useCase.intervalValue }

    public func event(range: (Double, Double)) {
        useCase.event(range: range)
    }

    public func event(interval: (Double, Double)) {
        useCase.event(interval: interval)
    }

    public func eventCancel() {
        router.routeCancel()
    }

    public func eventCreate() {
        useCase.eventCreate()
        router.routeCancel()
    }
}

extension ReminderPresenterImpl: ReminderUseCaseOuput {
    public func present(range: (TimeInterval, TimeInterval)) {
        output.show(range: "Напоминать c \(range.0.time) по \(range.1.time)")
    }

    public func present(interval: (TimeInterval, TimeInterval)) {
        output.show(interval: "Каждые \(interval.0.mins) - \(interval.1.mins) мин.")
    }
}
