import UIKit
import Presenters

public protocol LogEventViewControllerComposer {
    func emotionsViewController(router: EmotionsGroupsRouter) -> EmotionsGroupsViewController
    func eventNameViewController(router: EventNameRouter, selectedEmotions: [String]) -> EventNameViewController
}

public class LogEventViewController: UINavigationController {
    
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
    public var composer: LogEventViewControllerComposer!
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        let tabBarIcon = UIImage(named: "LogEventTabBarIcon", in: Bundle(for: LogEventViewController.self), with: nil)
        tabBarItem = UITabBarItem(title: nil, image: tabBarIcon, selectedImage: nil)
    }
}

extension LogEventViewController: UIGestureRecognizerDelegate {}

extension LogEventViewController: EmotionsGroupsRouter {
    public func routeEventName(selectedEmotions: [String]) {
        let eventNameViewController = composer.eventNameViewController(router: self, selectedEmotions: selectedEmotions)
        pushViewController(eventNameViewController, animated: true)
    }
}

extension LogEventViewController: EventNameRouter {
    public func routeEmotions() {
        let emotionsViewController = composer.emotionsViewController(router: self)
        setViewControllers([emotionsViewController], animated: true)
    }
    
    public func routeBack() {
        popViewController(animated: true)
    }
}

extension LogEventViewController: LogEventPresenterOutput {
    public func showEmotions() {
        let emotionsViewController = composer.emotionsViewController(router: self)
        pushViewController(emotionsViewController, animated: true)
    }
}
