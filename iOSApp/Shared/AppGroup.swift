import Foundation
import Model
import Storage

enum AppGroup {
    static let emotionEventsProvider: EmotionEventsProvider = {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.by.vasili.siniak.emotions")!
        let storeURL = containerURL.appendingPathComponent("emotions.sqlite")
        let storage = CoreDataStorage(model: "Model", url: storeURL, cloudKitGroup: "iCloud.by.vasili.siniak.emotions")
        return EmotionEventsProviderImpl<EmotionEventEntity>(storage: storage)
    }()

    static let groupsProvider: EmotionsGroupsProvider = EmotionsGroupsProviderImpl(url: Bundle.main.url(forResource: "Emotions", withExtension: "plist")!)
    static let settings: Settings = UserDefaultsSettings(defaults: UserDefaults(suiteName: "group.by.vasili.siniak.emotions")!)

    static let appLink = "https://apps.apple.com/app/id1558896129"
    static let email = "vasili.siniak+emotions@gmail.com"
    static let github = "https://github.com/vasilisiniak/emotions-ios"
    static let designer = "https://www.facebook.com/sergey.grabinsky"
    static let emailInfo = "https://support.apple.com/ru-ru/HT201320"
    static let faceIdInfo = "https://support.apple.com/ru-ru/HT204060"
    static let emailTheme = "[Emotions]"
}
