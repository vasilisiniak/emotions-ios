import Foundation
import Utils

public protocol Settings: AnyObject {
    typealias Observer = (Settings) -> Void
    func add(observer: @escaping Observer) -> AnyObject

    var range: (min: Date?, max: Date?) { get set }
    var protectSensitiveData: Bool { get set }
    var useFaceId: Bool { get set }
    var useLegacyLayout: Bool { get set }
    var useExpandedDiary: Bool { get set }
}

public final class SettingsImpl {

    private enum Constants {
        fileprivate static let RangeMinKey = "Model.SettingsImpl.RangeMinKey"
        fileprivate static let RangeMaxKey = "Model.SettingsImpl.RangeMaxKey"
        fileprivate static let ProtectSensitiveDataKey = "Model.SettingsImpl.ProtectSensitiveDataKey"
        fileprivate static let UseFaceIdKey = "Model.SettingsImpl.UseFaceIdKey"
        fileprivate static let UseLegacyLayoutKey = "Model.SettingsImpl.UseLegacyLayoutKey"
        fileprivate static let UseExtendedDiaryKey = "Model.SettingsImpl.UseExtendedDiaryKey"
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

    public var useFaceId: Bool {
        get {
            defaults.bool(forKey: Constants.UseFaceIdKey)
        }
        set {
            defaults.set(newValue, forKey: Constants.UseFaceIdKey)
            defaults.synchronize()

            notify()
        }
    }

    public var useLegacyLayout: Bool {
        get {
            defaults.bool(forKey: Constants.UseLegacyLayoutKey)
        }
        set {
            defaults.set(newValue, forKey: Constants.UseLegacyLayoutKey)
            defaults.synchronize()

            notify()
        }
    }

    public var useExpandedDiary: Bool {
        get {
            defaults.bool(forKey: Constants.UseExtendedDiaryKey)
        }
        set {
            defaults.set(newValue, forKey: Constants.UseExtendedDiaryKey)
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
