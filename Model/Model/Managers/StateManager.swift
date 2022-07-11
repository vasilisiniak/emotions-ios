import Foundation

public protocol StateManager: AnyObject {
    var emotionsGroupsState: (emotions: [String], color: String)? { get set }
    var emotionNameState: (name: String?, details: String?, date: Date?)? { get set }
}

public final class UserDefaultsStateManager {

    private enum Constants {
        static let EmotionsGroupsEmotionsKey = "Model.UserDefaultsStateManager.EmotionsGroupsEmotionsKey"
        static let EmotionsGroupsColorKey = "Model.UserDefaultsStateManager.EmotionsGroupsColorKey"
        static let EmotionNameNameKey = "Model.UserDefaultsStateManager.EmotionNameNameKey"
        static let EmotionNameDetailsKey = "Model.UserDefaultsStateManager.EmotionNameDetailsKey"
        static let EmotionNameDateKey = "Model.UserDefaultsStateManager.EmotionNameDateKey"
    }

    // MARK: - Private

    private let defaults: UserDefaults

    private func set<T>(_ value: T?, key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    private func get<T>(_ key: String) -> T? {
        defaults.object(forKey: key) as? T
    }

    // MARK: - Public

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }
}

extension UserDefaultsStateManager: StateManager {

    public var emotionsGroupsState: (emotions: [String], color: String)? {
        get {
            guard
                let emotions: [String] = get(Constants.EmotionsGroupsEmotionsKey),
                let color: String = get(Constants.EmotionsGroupsColorKey)
            else { return nil }
            return (emotions: emotions, color: color)
        }
        set {
            set(newValue?.emotions, key: Constants.EmotionsGroupsEmotionsKey)
            set(newValue?.color, key: Constants.EmotionsGroupsColorKey)
        }
    }

    public var emotionNameState: (name: String?, details: String?, date: Date?)? {
        get {
            (
                name: get(Constants.EmotionNameNameKey),
                details: get(Constants.EmotionNameDetailsKey),
                date: get(Constants.EmotionNameDateKey)
            )
        }
        set {
            set(newValue?.name, key: Constants.EmotionNameNameKey)
            set(newValue?.details, key: Constants.EmotionNameDetailsKey)
            set(newValue?.date, key: Constants.EmotionNameDateKey)
        }
    }
}
