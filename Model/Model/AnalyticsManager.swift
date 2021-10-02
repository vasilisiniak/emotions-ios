import Firebase
import FirebaseAnalytics
import WidgetKit
import UIKit

public final class AnalyticsManager {

    // MARK: - Private

    private var observers: [AnyObject] = []

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
    }

    // MARK: - Public

    public init(settings: Settings) {
        guard hasValidFirebaseConfig else {
            print("GoogleService-Info.plist is not setup, skipping Firebase initialization")
            return
        }

        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)

        trackWidgetProperties()
        trackDefaultsProperties()
        trackSettingsProperties(settings)

        observers = [
            NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
                self?.trackWidgetProperties()
            },
            NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
                self?.trackDefaultsProperties()
            },
            settings.add { [weak self] in self?.trackSettingsProperties($0) }
        ]
    }
}
