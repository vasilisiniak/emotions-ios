import Foundation
import Utils

public protocol RemindersManager: AnyObject {
    var enabled: Bool { get set }
    var reminders: [Reminder] { get }

    func add(_ reminder: Reminder)
    func delete(_ reminder: Reminder)
    func add(observer: @escaping (RemindersManager) -> ()) -> AnyObject
}

public struct Reminder: Equatable, Codable {

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
        TimeInterval.random(in: begin...min(end, begin + deltaMax))
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

fileprivate extension Array {
    func limited(to size: Int) -> Self {
        var res = self
        while res.count > size, let i = res.indices.randomElement() {
            res.remove(at: i)
        }
        return res
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
    private let settings: Settings
    private var observers: [UUID: (RemindersManager) -> ()] = [:]
    private var token: AnyObject?

    private func scheduleNotifications() {
        manager.cancelScheduled()
        guard enabled else { return }
        reminders
            .limited(to: 64)
            .flatMap { $0.times }
            .map { NotificationObject(text: message, time: $0) }
            .forEach(manager.schedule)
    }

    // MARK: - Public

    public init(message: String, manager: NotificationsManager, settings: Settings) {
        self.message = message
        self.manager = manager
        self.settings = settings

        token = self.manager.add { [weak self] _, event in
            guard event == .update else { return }
            self?.scheduleNotifications()
        }
    }
}

extension RemindersManagerImpl: RemindersManager {
    public var enabled: Bool {
        get { settings.notifications }
        set {
            settings.notifications = newValue
            scheduleNotifications()
        }
    }

    private(set) public var reminders: [Reminder] {
        get { (try? JSONDecoder().decode([Reminder].self, from: settings.reminders)) ?? [] }
        set { settings.reminders = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    public func add(_ reminder: Reminder) {
        reminders.append(reminder)
        scheduleNotifications()
        observers.values.forEach { $0(self) }
    }

    public func delete(_ reminder: Reminder) {
        let index = reminders.firstIndex(of: reminder)!
        reminders.remove(at: index)
        scheduleNotifications()
        observers.values.forEach { $0(self) }
    }

    public func add(observer: @escaping (RemindersManager) -> ()) -> AnyObject {
        let token = Token { [weak self] in self?.observers[$0] = nil }
        observers[token.id] = observer
        return token
    }
}
