import UIKit
import Presenters

public protocol LogEventViewControllerConfigurator {
    func configure(emotionsViewController: EmotionsGroupsViewController, router: EmotionsGroupsRouter)
    func configure(eventNameViewController: EventNameViewController, router: EventNameRouter, selectedEmotions: [String])
}

public class LogEventViewController: UINavigationController {
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        presenter.eventViewReady()
    }
    
    // MARK: - Public
    
    public var presenter: LogEventPresenter!
    public var configurator: LogEventViewControllerConfigurator!
}

extension LogEventViewController: UIGestureRecognizerDelegate {}

extension LogEventViewController: EmotionsGroupsRouter {
    public func routeEventName(selectedEmotions: [String]) {
        let eventNameViewController = EventNameViewController()
        configurator.configure(eventNameViewController: eventNameViewController, router: self, selectedEmotions: selectedEmotions)
        pushViewController(eventNameViewController, animated: true)
    }
}

extension LogEventViewController: EventNameRouter {
    public func routeBack() {
        popViewController(animated: true)
    }
}

extension LogEventViewController: LogEventPresenterOutput {
    public func showEmotions() {
        let emotionsViewController = EmotionsGroupsViewController()
        configurator.configure(emotionsViewController: emotionsViewController, router: self)
        pushViewController(emotionsViewController, animated: true)
    }
}
