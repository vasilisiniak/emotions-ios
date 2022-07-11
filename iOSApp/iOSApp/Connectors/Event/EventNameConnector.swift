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

    init(
        viewController: EventNameViewController,
        router: EventNameRouter,
        eventsProvider: EmotionEventsProvider,
        groupsProvider: EmotionsGroupsProvider,
        analytics: AnalyticsManager,
        state: StateManager,
        selectedEmotions: [String],
        color: String
    ) {
        self.viewController = viewController
        self.router = router
        presenter = EventNamePresenterImpl()
        useCase = EventNameUseCaseImpl(
            eventsProvider: eventsProvider,
            groupsProvider: groupsProvider,
            analytics: analytics,
            state: state,
            selectedEmotions: selectedEmotions,
            color: color
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
