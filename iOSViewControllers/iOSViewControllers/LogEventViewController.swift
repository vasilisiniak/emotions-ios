import UIKit
import Presenters

public protocol LogEventViewControllerConfigurator {
    func configure(emotionsViewController: EmotionsGroupsViewController, router: EmotionsGroupsRouter)
}

public class LogEventViewController: UINavigationController {
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter.eventViewReady()
    }
    
    // MARK: - Public
    
    public var presenter: LogEventPresenter!
    public var configurator: LogEventViewControllerConfigurator!
}

extension LogEventViewController: EmotionsGroupsRouter {
    public func routeEventName() {
        pushViewController(UIViewController(), animated: true)
    }
}

extension LogEventViewController: LogEventPresenterOutput {
    public func showEmotions() {
        let emotionsViewController = EmotionsGroupsViewController()
        configurator.configure(emotionsViewController: emotionsViewController, router: self)
        pushViewController(emotionsViewController, animated: true)
    }
}
