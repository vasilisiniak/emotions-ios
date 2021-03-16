import UIKit
import Presenters

public protocol EmotionsViewControllerComposer: class {
    var logEventViewController: LogEventViewController { get }
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
        selectedIndex = 0
    }

    public func route(shareText: String) {
        let controller = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }
}

extension EmotionsViewController: EmotionsPresenterOutput {
    public func showEmotions() {
        viewControllers = [
            composer.logEventViewController,
            composer.emotionEventsViewController(router: self),
            composer.trendsViewController(router: self)
        ]
    }
}
