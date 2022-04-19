import Foundation

public protocol RemindersManager {
    var reminders: [Reminder] { get }
    func add(_ reminder: Reminder)
    func delete(_ reminder: Reminder)
}

public struct Reminder: Equatable {

    // MARK: - Public

    public let begin: TimeInterval
    public let end: TimeInterval
    public let deltaMin: TimeInterval
    public let deltaMax: TimeInterval

    public init(begin: TimeInterval, end: TimeInterval, deltaMin: TimeInterval, deltaMax: TimeInterval) {
        self.begin = begin
        self.end = end
        self.deltaMin = deltaMin
        self.deltaMax = deltaMax
    }
}

fileprivate extension Reminder {
    private func next(of time: TimeInterval) -> TimeInterval {
        TimeInterval.random(in: (time + deltaMin)...(time + deltaMax))
    }

    private var first: TimeInterval {
        next(of: begin)
    }

    var times: [TimeInterval] {
        var times = [first]
        while let last = times.last, last < end {
            times.append(next(of: last))
        }
        if times.count > 1 {
            times.removeLast()
        }
        return times
    }
}

public final class RemindersManagerImpl {

    private struct NotificationObject: Notification {
        let text: String
        let trigger: DateComponents

        init(text: String, time: TimeInterval) {
            let seconds = Int(time)
            var trigger = DateComponents()

            trigger.calendar = Calendar.current
            trigger.hour = seconds / 3600
            trigger.minute = (seconds % 3600) / 60
            trigger.second = seconds % 60

            self.text = text
            self.trigger = trigger
        }
    }

    // MARK: - Private

    private let message: String
    private let manager: NotificationsManager

    private func scheduleNotifications() {
        manager.cancelScheduled()
        reminders
            .flatMap { $0.times }
            .map { NotificationObject(text: message, time: $0) }
            .forEach(manager.schedule)
    }

    // MARK: - Public

    public private(set) var reminders = [Reminder]()

    public init(message: String, manager: NotificationsManager) {
        self.message = message
        self.manager = manager
    }
}

extension RemindersManagerImpl: RemindersManager {
    public func add(_ reminder: Reminder) {
        reminders.append(reminder)
        scheduleNotifications()
    }

    public func delete(_ reminder: Reminder) {
        let index = reminders.firstIndex(of: reminder)!
        reminders.remove(at: index)
    }
}
