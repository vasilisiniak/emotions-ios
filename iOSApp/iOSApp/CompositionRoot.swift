import iOSViewControllers
import Presenters
import Model
import Storage

final class CompositionRoot {
    
    // MARK: - Private
    
    private let emotionEventsProvider = EmotionEventsProviderImpl<EmotionEventEntity>(storage: CoreDataStorage(model: "Model"))
    
    // MARK: - Internal
    
    var logEventViewController: LogEventViewController {
        let viewController = LogEventViewController()
        LogEventConnector(viewController: viewController, composer: self).configure()
        return viewController
    }
    
    var emotionEventsViewController: EmotionEventsViewController {
        let viewController = EmotionEventsViewController()
        EmotionEventsConnector(viewController: viewController, provider: emotionEventsProvider).configure()
        return viewController
    }
    
    var trendsViewController: TrendsViewController {
        let viewController = TrendsViewController()
        TrendsConnector(viewController: viewController, provider: emotionEventsProvider).configure()
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
