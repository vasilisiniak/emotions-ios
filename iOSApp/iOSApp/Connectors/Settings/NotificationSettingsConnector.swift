import iOSViewControllers
import Presenters
import UseCases
import Model

final class NotificationSettingsConnector {

    // MARK: - Private

    private let viewController: NotificationSettingsViewController
    private let presenter: NotificationsSettingsPresenterImpl
    private let useCase: NotificationsSettingsUseCaseImpl

    // MARK: - Internal

    init(
        viewController: NotificationSettingsViewController,
        notifications: NotificationsManager,
        reminders: RemindersManager,
        settings: Settings
    ) {
        self.viewController = viewController
        presenter = NotificationsSettingsPresenterImpl()
        useCase = NotificationsSettingsUseCaseImpl(notifications: notifications, reminders: reminders, settings: settings)
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
