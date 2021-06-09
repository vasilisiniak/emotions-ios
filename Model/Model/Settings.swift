import Foundation

public protocol Settings: AnyObject {
    var range: (min: Date?, max: Date?) { get set }
}

public final class SettingsImpl {

    private enum Constants {
        fileprivate static let RangeMinKey = "Model.SettingsImpl.RangeMinKey"
        fileprivate static let RangeMaxKey = "Model.SettingsImpl.RangeMaxKey"
    }

    // MARK: - Private

    private let defaults: UserDefaults

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
        }
    }
}
