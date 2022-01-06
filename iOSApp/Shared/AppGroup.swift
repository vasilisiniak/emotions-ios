import Foundation
import Model
import Storage

enum AppGroup {
    static let emotionEventsProvider: EmotionEventsProvider = {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.by.vasili.siniak.emotions")!
        let storeURL = containerURL.appendingPathComponent("emotions.sqlite")
        let storage = CoreDataStorage(model: "Model", url: storeURL)
        return EmotionEventsProviderImpl<EmotionEventEntity>(storage: storage)
    }()

    static let settings: Settings = {
        let defaults = UserDefaults(suiteName: "group.by.vasili.siniak.emotions")!
        return SettingsImpl(defaults: defaults)
    }()

    static let appLink = "https://apps.apple.com/app/id1558896129"
    static let email = "vasili.siniak+emotions@gmail.com"
    static let github = "https://github.com/vasilisiniak/emotions-ios"
    static let devLink = "https://github.com/vasilisiniak"
    static let emailInfo = "https://support.apple.com/ru-ru/HT201320"
    static let faceIdInfo = "https://support.apple.com/ru-ru/HT204060"
    static let emailTheme = "[Emotions]"
}
