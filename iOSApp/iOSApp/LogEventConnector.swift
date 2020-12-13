import iOSViewControllers
import Presenters
import UseCases

class LogEventConnector {
    
    // MARK: - Private
    
    private let viewController: LogEventViewController
    private let configurator: LogEventViewControllerConfigurator
    private let presenter: LogEventPresenterImpl
    private let useCase: LogEventUseCaseImpl
    
    // MARK: - Internal
    
    init(viewController: LogEventViewController, configurator: LogEventViewControllerConfigurator) {
        self.viewController = viewController
        self.configurator = configurator
        presenter = LogEventPresenterImpl()
        useCase = LogEventUseCaseImpl()
    }
    
    func configure() {
        viewController.configurator = configurator
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
