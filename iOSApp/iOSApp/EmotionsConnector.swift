import iOSViewControllers
import Presenters
import UseCases

final class EmotionsConnector {

    // MARK: - Private

    private let viewController: EmotionsViewController
    private let composer: EmotionsViewControllerComposer
    private let presenter: EmotionsPresenterImpl
    private let useCase: EmotionsUseCaseImpl

    // MARK: - Internal

    init(viewController: EmotionsViewController, composer: EmotionsViewControllerComposer) {
        self.viewController = viewController
        self.composer = composer
        presenter = EmotionsPresenterImpl()
        useCase = EmotionsUseCaseImpl()
    }

    func configure() {
        viewController.composer = composer
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
