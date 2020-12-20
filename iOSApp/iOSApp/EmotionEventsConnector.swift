import Foundation
import iOSViewControllers
import Presenters
import UseCases
import Model

final class EmotionEventsConnector {
    
    // MARK: - Private
    
    private let viewController: EmotionEventsViewController
    private let router: EmotionEventsRouter
    private let presenter: EmotionEventsPresenterImpl
    private let useCase: EmotionEventsUseCaseImpl
    
    // MARK: - Internal
    
    init(viewController: EmotionEventsViewController, router: EmotionEventsRouter, provider: EmotionEventsProvider) {
        self.viewController = viewController
        self.router = router
        presenter = EmotionEventsPresenterImpl()
        useCase = EmotionEventsUseCaseImpl(eventsProvider: provider)
    }
    
    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.router = router
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
