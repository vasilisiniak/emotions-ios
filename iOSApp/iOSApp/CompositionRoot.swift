import Foundation
import iOSViewControllers
import Presenters
import Model

final class CompositionRoot {

    // MARK: - Private

    private let analytics = AnalyticsManagerImpl(settings: AppGroup.settings)
    private let lock = LockManagerImpl()

    // MARK: - Internal

    let metricsManager: MetricsManager = MetricsManagerImpl()
    let promoManager: PromoManager = PromoManagerImpl(emotionsProvider: AppGroup.emotionEventsProvider)
    let migrationManager: MigrationManager = MigrationManagerImpl(eventsProvider: AppGroup.emotionEventsProvider)
    let newsManager: NewsManager = NewsManagerImpl(eventsProvider: AppGroup.emotionEventsProvider)

    lazy var emotionsViewController: EmotionsViewController = {
        let viewController = EmotionsViewController()
        EmotionsConnector(viewController: viewController, newsManager: newsManager, provider: AppGroup.emotionEventsProvider, composer: self).configure()
        return viewController
    }()
}

extension CompositionRoot: LogEventViewControllerComposer {
    func emotionNotFoundViewController(router: EmotionNotFoundRouter) -> EmotionNotFoundViewController {
        let emotionNotFoundViewController = EmotionNotFoundViewController()
        EmotionNotFoundConnector(
            viewController: emotionNotFoundViewController,
            router: router,
            analytics: analytics,
            email: AppGroup.email,
            emailInfo: AppGroup.emailInfo,
            emailTheme: AppGroup.emailTheme
        ).configure()
        return emotionNotFoundViewController
    }

    func emotionsViewController(router: EmotionsGroupsRouter) -> EmotionsGroupsViewController {
        let emotionsViewController = EmotionsGroupsViewController()
        EmotionsGroupsConnector(
            viewController: emotionsViewController,
            router: router,
            analytics: analytics,
            promoManager: promoManager,
            groupsProvider: AppGroup.groupsProvider,
            settings: AppGroup.settings,
            appLink: AppGroup.appLink
        ).configure()
        return emotionsViewController
    }

    func eventNameViewController(router: EventNameRouter, selectedEmotions: [String], color: String) -> EventNameViewController {
        let eventNameViewController = EventNameViewController()
        EventNameConnector(
            viewController: eventNameViewController,
            router: router,
            eventsProvider: AppGroup.emotionEventsProvider,
            groupsProvider: AppGroup.groupsProvider,
            analytics: analytics,
            selectedEmotions: selectedEmotions,
            color: color
        ).configure()
        return eventNameViewController
    }
}

extension CompositionRoot: EmotionsViewControllerComposer {
    var logEventViewController: LogEventViewController {
        let viewController = LogEventViewController()
        LogEventConnector(
            viewController: viewController,
            router: emotionsViewController,
            composer: self,
            promoManager: promoManager,
            analytics: analytics,
            appLink: AppGroup.appLink
        ).configure()
        return viewController
    }

    var appearanceSettingsViewController: SettingsViewController {
        let viewController = SettingsViewController()
        AppearanceSettingsConnector(viewController: viewController, settings: AppGroup.settings).configure()
        return viewController
    }

    func appInfoViewController(router: AppInfoRouter) -> SettingsViewController {
        let viewController = SettingsViewController()
        AppInfoConnector(
            viewController: viewController,
            router: router,
            analytics: analytics,
            appLink: AppGroup.appLink,
            email: AppGroup.email,
            github: AppGroup.github,
            designer: AppGroup.designer,
            emailInfo: AppGroup.emailInfo,
            faceIdInfo: AppGroup.faceIdInfo,
            emailTheme: AppGroup.emailTheme
        ).configure()
        return viewController
    }

    func privacySettingsViewController(router: PrivacySettingsRouter) -> SettingsViewController {
        let viewController = SettingsViewController()
        PrivacySettingsConnector(
            viewController: viewController,
            router: router,
            settings: AppGroup.settings,
            analytics: analytics,
            lock: lock,
            faceIdInfo: AppGroup.faceIdInfo
        ).configure()
        return viewController
    }

    func editEventNameViewController(router: EventNameRouter, name: String, details: String?, date: Date, selectedEmotions: [String], color: String) -> EventNameViewController {
        let eventNameViewController = EventNameViewController()
        EditEventNameConnector(
            viewController: eventNameViewController,
            router: router,
            eventsProvider: AppGroup.emotionEventsProvider,
            groupsProvider: AppGroup.groupsProvider,
            name: name,
            details: details,
            date: date,
            selectedEmotions: selectedEmotions,
            color: color
        ).configure()
        return eventNameViewController
    }

    func trendsViewController(router: TrendsRouter) -> TrendsViewController {
        let viewController = TrendsViewController()
        TrendsConnector(viewController: viewController, router: router, provider: AppGroup.emotionEventsProvider, settings: AppGroup.settings).configure()
        return viewController
    }

    func emotionEventsViewController(router: EmotionEventsRouter) -> EmotionEventsViewController {
        let viewController = EmotionEventsViewController()
        EmotionEventsConnector(
            viewController: viewController,
            router: router,
            settings: AppGroup.settings,
            lock: lock,
            analytics: analytics,
            eventsProvider: AppGroup.emotionEventsProvider,
            groupsProvider: AppGroup.groupsProvider,
            faceIdInfo: AppGroup.faceIdInfo,
            mode: .normal
        ).configure()
        return viewController
    }

    func deletedEventsViewController(router: EmotionEventsRouter) -> EmotionEventsViewController {
        let viewController = EmotionEventsViewController()
        EmotionEventsConnector(
            viewController: viewController,
            router: router,
            settings: AppGroup.settings,
            lock: lock,
            analytics: analytics,
            eventsProvider: AppGroup.emotionEventsProvider,
            groupsProvider: AppGroup.groupsProvider,
            faceIdInfo: AppGroup.faceIdInfo,
            mode: .deleted
        ).configure()
        return viewController
    }
}
