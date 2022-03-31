import iOSViewControllers
import Presenters
import UseCases
import Model

final class EmotionNotFoundConnector {

    // MARK: - Private

    private let viewController: EmotionNotFoundViewController
    private let router: EmotionNotFoundRouter
    private let presenter: EmotionNotFoundPresenterImpl
    private let useCase: EmotionNotFoundUseCaseImpl

    // MARK: - Internal

    init(
        viewController: EmotionNotFoundViewController,
        router: EmotionNotFoundRouter,
        analytics: AnalyticsManager,
        email: String,
        emailInfo: String,
        emailTheme: String
    ) {
        self.viewController = viewController
        self.router = router
        presenter = EmotionNotFoundPresenterImpl()
        useCase = EmotionNotFoundUseCaseImpl(analytics: analytics, email: email, emailInfo: emailInfo, emailTheme: emailTheme)
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.router = router
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
