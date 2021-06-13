import iOSViewControllers
import Presenters
import UseCases

final class AppInfoConnector {

    // MARK: - Private

    private let viewController: AppInfoViewController
    private let router: AppInfoRouter
    private let presenter: AppInfoPresenterImpl
    private let useCase: AppInfoUseCaseImpl

    // MARK: - Internal

    init(viewController: AppInfoViewController, router: AppInfoRouter, appLink: String) {
        self.viewController = viewController
        self.router = router
        presenter = AppInfoPresenterImpl()
        useCase = AppInfoUseCaseImpl(appLink: appLink)
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.router = router
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
