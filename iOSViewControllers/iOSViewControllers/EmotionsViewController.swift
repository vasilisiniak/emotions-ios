import UIKit
import MessageUI
import Presenters
import SafariServices

public protocol EmotionsViewControllerComposer: AnyObject {
    var logEventViewController: LogEventViewController { get }
    func appInfoViewController(router: AppInfoRouter) -> AppInfoViewController
    func editEventNameViewController(router: EventNameRouter, emotion: String, date: Date, selectedEmotions: [String], color: String) -> EventNameViewController
    func trendsViewController(router: TrendsRouter) -> TrendsViewController
    func emotionEventsViewController(router: EmotionEventsRouter) -> EmotionEventsViewController
}

public final class EmotionsViewController: UITabBarController {

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !initialized else { return }
        presenter.eventViewReady()
        initialized = true
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.eventViewIsShown()
    }

    // MARK: - Private

    private var initialized = false

    // MARK: - Public

    public var presenter: EmotionsPresenter!
    public weak var composer: EmotionsViewControllerComposer!
}

extension EmotionsViewController: EmotionEventsRouter, TrendsRouter {
    public func routeEmotions() {
        if presentedViewController != nil {
            dismiss(animated: true)
        }
        else {
            selectedIndex = 0
        }
    }

    public func route(shareText: String) {
        let controller = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(controller, animated: true)
    }

    public func route(editEvent: EmotionEventsPresenterObjects.EventsGroup.Event, date: Date) {
        let controller = composer.editEventNameViewController(
            router: self,
            emotion: editEvent.name,
            date: date,
            selectedEmotions: editEvent.emotions.components(separatedBy: ", "),
            color: editEvent.color.hex
        )
        present(UINavigationController(rootViewController: controller), animated: true)
    }
}

extension EmotionsViewController: EventNameRouter {
    public func routeCancel() {
        dismiss(animated: true)
    }
}

extension EmotionsViewController: AppInfoRouter, LogEventRouter {
    public func route(emailTheme: String, email: String) {
        let controller = MFMailComposeViewController()
        controller.setSubject(emailTheme)
        controller.setToRecipients([email])
        controller.mailComposeDelegate = self
        topPresentedViewController.present(controller, animated: true)
    }

    public func route(url: String) {
        topPresentedViewController.present(SFSafariViewController(url: URL(string: url)!), animated: true)
    }

    public func route(shareItem: UIActivityItemSource) {
        let activityViewController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
        present(activityViewController, animated: true)
    }
}

extension EmotionsViewController: EmotionsPresenterOutput {
    public func showEmotions() {
        viewControllers = [
            composer.logEventViewController,
            UINavigationController(rootViewController: composer.emotionEventsViewController(router: self)),
            composer.trendsViewController(router: self),
            composer.appInfoViewController(router: self)
        ]
    }

    public func show(message: String, title: String, button: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .default))
        present(alert, animated: true)
    }
}

extension EmotionsViewController: UINavigationControllerDelegate { }

extension EmotionsViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}
