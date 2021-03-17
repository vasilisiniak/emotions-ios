import Foundation
import iOSViewControllers
import Presenters

final class CompositionRoot {
    
    // MARK: - Internal
    
    var emotionsViewController: EmotionsViewController {
        let viewController = EmotionsViewController()
        EmotionsConnector(viewController: viewController, composer: self).configure()
        return viewController
    }
}

extension CompositionRoot: LogEventViewControllerComposer {
    func emotionsViewController(router: EmotionsGroupsRouter) -> EmotionsGroupsViewController {
        let emotionsViewController = EmotionsGroupsViewController()
        EmotionsGroupsConnector(viewController: emotionsViewController, router: router).configure()
        return emotionsViewController
    }
    
    func eventNameViewController(router: EventNameRouter, selectedEmotions: [String], color: String) -> EventNameViewController {
        let eventNameViewController = EventNameViewController()
        let connector = EventNameConnector(
            viewController: eventNameViewController,
            router: router,
            provider: AppGroup.emotionEventsProvider,
            selectedEmotions: selectedEmotions,
            color: color
        )
        connector.configure()
        return eventNameViewController
    }
}

extension CompositionRoot: EmotionsViewControllerComposer {
    var logEventViewController: LogEventViewController {
        let viewController = LogEventViewController()
        LogEventConnector(viewController: viewController, composer: self).configure()
        return viewController
    }

    func appInfoViewController(router: AppInfoRouter) -> AppInfoViewController {
        let viewController = AppInfoViewController()
        AppInfoConnector(viewController: viewController, router: router).configure()
        return viewController
    }

    func editEventNameViewController(router: EventNameRouter, emotion: String, date: Date, selectedEmotions: [String], color: String) -> EventNameViewController {
        let eventNameViewController = EventNameViewController()
        let connector = EditEventNameConnector(
            viewController: eventNameViewController,
            router: router,
            provider: AppGroup.emotionEventsProvider,
            emotion: emotion,
            date: date,
            selectedEmotions: selectedEmotions,
            color: color
        )
        connector.configure()
        return eventNameViewController
    }
    
    func trendsViewController(router: TrendsRouter) -> TrendsViewController {
        let viewController = TrendsViewController()
        TrendsConnector(viewController: viewController, router: router, provider: AppGroup.emotionEventsProvider).configure()
        return viewController
    }
    
    func emotionEventsViewController(router: EmotionEventsRouter) -> EmotionEventsViewController {
        let viewController = EmotionEventsViewController()
        EmotionEventsConnector(viewController: viewController, router: router, provider: AppGroup.emotionEventsProvider).configure()
        return viewController
    }
}
