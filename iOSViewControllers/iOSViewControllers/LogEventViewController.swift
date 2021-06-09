import UIKit
import Presenters

public protocol LogEventViewControllerComposer: AnyObject {
    func emotionsViewController(router: EmotionsGroupsRouter) -> EmotionsGroupsViewController
    func eventNameViewController(router: EventNameRouter, selectedEmotions: [String], color: String) -> EventNameViewController
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
    public func routeEventName(selectedEmotions: [String], color: String) {
        let eventNameViewController = composer.eventNameViewController(router: self, selectedEmotions: selectedEmotions, color: color)
        pushViewController(eventNameViewController, animated: true)
    }
}

extension LogEventViewController: EventNameRouter {
    public func routeEmotions() {
        let emotionsViewController = composer.emotionsViewController(router: self)
        setViewControllers([emotionsViewController], animated: true)
        presenter.eventEventCreated()
    }
    
    public func routeBack() {
        popViewController(animated: true)
    }
}

extension LogEventViewController: LogEventPresenterOutput {
    public func show(message: String, button: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    public func showWidgetAlert(message: String, okButton: String, infoButton: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okButton, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: infoButton, style: .default, handler: { [weak self] _ in
            self?.presenter.eventWidgetInfo()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    public func showEmotions() {
        let emotionsViewController = composer.emotionsViewController(router: self)
        pushViewController(emotionsViewController, animated: true)
    }
}
