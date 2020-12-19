import iOSViewControllers
import Presenters

final class CompositionRoot {
    
    // MARK: - Internal
    
    var logEventViewController: LogEventViewController {
        let viewController = LogEventViewController()
        LogEventConnector(viewController: viewController, composer: self).configure()
        return viewController
    }
    
    var emotionEventsViewController: EmotionEventsViewController {
        let viewController = EmotionEventsViewController()
        EmotionEventsConnector(viewController: viewController).configure()
        return viewController
    }
}

extension CompositionRoot: LogEventViewControllerComposer {
    func emotionsViewController(router: EmotionsGroupsRouter) -> EmotionsGroupsViewController {
        let emotionsViewController = EmotionsGroupsViewController()
        EmotionsGroupsConnector(viewController: emotionsViewController, router: router).configure()
        return emotionsViewController
    }
    
    func eventNameViewController(router: EventNameRouter, selectedEmotions: [String]) -> EventNameViewController {
        let eventNameViewController = EventNameViewController()
        EventNameConnector(viewController: eventNameViewController, router: router, selectedEmotions: selectedEmotions).configure()
        return eventNameViewController
    }
}
