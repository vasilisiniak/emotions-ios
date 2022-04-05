import UIKit
import Model

@UIApplicationMain final class AppDelegate: UIResponder {

    // MARK: - Private
    
    private let compositionRoot = CompositionRoot()
    private var token: AnyObject?

    func updateAppearance() {
        window?.overrideUserInterfaceStyle = AppGroup.settings.appearance
    }

    // MARK: - Internal

    var window: UIWindow? {
        didSet { updateAppearance() }
    }
}

extension AppDelegate: UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        compositionRoot.metricsManager.start()
        compositionRoot.migrationManager.migrate()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = compositionRoot.emotionsViewController
        window?.makeKeyAndVisible()

        token = AppGroup.settings.add { [weak self] _ in self?.updateAppearance() }

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        compositionRoot.promoManager.trackAppLaunch()
    }
}
