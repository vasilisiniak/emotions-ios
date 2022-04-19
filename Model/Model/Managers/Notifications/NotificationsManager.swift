import Foundation

public protocol Notification {
    var trigger: DateComponents { get }
    var text: String { get }
}

public enum NotificationsManagerEvent {
    case update
    case denied
}

public typealias NotificationsManagerHandler = (NotificationsManager, NotificationsManagerEvent) -> ()

public protocol NotificationsManager {
    var enabled: Bool { get set }
    func add(observer: @escaping NotificationsManagerHandler) -> AnyObject
    func cancelDelivered()
    func cancelScheduled()
    func schedule(_ notification: Notification)
}
