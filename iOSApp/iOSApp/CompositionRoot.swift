import Foundation
import iOSViewControllers
import Presenters
import Model

final class CompositionRoot {

    // MARK: - Private

    private let analytics = AnalyticsManagerImpl(settings: AppGroup.settings)

    // MARK: - Internal

    let promoManager: PromoManager = PromoManagerImpl(emotionsProvider: AppGroup.emotionEventsProvider)
    let migrationManager: MigrationManager = MigrationManagerImpl(eventsProvider: AppGroup.emotionEventsProvider)

    lazy var emotionsViewController: EmotionsViewController = {
        let viewController = EmotionsViewController()
        EmotionsConnector(viewController: viewController, composer: self).configure()
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
            appLink: AppGroup.appLink
        ).configure()
        return emotionsViewController
    }

    func eventNameViewController(router: EventNameRouter, selectedEmotions: [String], color: String) -> EventNameViewController {
        let eventNameViewController = EventNameViewController()
        EventNameConnector(
            viewController: eventNameViewController,
            router: router,
            provider: AppGroup.emotionEventsProvider,
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

    func appInfoViewController(router: AppInfoRouter) -> AppInfoViewController {
        let viewController = AppInfoViewController()
        AppInfoConnector(
            viewController: viewController,
            router: router,
            settings: AppGroup.settings,
            analytics: analytics,
            appLink: AppGroup.appLink,
            email: AppGroup.email,
            github: AppGroup.github,
            emailInfo: AppGroup.emailInfo,
            emailTheme: AppGroup.emailTheme
        ).configure()
        return viewController
    }

    func editEventNameViewController(router: EventNameRouter, emotion: String, date: Date, selectedEmotions: [String], color: String) -> EventNameViewController {
        let eventNameViewController = EventNameViewController()
        EditEventNameConnector(
            viewController: eventNameViewController,
            router: router,
            provider: AppGroup.emotionEventsProvider,
            emotion: emotion,
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
            analytics: analytics,
            provider: AppGroup.emotionEventsProvider
        ).configure()
        return viewController
    }
}
