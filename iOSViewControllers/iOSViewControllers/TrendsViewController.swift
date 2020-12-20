import UIKit
import iOSControls
import Presenters

public final class TrendsViewController: UIViewController {
    
    // MARK: - UIViewController
    
    public override func loadView() {
        view = gradientView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter.eventViewReady()
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private let gradientView = GradientView()
    
    // MARK: - Public
    
    public var presenter: TrendsPresenter!
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        let tabBarIcon = UIImage(named: "TrendsTabBarIcon", in: Bundle(for: LogEventViewController.self), with: nil)
        tabBarItem = UITabBarItem(title: "", image: tabBarIcon, selectedImage: nil)
    }
}

extension TrendsViewController: TrendsPresenterOutput {
    public func show(colors: [UIColor]) {
        gradientView.colors = colors
    }
}
