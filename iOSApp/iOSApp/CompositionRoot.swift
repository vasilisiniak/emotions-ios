import Foundation
import iOSViewControllers
import Presenters
import Model

final class CompositionRoot {

    // MARK: - Private

    private let analytics = AnalyticsManagerImpl(settings: AppGroup.settings)
    private let lock = LockManagerImpl()
    private let state = UserDefaultsStateManager(defaults: UserDefaults.standard)

    private lazy var reminders: RemindersManagerImpl = {
        RemindersManagerImpl(message: AppGroup.reminder, manager: notifications, settings: AppGroup.settings)
    }()

    // MARK: - Internal

    let notifications = LocalNotificationsManager()
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
        emotionsViewController(router: router, emotions: [])
    }

    func eventNameViewController(router: EventNameRouter, selectedEmotions: [String], color: String) -> EventNameViewController {
        let eventNameViewController = EventNameViewController()
        EventNameConnector(
            viewController: eventNameViewController,
            router: router,
            eventsProvider: AppGroup.emotionEventsProvider,
            groupsProvider: AppGroup.groupsProvider,
            analytics: analytics,
            state: state,
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
        AppearanceSettingsConnector(
            viewController: viewController,
            settings: AppGroup.settings,
            eventsProvider: AppGroup.emotionEventsProvider
        ).configure()
        return viewController
    }

    func reminderViewController(router: ReminderRouter) -> ReminderViewController {
        let viewController = ReminderViewController(style: .insetGrouped)
        ReminderConnector(viewController: viewController, router: router, reminders: reminders).configure()
        return viewController
    }

    func notificationsSettingsViewController(router: NotificationsSettingsRouter) -> NotificationSettingsViewController {
        let viewController = NotificationSettingsViewController(style: .insetGrouped)
        NotificationSettingsConnector(
            viewController: viewController,
            router: router,
            notifications: notifications,
            reminders: reminders
        ).configure()
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
            roadmap: AppGroup.roadmap,
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
            analytics: analytics,
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
        TrendsConnector(
            viewController: viewController,
            router: router,
            eventsProvider: AppGroup.emotionEventsProvider,
            emotionsProvider: AppGroup.groupsProvider,
            settings: AppGroup.settings
        ).configure()
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

    func emotionsViewController(router: EmotionsGroupsRouter, emotions: [String]) -> EmotionsGroupsViewController {
        let emotionsViewController = EmotionsGroupsViewController()
        EmotionsGroupsConnector(
            viewController: emotionsViewController,
            router: router,
            analytics: analytics,
            promoManager: promoManager,
            groupsProvider: AppGroup.groupsProvider,
            settings: AppGroup.settings,
            state: state,
            appLink: AppGroup.appLink,
            emotions: emotions
        ).configure()
        return emotionsViewController
    }
}
