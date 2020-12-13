import UIKit
import iOSViewControllers
import Presenters

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Private
    
    private var logEventViewController: LogEventViewController {
        let viewController = LogEventViewController()
        LogEventConnector(viewController: viewController, configurator: self).configure()
        return viewController
    }
    
    // MARK: - UIApplicationDelegate
    
    var window: UIWindow?
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = logEventViewController
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
