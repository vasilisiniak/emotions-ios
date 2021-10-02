import Foundation
import Utils

public protocol Settings: AnyObject {
    typealias Observer = (Settings) -> Void
    func add(observer: @escaping Observer) -> AnyObject

    var range: (min: Date?, max: Date?) { get set }
    var protectSensitiveData: Bool { get set }
}

public final class SettingsImpl {

    private enum Constants {
        fileprivate static let RangeMinKey = "Model.SettingsImpl.RangeMinKey"
        fileprivate static let RangeMaxKey = "Model.SettingsImpl.RangeMaxKey"
        fileprivate static let ProtectSensitiveDataKey = "Model.SettingsImpl.ProtectSensitiveDataKey"
    }

    // MARK: - Private

    private let defaults: UserDefaults
    private var observers: [UUID: Observer] = [:]

    private func notify() {
        observers.values.forEach { $0(self) }
    }

    // MARK: - Public

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }
}

extension SettingsImpl: Settings {
    public var range: (min: Date?, max: Date?) {
        get {
            return (
                min: defaults.object(forKey: Constants.RangeMinKey) as? Date,
                max: defaults.object(forKey: Constants.RangeMaxKey) as? Date
            )
        }
        set {
            defaults.setValue(newValue.min, forKey: Constants.RangeMinKey)
            defaults.setValue(newValue.max, forKey: Constants.RangeMaxKey)
            defaults.synchronize()

            notify()
        }
    }

    public var protectSensitiveData: Bool {
        get {
            defaults.bool(forKey: Constants.ProtectSensitiveDataKey)
        }
        set {
            defaults.set(newValue, forKey: Constants.ProtectSensitiveDataKey)
            defaults.synchronize()

            notify()
        }
    }

    public func add(observer: @escaping Observer) -> AnyObject {
        let token = Token { [weak self] in self?.observers[$0] = nil }
        observers[token.id] = observer
        return token
    }
}
