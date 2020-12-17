import Foundation
import iOSViewControllers
import Presenters
import UseCases
import Model

class EmotionEventsConnector {
    
    // MARK: - Private
    
    private let viewController: EmotionEventsViewController
    private let presenter: EmotionEventsPresenterImpl
    private let useCase: EmotionEventsUseCaseImpl
    
    // MARK: - Internal
    
    init(viewController: EmotionEventsViewController) {
        let provider = EmotionEventsProviderImpl()
        self.viewController = viewController
        presenter = EmotionEventsPresenterImpl()
        useCase = EmotionEventsUseCaseImpl(eventsProvider: provider)
    }
    
    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
