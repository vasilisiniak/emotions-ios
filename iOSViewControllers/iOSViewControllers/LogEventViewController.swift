import UIKit
import Presenters

public protocol LogEventViewControllerComposer: AnyObject {
    func emotionsViewController(router: EmotionsGroupsRouter) -> EmotionsGroupsViewController
    func eventNameViewController(router: EventNameRouter, selectedEmotions: [String], color: String) -> EventNameViewController
    func emotionNotFoundViewController(router: EmotionNotFoundRouter) -> EmotionNotFoundViewController
}

public final class LogEventViewController: UINavigationController {

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        presenter.eventViewReady()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = ""
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    public var presenter: LogEventPresenter!
    public weak var composer: LogEventViewControllerComposer!

    public init() {
        super.init(nibName: nil, bundle: nil)
        let tabBarIcon = UIImage(named: "LogEventTabBarIcon", in: Bundle(for: LogEventViewController.self), with: nil)
        tabBarItem = UITabBarItem(title: nil, image: tabBarIcon, selectedImage: nil)
    }
}

extension LogEventViewController: UIGestureRecognizerDelegate {}

extension LogEventViewController: EmotionsGroupsRouter {
    public func routeNotFound() {
        let emotionNotFoundViewController = composer.emotionNotFoundViewController(router: self)
        let navigationController = UINavigationController(rootViewController: emotionNotFoundViewController)
        present(navigationController, animated: true)
    }

    public func routeEventName(selectedEmotions: [String], color: String) {
        let eventNameViewController = composer.eventNameViewController(router: self, selectedEmotions: selectedEmotions, color: color)
        let navigationController = UINavigationController(rootViewController: eventNameViewController)
        present(navigationController, animated: true)
    }
}

extension LogEventViewController: EventNameRouter {
    public func routeEmotions() {
        dismiss(animated: true) { [weak self] in
            self?.presenter.eventEventCreated()
            (self?.viewControllers.first as? EmotionsGroupsViewController)?.presenter.eventClear()
        }
    }

    public func routeCancel() {
        dismiss(animated: true)
    }
}

extension LogEventViewController: EmotionNotFoundRouter {
    public func route(emailTheme: String, email: String) {
        presenter.event(emailTheme: emailTheme, email: email)
    }

    public func route(url: String) {
        presenter.event(url: url)
    }

    public func routeClose() {
        presentedViewController?.dismiss(animated: true)
    }
}

extension LogEventViewController: LogEventPresenterOutput {
    public func show(share: UIActivityItemSource) {
        let activityViewController = UIActivityViewController(activityItems: [share], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
        present(activityViewController, animated: true)
    }

    public func show(message: String, button: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .default))
        present(alert, animated: true)
    }

    public func showShareAlert(message: String, okButton: String, cancelButton: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okButton, style: .default, handler: { [weak self] _ in
            self?.presenter.eventShare()
        }))
        alert.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: { [weak self] _ in
            self?.presenter.eventCancelShare()
        }))
        present(alert, animated: true)
    }

    public func showWidgetAlert(message: String, okButton: String, infoButton: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okButton, style: .default))
        alert.addAction(UIAlertAction(title: infoButton, style: .default, handler: { [weak self] _ in
            self?.presenter.eventWidgetInfo()
        }))
        present(alert, animated: true)
    }

    public func showEmotions() {
        let emotionsViewController = composer.emotionsViewController(router: self)
        pushViewController(emotionsViewController, animated: true)
    }
}
