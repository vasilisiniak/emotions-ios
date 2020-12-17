import UIKit
import iOSViewControllers
import Presenters

@UIApplicationMain class AppDelegate: UIResponder {
    
    // MARK: - Private
    
    private var logEventViewController: LogEventViewController {
        let viewController = LogEventViewController()
        LogEventConnector(viewController: viewController, configurator: self).configure()
        return viewController
    }
    
    private var emotionEventsViewController: EmotionEventsViewController {
        let viewController = EmotionEventsViewController()
        EmotionEventsConnector(viewController: viewController).configure()
        return viewController
    }
    
    private var tabBarController: UITabBarController {
        let controller = UITabBarController()
        controller.viewControllers = [logEventViewController, emotionEventsViewController]
        return controller
    }
    
    // MARK: - Internal
    
    var window: UIWindow?
}

extension AppDelegate: UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        return true
    }
}

extension AppDelegate: LogEventViewControllerConfigurator {
    func configure(eventNameViewController: EventNameViewController, router: EventNameRouter, selectedEmotions: [String]) {
        EventNameConnector(viewController: eventNameViewController, router: router, selectedEmotions: selectedEmotions).configure()
    }
    
    func configure(emotionsViewController: EmotionsGroupsViewController, router: EmotionsGroupsRouter) {
        EmotionsGroupsConnector(viewController: emotionsViewController, router: router).configure()
    }
}
