import Firebase
import FirebaseAnalytics
import WidgetKit
import UIKit

fileprivate extension UIUserInterfaceStyle {
    var name: String {
        switch self {
        case .unspecified: return "unspecified"
        case .light: return "light"
        case .dark: return "dark"
        @unknown default: fatalError()
        }
    }
}

public enum AnalyticsEvent {
    case emotionNotFound
    case emotionDetails(emotion: String)
    case eventCreated(hasDetails: Bool)
    case eventEdited(hasDetails: Bool)
    case shareEvent
    case deleteEvent
    case eraseEvent
    case restoreEvent
    case editEvent
    case eraseAll
    case rate
    case share
    case suggestEmotion
    case suggestImprove
    case report
    case donate
    case designer
    case sourceCode
    case toggleExpand
    case roadmap
    case requestRate
    case requestShare
    case acceptRequestShare
    case declineRequestShare

    var name: String {
        switch self {
        case .emotionDetails: return "emotionDetails"
        case .eventCreated: return "eventCreated"
        default: return "\(self)"
        }
    }

    var params: [String: Any]? {
        switch self {
        case .emotionDetails(let emotion): return ["emotion": emotion]
        case .eventCreated(let hasDetails): return ["hasDetails": hasDetails]
        case .eventEdited(let hasDetails): return ["hasEditedDetails": hasDetails]
        default: return nil
        }
    }
}

public protocol AnalyticsManager {
    func track(_ event: AnalyticsEvent)
}

public final class AnalyticsManagerImpl {

    deinit {
        notificationsObservers?.forEach { NotificationCenter.default.removeObserver($0) }
    }

    // MARK: - Private

    #if DEBUG
        private let optout = true
    #else
        private let optout = false
    #endif


    private var notificationsObservers: [AnyObject]?
    private var settingsObserver: AnyObject?

    private var hasValidFirebaseConfig: Bool {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else { return false }
        guard let dict = NSDictionary(contentsOfFile: path) else { return false }
        return (dict.count == 14)
    }

    private func trackWidgetProperties() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            guard case let .success(info) = result else {
                assertionFailure()
                return
            }
            Analytics.setUserProperty("\(!info.isEmpty)", forName: "widget_added")
        }
    }

    private func trackSettingsProperties(_ settings: Settings) {
        Analytics.setUserProperty("\(settings.protectSensitiveData)", forName: "blur_enabled")
        Analytics.setUserProperty("\(settings.useFaceId)", forName: "faceid_enabled")
        Analytics.setUserProperty("\(settings.useLegacyLayout)", forName: "emotion_table_enabled")
        Analytics.setUserProperty("\(settings.useExpandedDiary)", forName: "emotion_table_expanded")
        Analytics.setUserProperty("\(settings.reduceAnimation)", forName: "reduce_animation")
        Analytics.setUserProperty("\(settings.useLegacyDiary)", forName: "legacy_diary")
        Analytics.setUserProperty("\(settings.appearance.name)", forName: "appearance")
    }

    private func trackDefaultsProperties() {
        Analytics.setUserProperty("\(UserDefaults.standard.bool(forKey: "UseCases.LogEventUseCaseImpl.FirstCreationKey"))", forName: "diary_info_shown")
        Analytics.setUserProperty("\(UserDefaults.standard.bool(forKey: "UseCases.LogEventUseCaseImpl.SecondCreationKey"))", forName: "trends_info_shown")
        Analytics.setUserProperty("\(UserDefaults.standard.bool(forKey: "UseCases.LogEventUseCaseImpl.ThirdCreationKey"))", forName: "widget_info_shown")

        Analytics.setUserProperty("\(UserDefaults.standard.bool(forKey: "Model.PromoManagerImpl.FirstRateKey"))", forName: "rate_once_shown")
        Analytics.setUserProperty("\(UserDefaults.standard.bool(forKey: "Model.PromoManagerImpl.FirstShareKey"))", forName: "share_once_shown")

        Analytics.setUserProperty("\(UserDefaults.standard.bool(forKey: "UseCases.EmotionsGroupsUseCaseImpl.FirstLaunchKey"))", forName: "long_tap_shown")
        Analytics.setUserProperty("\(UserDefaults.standard.bool(forKey: "UseCases.EmotionsGroupsUseCaseImpl.SecondLaunchKey"))", forName: "swipe_info_shown")

        Analytics.setUserProperty("\(UserDefaults.standard.bool(forKey: "UseCases.EmotionEventsUseCaseImpl.FirstEventDisplay"))", forName: "edit_info_shown")
        Analytics.setUserProperty("\(UserDefaults.standard.bool(forKey: "UseCases.EmotionEventsUseCaseImpl.TrashFirstEventDisplay"))", forName: "trash_info_shown")
        Analytics.setUserProperty("\(UserDefaults.standard.bool(forKey: "UseCases.EmotionEventsUseCaseImpl.FirstEventDelete"))", forName: "delete_info_shown")
    }

    // MARK: - Public

    public init(settings: Settings) {
        guard !optout else { return }

        guard hasValidFirebaseConfig else {
            print("GoogleService-Info.plist is not setup, skipping Firebase initialization")
            return
        }

        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)

        trackWidgetProperties()
        trackDefaultsProperties()
        trackSettingsProperties(settings)

        settingsObserver = settings.add { [weak self] in self?.trackSettingsProperties($0) }
        notificationsObservers = [
            NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
                self?.trackWidgetProperties()
                Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
            },
            NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
                self?.trackDefaultsProperties()
            }
        ]
    }
}

extension AnalyticsManagerImpl: AnalyticsManager {
    public func track(_ event: AnalyticsEvent) {
        guard !optout else { return }
        Analytics.logEvent(event.name, parameters: event.params)
    }
}
