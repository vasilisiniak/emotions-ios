import Foundation
import iOSViewControllers
import Presenters
import UseCases
import Model

final class EditEventNameConnector {

    // MARK: - Private

    private let viewController: EventNameViewController
    private let router: EventNameRouter
    private let presenter: EventNamePresenterImpl
    private let useCase: EditEventNameUseCaseImpl

    // MARK: - Internal

    init(
        viewController: EventNameViewController,
        router: EventNameRouter,
        provider: EmotionEventsProvider,
        emotion: String,
        date: Date,
        selectedEmotions: [String],
        color: String
    ) {
        self.viewController = viewController
        self.router = router
        presenter = EventNamePresenterImpl()
        useCase = EditEventNameUseCaseImpl(
            provider: provider,
            emotion: emotion,
            date: date,
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
