import Foundation
import iOSViewControllers
import Presenters
import UseCases
import Model

final class EmotionsGroupsConnector {

    // MARK: - Private

    private let viewController: EmotionsGroupsViewController
    private let router: EmotionsGroupsRouter
    private let presenter: EmotionsGroupsPresenterImpl
    private let useCase: EmotionsGroupsUseCaseImpl

    // MARK: - Internal

    init(
        viewController: EmotionsGroupsViewController,
        router: EmotionsGroupsRouter,
        analytics: AnalyticsManager,
        promoManager: PromoManager,
        groupsProvider: EmotionsGroupsProvider,
        settings: Settings,
        state: StateManager,
        appLink: String,
        emotions: [String]
    ) {
        self.viewController = viewController
        self.router = router
        presenter = EmotionsGroupsPresenterImpl()
        useCase = EmotionsGroupsUseCaseImpl(
            emotionsProvider: groupsProvider,
            analytics: analytics,
            promoManager: promoManager,
            settings: settings,
            state: state,
            appLink: appLink,
            emotions: emotions
        )
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.useCase = useCase
        presenter.router = router
        useCase.output = presenter
    }
}
