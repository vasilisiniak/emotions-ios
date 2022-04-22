import UseCases
import UIKit

fileprivate extension TimeInterval {
    var time: String { String(format: "%02d:%02d", Int(self) / 3600, (Int(self) % 3600) / 60) }
    var mins: String { "\(Int(self / 60))" }
}

fileprivate extension NotificationsSettingsUseCaseObjects.Reminder {
    var name: (String, String) { ("С \(begin.time) по \(end.time)", "Каждые \(deltaMin.mins) - \(deltaMax.mins) мин.") }
}

public protocol NotificationsSettingsPresenterOutput: AnyObject {
    func show(enabled: Bool)
    func show(denied: String, ok: String, settings: String)
    func show(info: String, ok: String)
    func show(info: Bool)
}

public protocol NotificationsSettingsPresenter {
    var title: String { get }
    var add: String { get }
    var rules: String { get }

    var notificationsTitle: String { get }
    var notificationsInfo: String { get }

    var reminders: [(String, String)] { get }

    func eventViewReady()
    func event(enabled: Bool)
    func eventSettings()
    func eventAdd()
    func event(delete: Int)
    func eventInfo()
}

public protocol NotificationsSettingsRouter: AnyObject {
    func routeAddReminder()
}

public final class NotificationsSettingsPresenterImpl {

    // MARK: - Public

    public weak var output: NotificationsSettingsPresenterOutput!
    public var useCase: NotificationsSettingsUseCase!
    public weak var router: NotificationsSettingsRouter!

    public init() {}
}

extension NotificationsSettingsPresenterImpl: NotificationsSettingsPresenter {
    public var title: String { "Уведомления" }
    public var add: String { "Добавить правило" }
    public var rules: String { "Правила "}

    public var notificationsTitle: String { "Уведомления" }
    public var notificationsInfo: String { "Напоминать случайным образом по заданным правилам (время суток, интервал между уведомлениями) сделать запись в дневник. Настройка правил доступна ниже при включении уведомлений" }

    public var reminders: [(String, String)] { useCase.reminders.map(\.name) }

    public func eventViewReady() {
        useCase.eventOutputReady()
    }

    public func event(enabled: Bool) {
        useCase.event(enabled: enabled)
    }

    public func eventSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }

    public func eventAdd() {
        router.routeAddReminder()
    }

    public func event(delete: Int) {
        useCase.event(delete: delete)
    }

    public func eventInfo() {
        output.show(info: "Свайпните правило, чтобы удалить", ok: "OK")
    }
}

extension NotificationsSettingsPresenterImpl: NotificationsSettingsUseCaseOutput {
    public func present(enabled: Bool) {
        output.show(enabled: enabled)
        output.show(info: enabled)
    }

    public func presentDenied() {
        output.show(denied: "Чтобы включить напоминания, нужно разрешить приложению отправку уведомлений в настройках устройства", ok: "OK", settings: "Настройки")
    }

    public func presentAddReminder() {
        router.routeAddReminder()
    }

    public func presentInfo() {
        eventInfo()
    }
}
