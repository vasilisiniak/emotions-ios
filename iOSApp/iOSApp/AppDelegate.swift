import UIKit

@UIApplicationMain final class AppDelegate: UIResponder {
    
    // MARK: - Private
    
    private let compositionRoot = CompositionRoot()
    
    private var tabBarController: UITabBarController {
        let controller = UITabBarController()
        controller.viewControllers = [
            compositionRoot.logEventViewController,
            compositionRoot.emotionEventsViewController
        ]
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
