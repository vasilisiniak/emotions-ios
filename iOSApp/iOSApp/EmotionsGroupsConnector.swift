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
        appLink: String
    ) {
        let provider = EmotionsGroupsProviderImpl(url: Bundle.main.url(forResource: "Emotions", withExtension: "plist")!)
        self.viewController = viewController
        self.router = router
        presenter = EmotionsGroupsPresenterImpl()
        useCase = EmotionsGroupsUseCaseImpl(emotionsProvider: provider, analytics: analytics, promoManager: promoManager, appLink: appLink)
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.useCase = useCase
        presenter.router = router
        useCase.output = presenter
    }
}
