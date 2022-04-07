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

    init(
        viewController: EmotionEventsViewController,
        router: EmotionEventsRouter,
        settings: Settings,
        lock: LockManager,
        analytics: AnalyticsManager,
        eventsProvider: EmotionEventsProvider,
        groupsProvider: EmotionsGroupsProvider,
        faceIdInfo: String,
        mode: EmotionEventsUseCaseObjects.Mode
    ) {
        self.viewController = viewController
        self.router = router
        presenter = EmotionEventsPresenterImpl()
        useCase = EmotionEventsUseCaseImpl(
            mode: mode,
            settings: settings,
            lock: lock,
            analytics: analytics,
            eventsProvider: eventsProvider,
            groupsProvider: groupsProvider,
            faceIdInfo: faceIdInfo
        )
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.router = router
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
