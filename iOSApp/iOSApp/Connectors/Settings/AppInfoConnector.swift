import iOSViewControllers
import Presenters
import UseCases
import Model

final class AppInfoConnector {

    // MARK: - Private

    private let viewController: SettingsViewController
    private let router: AppInfoRouter
    private let presenter: AppInfoPresenterImpl
    private let useCase: AppInfoUseCaseImpl

    // MARK: - Internal

    init(
        viewController: SettingsViewController,
        router: AppInfoRouter,
        analytics: AnalyticsManager,
        appLink: String,
        email: String,
        github: String,
        roadmap: String,
        designer: String,
        emailInfo: String,
        faceIdInfo: String,
        emailTheme: String
    ) {
        self.viewController = viewController
        self.router = router
        presenter = AppInfoPresenterImpl()
        useCase = AppInfoUseCaseImpl(
            analytics: analytics,
            appLink: appLink,
            email: email,
            github: github,
            roadmap: roadmap,
            designer: designer,
            emailInfo: emailInfo,
            faceIdInfo: faceIdInfo,
            emailTheme: emailTheme
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
