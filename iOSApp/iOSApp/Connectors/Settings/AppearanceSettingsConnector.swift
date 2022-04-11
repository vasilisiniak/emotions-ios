import iOSViewControllers
import Presenters
import UseCases
import Model

final class AppearanceSettingsConnector {

    // MARK: - Private

    private let viewController: SettingsViewController
    private let presenter: AppearanceSettingsPresenterImpl
    private let useCase: AppearanceSettingsUseCaseImpl

    // MARK: - Internal

    init(viewController: SettingsViewController, settings: Settings, eventsProvider: EmotionEventsProvider) {
        self.viewController = viewController
        presenter = AppearanceSettingsPresenterImpl()
        useCase = AppearanceSettingsUseCaseImpl(settings: settings, eventsProvider: eventsProvider)
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.useCase = useCase
        useCase.output = presenter
    }
}
