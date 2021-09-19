import UIKit

@UIApplicationMain final class AppDelegate: UIResponder {

    // MARK: - Private

    private let compositionRoot = CompositionRoot()

    // MARK: - Internal

    var window: UIWindow?
}

extension AppDelegate: UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = compositionRoot.emotionsViewController
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        compositionRoot.promoManager.trackAppLaunch()
    }
}
