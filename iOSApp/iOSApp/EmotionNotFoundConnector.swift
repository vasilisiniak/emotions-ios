import iOSViewControllers
import Presenters

final class EmotionNotFoundConnector {

    // MARK: - Private

    private let viewController: EmotionNotFoundViewController
    private let router: EmotionNotFoundRouter
    private let presenter: EmotionNotFoundPresenterImpl

    // MARK: - Internal

    init(viewController: EmotionNotFoundViewController, router: EmotionNotFoundRouter, email: String, emailInfo: String, emailTheme: String) {
        self.viewController = viewController
        self.router = router
        presenter = EmotionNotFoundPresenterImpl(email: email, emailInfo: emailInfo, emailTheme: emailTheme)
    }

    func configure() {
        viewController.presenter = presenter
        presenter.output = viewController
        presenter.router = router
    }
}
