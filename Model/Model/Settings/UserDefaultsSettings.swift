import Foundation
import UIKit
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
        static let AppearanceKey = "Model.SettingsImpl.AppearanceKey"
        static let EraseImmediatelyKey = "Model.SettingsImpl.EraseImmediatelyKey"
        static let RemindersKey = "Model.SettingsImpl.RemindersKey"
        static let NotificationsKey = "Model.SettingsImpl.NotificationsKey"
        static let ShowPercentageKey = "Model.SettingsImpl.ShowPercentageKey"
    }

    // MARK: - Private

    private let defaults: UserDefaults
    private var observers: [UUID: Observer] = [:]

    private func notify() {
        observers.values.forEach { $0(self) }
    }

    private func set<T>(_ value: T?, key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
        notify()
    }

    private func get(_ key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    private func get(_ key: String) -> Data {
        defaults.data(forKey: key) ?? Data()
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
        get { get(Constants.ProtectSensitiveDataKey) }
        set { set(newValue, key: Constants.ProtectSensitiveDataKey) }
    }

    public var useFaceId: Bool {
        get { get(Constants.UseFaceIdKey) }
        set { set(newValue, key: Constants.UseFaceIdKey) }
    }

    public var useLegacyLayout: Bool {
        get { get(Constants.UseLegacyLayoutKey) }
        set { set(newValue, key: Constants.UseLegacyLayoutKey) }
    }

    public var useExpandedDiary: Bool {
        get { get(Constants.UseExtendedDiaryKey) }
        set { set(newValue, key: Constants.UseExtendedDiaryKey) }
    }

    public var reduceAnimation: Bool {
        get { get(Constants.ReduceAnimationKey) }
        set { set(newValue, key: Constants.ReduceAnimationKey) }
    }

    public var useLegacyDiary: Bool {
        get { get(Constants.UseLegacyDiaryKey) }
        set { set(newValue, key: Constants.UseLegacyDiaryKey) }
    }

    public var appearance: UIUserInterfaceStyle {
        get { UIUserInterfaceStyle(rawValue: defaults.integer(forKey: Constants.AppearanceKey)) ?? .unspecified }
        set { set(newValue.rawValue, key: Constants.AppearanceKey) }
    }

    public var eraseImmediately: Bool {
        get { get(Constants.EraseImmediatelyKey) }
        set { set(newValue, key: Constants.EraseImmediatelyKey) }
    }

    public var reminders: Data {
        get { get(Constants.RemindersKey) }
        set { set(newValue, key: Constants.RemindersKey) }
    }

    public var notifications: Bool {
        get { get(Constants.NotificationsKey) }
        set { set(newValue, key: Constants.NotificationsKey) }
    }

    public var showPercentage: Bool {
        get { get(Constants.ShowPercentageKey) }
        set { set(newValue, key: Constants.ShowPercentageKey) }
    }

    public func add(observer: @escaping Observer) -> AnyObject {
        let token = Token { [weak self] in self?.observers[$0] = nil }
        observers[token.id] = observer
        return token
    }
}
