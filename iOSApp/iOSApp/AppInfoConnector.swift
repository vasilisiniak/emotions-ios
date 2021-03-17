import iOSViewControllers
import Presenters
import UseCases

final class AppInfoConnector {

    // MARK: - Private

    private let viewController: AppInfoViewController
    private let router: AppInfoRouter
    private let presenter: AppInfoPresenterImpl

    // MARK: - Internal

    init(viewController: AppInfoViewController, router: AppInfoRouter) {
        self.viewController = viewController
        self.router = router
        presenter = AppInfoPresenterImpl()
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.router = router
    }
}
