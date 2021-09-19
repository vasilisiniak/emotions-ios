import iOSViewControllers
import Presenters
import UseCases
import Model

final class LogEventConnector {

    // MARK: - Private

    private let viewController: LogEventViewController
    private let router: LogEventRouter
    private let composer: LogEventViewControllerComposer
    private let presenter: LogEventPresenterImpl
    private let useCase: LogEventUseCaseImpl

    // MARK: - Internal

    init(viewController: LogEventViewController, router: LogEventRouter, composer: LogEventViewControllerComposer, promoManager: PromoManager, appLink: String) {
        self.viewController = viewController
        self.router = router
        self.composer = composer
        presenter = LogEventPresenterImpl()
        useCase = LogEventUseCaseImpl(promoManager: promoManager, appLink: appLink)
    }

    func configure() {
        viewController.composer = composer
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.router = router
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
