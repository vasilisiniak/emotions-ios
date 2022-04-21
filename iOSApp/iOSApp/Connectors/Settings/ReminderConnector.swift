import iOSViewControllers
import Presenters
import UseCases
import Model

public final class ReminderConnector {

    // MARK: - Private

    private let viewController: ReminderViewController
    private let router: ReminderRouter
    private let presenter: ReminderPresenterImpl
    private let useCase: ReminderUseCaseImpl

    // MARK: - Internal

    init(viewController: ReminderViewController, router: ReminderRouter, reminders: RemindersManager) {
        self.viewController = viewController
        self.router = router
        presenter = ReminderPresenterImpl()
        useCase = ReminderUseCaseImpl(reminders: reminders)
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.router = router
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
