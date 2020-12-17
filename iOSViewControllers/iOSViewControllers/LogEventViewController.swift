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
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = ""
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private var emotionsViewController: EmotionsGroupsViewController {
        let emotionsViewController = EmotionsGroupsViewController()
        configurator.configure(emotionsViewController: emotionsViewController, router: self)
        return emotionsViewController
    }
    
    // MARK: - Public
    
    public var presenter: LogEventPresenter!
    public var configurator: LogEventViewControllerConfigurator!
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        let tabBarIcon = UIImage(named: "LogEventTabBarIcon", in: Bundle(for: LogEventViewController.self), with: nil)
        tabBarItem = UITabBarItem(title: nil, image: tabBarIcon, selectedImage: nil)
    }
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
    public func routeEmotions() {
        setViewControllers([emotionsViewController], animated: true)
    }
    
    public func routeBack() {
        popViewController(animated: true)
    }
}

extension LogEventViewController: LogEventPresenterOutput {
    public func showEmotions() {
        pushViewController(emotionsViewController, animated: true)
    }
}
