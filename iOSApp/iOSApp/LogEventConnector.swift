import iOSViewControllers
import Presenters
import UseCases

class LogEventConnector {
    
    // MARK: - Private
    
    private let viewController: LogEventViewController
    private let composer: LogEventViewControllerComposer
    private let presenter: LogEventPresenterImpl
    private let useCase: LogEventUseCaseImpl
    
    // MARK: - Internal
    
    init(viewController: LogEventViewController, composer: LogEventViewControllerComposer) {
        self.viewController = viewController
        self.composer = composer
        presenter = LogEventPresenterImpl()
        useCase = LogEventUseCaseImpl()
    }
    
    func configure() {
        viewController.composer = composer
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
