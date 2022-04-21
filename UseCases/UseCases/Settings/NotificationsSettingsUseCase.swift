import Foundation
import Model

public enum NotificationsSettingsUseCaseObjects {

    public struct Reminder {

        // MARK: - Internal

        init(reminder: Model.Reminder) {
            begin = reminder.begin
            end = reminder.end
            deltaMin = reminder.deltaMin
            deltaMax = reminder.deltaMax
        }

        // MARK: - Public

        public let begin: TimeInterval
        public let end: TimeInterval
        public let deltaMin: TimeInterval
        public let deltaMax: TimeInterval
    }
}

public protocol NotificationsSettingsUseCaseOutput: AnyObject {
    func present(enabled: Bool)
    func presentDenied()
    func presentAddReminder()
}

public protocol NotificationsSettingsUseCase {
    var reminders: [NotificationsSettingsUseCaseObjects.Reminder] { get }
    func eventOutputReady()
    func event(enabled: Bool)
    func event(delete: Int)
}

public final class NotificationsSettingsUseCaseImpl {

    // MARK: - Private

    private let notifications: NotificationsManager
    private let remindersManager: RemindersManager
    private var observers: [AnyObject]?

    private func presentEnabled() {
        let available = notifications.enabled
        let hasAny = !remindersManager.reminders.isEmpty
        output.present(enabled: available && hasAny)
    }

    private func handleDenied() {
        presentEnabled()
        output.presentDenied()
    }

    // MARK: - Public

    public weak var output: NotificationsSettingsUseCaseOutput!

    public init(notifications: NotificationsManager, reminders: RemindersManager) {
        self.notifications = notifications
        self.remindersManager = reminders

        observers = [
            self.notifications.add { [weak self] _, event in
                DispatchQueue.main.async {
                    switch event {
                    case .update: self?.presentEnabled()
                    case .denied: self?.handleDenied()
                    }
                }
            },
            self.remindersManager.add { [weak self] _ in self?.presentEnabled() }
        ]
    }
}

extension NotificationsSettingsUseCaseImpl: NotificationsSettingsUseCase {
    public var reminders: [NotificationsSettingsUseCaseObjects.Reminder] {
        remindersManager.reminders.map(NotificationsSettingsUseCaseObjects.Reminder.init(reminder:))
    }

    public func eventOutputReady() {
        presentEnabled()
    }

    public func event(enabled: Bool) {
        notifications.enabled = enabled

        guard enabled else { return }
        var observer: AnyObject?

        observer = notifications.add { [weak self] _, event in
            defer { withExtendedLifetime(observer) { observer = nil } }

            guard event == .update else { return }
            guard self?.notifications.enabled == true else { return }

            DispatchQueue.main.async { self?.output.presentAddReminder() }
        }
    }

    public func event(delete: Int) {
        remindersManager.delete(remindersManager.reminders[delete])
    }
}
