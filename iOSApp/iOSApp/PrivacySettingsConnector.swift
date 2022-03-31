import iOSViewControllers
import Presenters
import UseCases
import Model

final class PrivacySettingsConnector {

    // MARK: - Private

    private let viewController: SettingsViewController
    private let router: PrivacySettingsRouter
    private let presenter: PrivacySettingsPresenterImpl
    private let useCase: PrivacySettingsUseCaseImpl

    // MARK: - Internal

    init(
        viewController: SettingsViewController,
        router: PrivacySettingsRouter,
        settings: Settings,
        analytics: AnalyticsManager,
        lock: LockManager,
        faceIdInfo: String
    ) {
        self.viewController = viewController
        self.router = router
        presenter = PrivacySettingsPresenterImpl()
        useCase = PrivacySettingsUseCaseImpl(
            settings: settings,
            analytics: analytics,
            lock: lock,
            faceIdInfo: faceIdInfo
        )
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.router = router
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
