import Foundation
import iOSViewControllers
import Presenters
import UseCases
import Model

final class EventNameConnector {
    
    // MARK: - Private
    
    private let viewController: EventNameViewController
    private let router: EventNameRouter
    private let presenter: EventNamePresenterImpl
    private let useCase: EventNameUseCaseImpl
    
    // MARK: - Internal
    
    init(viewController: EventNameViewController, router: EventNameRouter, provider: EmotionEventsProvider, selectedEmotions: [String]) {
        self.viewController = viewController
        self.router = router
        presenter = EventNamePresenterImpl()
        useCase = EventNameUseCaseImpl(provider: provider, selectedEmotions: selectedEmotions)
    }
    
    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.useCase = useCase
        presenter.router = router
        useCase.output = presenter
    }
}
