import UIKit
import UserNotifications
import Utils

public final class LocalNotificationsManager {

    // MARK: - Private

    private var observers: [UUID: NotificationsManagerHandler] = [:]

    private var authorized = false {
        didSet { notify(.update) }
    }

    private func notify(_ event: NotificationsManagerEvent) {
        observers.forEach { $0.value(self, event) }
    }

    private func check() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.authorized = (settings.authorizationStatus == .authorized)
        }
    }

    private func authorize() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] success, error in
            if let error = error {
                print("Error while requesting notifications permissions: \(error)")
            }
            if !success {
                self?.notify(.denied)
            }
            self?.authorized = success
        }
    }

    // MARK: - Public

    public init() {
        check()
    }
}

extension LocalNotificationsManager: NotificationsManager {
    public var enabled: Bool {
        get { authorized }
        set {
            guard newValue else { return }
            authorize()
        }
    }

    public func add(observer: @escaping NotificationsManagerHandler) -> AnyObject {
        let token = Token { [weak self] in self?.observers[$0] = nil }
        observers[token.id] = observer
        return token
    }

    public func schedule(_ notification: Notification) {
        let content = UNMutableNotificationContent()
        content.title = notification.text
        content.badge = 1
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: notification.trigger, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error while add notification requst \(request): \(error)")
            }
        }
    }

    public func cancelDelivered() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    public func cancelScheduled() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
