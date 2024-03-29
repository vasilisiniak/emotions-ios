import UIKit
import MessageUI
import Presenters
import SafariServices

public protocol EmotionsViewControllerComposer: AnyObject {
    var logEventViewController: LogEventViewController { get }
    var appearanceSettingsViewController: SettingsViewController { get }

    func emotionsViewController(router: EmotionsGroupsRouter, emotions: [String]) -> EmotionsGroupsViewController
    func appInfoViewController(router: AppInfoRouter) -> SettingsViewController
    func privacySettingsViewController(router: PrivacySettingsRouter) -> SettingsViewController
    func notificationsSettingsViewController(router: NotificationsSettingsRouter) -> NotificationSettingsViewController
    func reminderViewController(router: ReminderRouter) -> ReminderViewController
    func trendsViewController(router: TrendsRouter) -> TrendsViewController
    func emotionEventsViewController(router: EmotionEventsRouter) -> EmotionEventsViewController
    func deletedEventsViewController(router: EmotionEventsRouter) -> EmotionEventsViewController

    func editEventNameViewController(
        router: EventNameRouter,
        name: String,
        details: String?,
        date: Date,
        selectedEmotions: [String],
        color: String
    ) -> EventNameViewController
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
        selectedIndex = 0
    }

    public func routeDeleted() {
        let controller = composer.deletedEventsViewController(router: self)
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true)
    }

    public func routeClose() {
        dismiss(animated: true)
    }

    public func route(shareText: String) {
        let controller = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(controller, animated: true)
    }

    public func route(editEvent: EmotionEventsPresenterObjects.EventsGroup.Event, date: Date) {
        let controller = composer.editEventNameViewController(
            router: self,
            name: editEvent.name,
            details: editEvent.details,
            date: date,
            selectedEmotions: editEvent.emotions.map(\.name),
            color: editEvent.color.hex
        )
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isModalInPresentation = true
        present(navigationController, animated: true)
    }
}

extension EmotionsViewController: EventNameRouter, ReminderRouter {
    public func routeCancel() {
        topPresentedViewController.dismiss(animated: true)
    }

    public func routeEvents() {
        dismiss(animated: true)
    }

    public func routeEdit(emotions: [String]) {
        let controller = UINavigationController(rootViewController: composer.emotionsViewController(router: self, emotions: emotions))
        topPresentedViewController.present(controller, animated: true)
    }
}

extension  EmotionsViewController: EmotionsGroupsRouter {
    public func routeEventName(selectedEmotions: [String], color: String) {
        let navigation = topPresentedViewController.presentingViewController as? UINavigationController
        let controller = navigation?.viewControllers.first as? EventNameViewController
        controller?.set(emotions: selectedEmotions, color: color)
        topPresentedViewController.dismiss(animated: true)
    }

    public func routeNotFound() {
        fatalError()
    }
}

extension EmotionsViewController: AppInfoRouter, PrivacySettingsRouter, LogEventRouter {
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

    public func routePrivacySettings() {
        let settings = composer.privacySettingsViewController(router: self)
        let navigation = (selectedViewController as? UINavigationController)
        navigation?.pushViewController(settings, animated: true)
    }

    public func routeAppearanceSettings() {
        let settings = composer.appearanceSettingsViewController
        let navigation = (selectedViewController as? UINavigationController)
        navigation?.pushViewController(settings, animated: true)
    }

    public func routeNotificationsSettings() {
        let settings = composer.notificationsSettingsViewController(router: self)
        let navigation = (selectedViewController as? UINavigationController)
        navigation?.pushViewController(settings, animated: true)
    }
}

extension EmotionsViewController: NotificationsSettingsRouter {
    public func routeAddReminder() {
        let reminder = composer.reminderViewController(router: self)
        let navigation = UINavigationController(rootViewController: reminder)
        present(navigation, animated: true)
    }
}

extension EmotionsViewController: EmotionsPresenterOutput {
    public func showEmotions() {
        viewControllers = [
            composer.logEventViewController,
            UINavigationController(rootViewController: composer.emotionEventsViewController(router: self)),
            composer.trendsViewController(router: self),
            UINavigationController(rootViewController: composer.appInfoViewController(router: self))
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
