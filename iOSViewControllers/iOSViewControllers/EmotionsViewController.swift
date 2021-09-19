import UIKit
import MessageUI
import Presenters

public protocol EmotionsViewControllerComposer: AnyObject {
    var logEventViewController: LogEventViewController { get }
    func appInfoViewController(router: AppInfoRouter) -> AppInfoViewController
    func editEventNameViewController(router: EventNameRouter, emotion: String, date: Date, selectedEmotions: [String], color: String) -> EventNameViewController
    func trendsViewController(router: TrendsRouter) -> TrendsViewController
    func emotionEventsViewController(router: EmotionEventsRouter) -> EmotionEventsViewController
}

public final class EmotionsViewController: UITabBarController {

    // MARK: - UIViewController

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.eventViewReady()
    }

    // MARK: - Public

    public var presenter: EmotionsPresenter!
    public weak var composer: EmotionsViewControllerComposer!
}

extension EmotionsViewController: EmotionEventsRouter, TrendsRouter {
    public func routeEmotions() {
        if presentedViewController != nil {
            dismiss(animated: true, completion: nil)
        }
        else {
            selectedIndex = 0
        }
    }

    public func route(shareText: String) {
        let controller = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }

    public func route(editEvent: EmotionEventsPresenterObjects.EventsGroup.Event, date: Date) {
        let controller = composer.editEventNameViewController(
            router: self,
            emotion: editEvent.name,
            date: date,
            selectedEmotions: editEvent.emotions.components(separatedBy: ", "),
            color: editEvent.color.hex
        )
        present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }
}

extension EmotionsViewController: EventNameRouter {
    public func routeBack() {
        dismiss(animated: true, completion: nil)
    }
}

extension EmotionsViewController: AppInfoRouter, LogEventRouter {
    public func route(emailTheme: String, email: String) {
        let controller = MFMailComposeViewController()
        controller.setSubject(emailTheme)
        controller.setToRecipients([email])
        controller.mailComposeDelegate = self
        topPresentedViewController.present(controller, animated: true, completion: nil)
    }

    public func route(url: String) {
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }

    public func route(shareItem: UIActivityItemSource) {
        let activityViewController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
        present(activityViewController, animated: true, completion: nil)
    }
}

extension EmotionsViewController: EmotionsPresenterOutput {
    public func showEmotions() {
        viewControllers = [
            composer.logEventViewController,
            composer.emotionEventsViewController(router: self),
            composer.trendsViewController(router: self),
            composer.appInfoViewController(router: self)
        ]
    }
}

extension EmotionsViewController: UINavigationControllerDelegate { }

extension EmotionsViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
