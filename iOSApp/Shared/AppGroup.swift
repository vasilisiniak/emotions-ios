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
}
