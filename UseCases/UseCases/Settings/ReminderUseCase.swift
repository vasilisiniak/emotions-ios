import Foundation
import Model

fileprivate enum Constants {
    static let MinInterval: TimeInterval = 5 * 60
    static let MaxInterval: TimeInterval = 999 * 60
    static let LogNorm = 0.9
}

fileprivate extension Double {
    var time: TimeInterval { self * 24 * 3600 }
    var interval: TimeInterval { max(Constants.MinInterval, pow(Constants.MaxInterval, (self + Constants.LogNorm) / (1 + Constants.LogNorm))) }
}

fileprivate extension TimeInterval {
    var normLog: Double { log(self) / log(Constants.MaxInterval) * (1 + Constants.LogNorm) - Constants.LogNorm }
}

public protocol ReminderUseCaseOuput: AnyObject {
    func present(range: (TimeInterval, TimeInterval))
    func present(interval: (TimeInterval, TimeInterval))
}

public protocol ReminderUseCase {
    var rangeLimit: (TimeInterval, TimeInterval) { get }
    var intervalLimit: (TimeInterval, TimeInterval) { get }
    var rangeValue: (Double, Double) { get }
    var intervalValue: (Double, Double) { get }

    func event(range: (Double, Double))
    func event(interval: (Double, Double))
    func eventCreate()
}

public final class ReminderUseCaseImpl {

    // MARK: - Private

    private var range: (TimeInterval, TimeInterval) = (8 * 3600, 20 * 3600)
    private var interval: (TimeInterval, TimeInterval) = (30 * 60, 150 * 60)

    private let reminders: RemindersManager

    // MARK: - Public

    public weak var output: ReminderUseCaseOuput!

    public init(reminders: RemindersManager) {
        self.reminders = reminders
    }
}

extension ReminderUseCaseImpl: ReminderUseCase {
    public var rangeLimit: (TimeInterval, TimeInterval) { (0, 24 * 3600) }
    public var intervalLimit: (TimeInterval, TimeInterval) { (Constants.MinInterval, Constants.MaxInterval) }

    public var rangeValue: (Double, Double) { (range.0 / 24 / 3600, range.1 / 24 / 3600) }
    public var intervalValue: (Double, Double) { (interval.0.normLog, interval.1.normLog) }

    public func event(range: (Double, Double)) {
        self.range = (range.0.time, range.1.time)
        output.present(range: self.range)
    }

    public func event(interval: (Double, Double)) {
        self.interval = (interval.0.interval, interval.1.interval)
        output.present(interval: self.interval)
    }

    public func eventCreate() {
        reminders.add(Reminder(begin: range.0, end: range.1, deltaMin: interval.0, deltaMax: interval.1))
    }
}
