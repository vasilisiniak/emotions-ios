import Foundation
import iOSViewControllers
import Presenters
import UseCases
import Model

final class TrendsConnector {

    // MARK: - Private

    private let viewController: TrendsViewController
    private let router: TrendsRouter
    private let presenter: TrendsPresenterImpl
    private let useCase: TrendsUseCaseImpl

    // MARK: - Internal

    init(
        viewController: TrendsViewController,
        router: TrendsRouter,
        eventsProvider: EmotionEventsProvider,
        emotionsProvider: EmotionsGroupsProvider,
        settings: Settings
    ) {
        self.viewController = viewController
        self.router = router
        presenter = TrendsPresenterImpl()
        useCase = TrendsUseCaseImpl(eventsProvider: eventsProvider, emotionsProvider: emotionsProvider, settings: settings)
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.router = router
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
