import iOSViewControllers
import Presenters
import UseCases
import Model

final class PasscodeConnector {

    // MARK: - Private

    private let viewController: PasscodeViewController
    private let router: PasscodeRouter
    private let presenter: PasscodePresenterImpl
    private let useCase: PasscodeUseCaseImpl

    // MARK: - Internal

    init(
        viewController: PasscodeViewController,
        router: PasscodeRouter,
        mode: PasscodeUseCaseObjects.Mode,
        info: String,
        manager: PasscodeManager,
        completion: @escaping (_ success: Bool) -> ()
    ) {
        self.viewController = viewController
        self.router = router
        presenter = PasscodePresenterImpl()
        useCase = PasscodeUseCaseImpl(mode: mode, info: info, passcodeManager: manager)
        useCase.completion = completion
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.router = router
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
