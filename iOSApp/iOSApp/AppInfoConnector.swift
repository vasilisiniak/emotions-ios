import iOSViewControllers
import Presenters
import UseCases
import Model

final class AppInfoConnector {

    // MARK: - Private

    private let viewController: AppInfoViewController
    private let router: AppInfoRouter
    private let presenter: AppInfoPresenterImpl
    private let useCase: AppInfoUseCaseImpl

    // MARK: - Internal

    init(
        viewController: AppInfoViewController,
        router: AppInfoRouter,
        analytics: AnalyticsManager,
        appLink: String,
        email: String,
        github: String,
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
