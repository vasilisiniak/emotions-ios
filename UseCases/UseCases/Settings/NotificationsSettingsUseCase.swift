import Foundation
import Model

public protocol NotificationsSettingsUseCaseOutput: AnyObject {
    func present(enabled: Bool)
    func presentDenied()
}

public protocol NotificationsSettingsUseCase {
    func eventOutputReady()
    func event(enabled: Bool)
}

public final class NotificationsSettingsUseCaseImpl {

    // MARK: - Private

    private let notifications: NotificationsManager
    private let reminders: RemindersManager
    private let settings: Settings
    private var observer: AnyObject?

    private func presentEnabled() {
        let available = notifications.enabled
        let enabled = settings.reminders
        output.present(enabled: available && enabled)
    }

    private func handleDenied() {
        settings.reminders = false
        presentEnabled()
        output.presentDenied()
    }

    // MARK: - Public

    public weak var output: NotificationsSettingsUseCaseOutput!

    public init(notifications: NotificationsManager, reminders: RemindersManager, settings: Settings) {
        self.notifications = notifications
        self.reminders = reminders
        self.settings = settings

        observer = self.notifications.add { [weak self] _, event in
            DispatchQueue.main.async {
                switch event {
                case .update: self?.presentEnabled()
                case .denied: self?.handleDenied()
                }
            }
        }
    }
}

extension NotificationsSettingsUseCaseImpl: NotificationsSettingsUseCase {
    public func eventOutputReady() {
        presentEnabled()
    }

    public func event(enabled: Bool) {
        notifications.enabled = enabled
        settings.reminders = enabled
    }
}
