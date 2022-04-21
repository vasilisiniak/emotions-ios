import iOSViewControllers
import Presenters
import UseCases
import Model

final class NotificationSettingsConnector {

    // MARK: - Private

    private let viewController: NotificationSettingsViewController
    private let router: NotificationsSettingsRouter
    private let presenter: NotificationsSettingsPresenterImpl
    private let useCase: NotificationsSettingsUseCaseImpl

    // MARK: - Internal

    init(
        viewController: NotificationSettingsViewController,
        router: NotificationsSettingsRouter,
        notifications: NotificationsManager,
        reminders: RemindersManager
    ) {
        self.viewController = viewController
        self.router = router
        presenter = NotificationsSettingsPresenterImpl()
        useCase = NotificationsSettingsUseCaseImpl(notifications: notifications, reminders: reminders)
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.router = router
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
