import Foundation
import iOSViewControllers
import Presenters
import UseCases
import Model

final class TrendsConnector {
    
    // MARK: - Private
    
    private let viewController: TrendsViewController
    private let presenter: TrendsPresenterImpl
    private let useCase: TrendsUseCaseImpl
    
    // MARK: - Internal
    
    init(viewController: TrendsViewController, provider: EmotionEventsProvider) {
        self.viewController = viewController
        presenter = TrendsPresenterImpl()
        useCase = TrendsUseCaseImpl(eventsProvider: provider)
    }
    
    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
