import iOSViewControllers
import Presenters
import Model
import Storage

final class CompositionRoot {
    
    // MARK: - Private
    
    private let emotionEventsProvider = EmotionEventsProviderImpl<EmotionEventEntity>(storage: CoreDataStorage(model: "Model"))
    
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
            provider: emotionEventsProvider,
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
    
    func trendsViewController(router: TrendsRouter) -> TrendsViewController {
        let viewController = TrendsViewController()
        TrendsConnector(viewController: viewController, router: router, provider: emotionEventsProvider).configure()
        return viewController
    }
    
    func emotionEventsViewController(router: EmotionEventsRouter) -> EmotionEventsViewController {
        let viewController = EmotionEventsViewController()
        EmotionEventsConnector(viewController: viewController, router: router, provider: emotionEventsProvider).configure()
        return viewController
    }
}
