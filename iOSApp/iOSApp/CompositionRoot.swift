import Foundation
import iOSViewControllers
import Presenters
import Model

final class CompositionRoot {

    // MARK: - Internal

    let promoManager: PromoManager = PromoManagerImpl(emotionsProvider: AppGroup.emotionEventsProvider)

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
            email: AppGroup.email,
            emailInfo: AppGroup.emailInfo,
            emailTheme: AppGroup.emailTheme
        ).configure()
        return emotionNotFoundViewController
    }

    func emotionsViewController(router: EmotionsGroupsRouter) -> EmotionsGroupsViewController {
        let emotionsViewController = EmotionsGroupsViewController()
        EmotionsGroupsConnector(viewController: emotionsViewController, router: router, promoManager: promoManager, appLink: AppGroup.appLink).configure()
        return emotionsViewController
    }

    func eventNameViewController(router: EventNameRouter, selectedEmotions: [String], color: String) -> EventNameViewController {
        let eventNameViewController = EventNameViewController()
        EventNameConnector(
            viewController: eventNameViewController,
            router: router,
            provider: AppGroup.emotionEventsProvider,
            selectedEmotions: selectedEmotions,
            color: color
        ).configure()
        return eventNameViewController
    }
}

extension CompositionRoot: EmotionsViewControllerComposer {
    var logEventViewController: LogEventViewController {
        let viewController = LogEventViewController()
        LogEventConnector(viewController: viewController, router: emotionsViewController, composer: self, promoManager: promoManager, appLink: AppGroup.appLink).configure()
        return viewController
    }

    func appInfoViewController(router: AppInfoRouter) -> AppInfoViewController {
        let viewController = AppInfoViewController()
        AppInfoConnector(
            viewController: viewController,
            router: router,
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
        EmotionEventsConnector(viewController: viewController, router: router, provider: AppGroup.emotionEventsProvider).configure()
        return viewController
    }
}
