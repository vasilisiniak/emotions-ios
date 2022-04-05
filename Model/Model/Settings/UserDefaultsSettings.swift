import Foundation
import Utils

public final class UserDefaultsSettings {

    private enum Constants {
        static let RangeMinKey = "Model.SettingsImpl.RangeMinKey"
        static let RangeMaxKey = "Model.SettingsImpl.RangeMaxKey"
        static let ProtectSensitiveDataKey = "Model.SettingsImpl.ProtectSensitiveDataKey"
        static let UseFaceIdKey = "Model.SettingsImpl.UseFaceIdKey"
        static let UseLegacyLayoutKey = "Model.SettingsImpl.UseLegacyLayoutKey"
        static let UseExtendedDiaryKey = "Model.SettingsImpl.UseExtendedDiaryKey"
        static let ReduceAnimationKey = "Model.SettingsImpl.ReduceAnimationKey"
        static let UseLegacyDiaryKey = "Model.SettingsImpl.UseLegacyDiaryKey"
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

extension UserDefaultsSettings: Settings {
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

    public var reduceAnimation: Bool {
        get {
            defaults.bool(forKey: Constants.ReduceAnimationKey)
        }
        set {
            defaults.set(newValue, forKey: Constants.ReduceAnimationKey)
            defaults.synchronize()

            notify()
        }
    }

    public var useLegacyDiary: Bool {
        get {
            defaults.bool(forKey: Constants.UseLegacyDiaryKey)
        }
        set {
            defaults.set(newValue, forKey: Constants.UseLegacyDiaryKey)
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
