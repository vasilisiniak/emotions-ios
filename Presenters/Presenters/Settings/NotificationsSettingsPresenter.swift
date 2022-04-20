import UseCases
import UIKit

public protocol NotificationsSettingsPresenterOutput: AnyObject {
    func show(enabled: Bool)
    func show(denied: String, ok: String, settings: String)
}

public protocol NotificationsSettingsPresenter {
    var title: String { get }
    var notificationsTitle: String { get }
    var notificationsInfo: String { get }

    func eventViewReady()
    func event(enabled: Bool)
    func eventSettings()
}

public final class NotificationsSettingsPresenterImpl {

    // MARK: - Public

    public weak var output: NotificationsSettingsPresenterOutput!
    public var useCase: NotificationsSettingsUseCase!

    public init() {}
}

extension NotificationsSettingsPresenterImpl: NotificationsSettingsPresenter {
    public var title: String { "Уведомления" }
    public var notificationsTitle: String { "Уведомления" }
    public var notificationsInfo: String { "Напоминать в заданное время сделать запись в дневник. Настройка времени доступна, если включить уведомления" }

    public func eventViewReady() {
        useCase.eventOutputReady()
    }

    public func event(enabled: Bool) {
        useCase.event(enabled: enabled)
    }

    public func eventSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}

extension NotificationsSettingsPresenterImpl: NotificationsSettingsUseCaseOutput {
    public func present(enabled: Bool) {
        output.show(enabled: enabled)
    }

    public func presentDenied() {
        output.show(denied: "Чтобы включить напоминания, нужно разрешить приложению отправку уведомлений в настройках устройства", ok: "OK", settings: "Настройки")
    }
}
