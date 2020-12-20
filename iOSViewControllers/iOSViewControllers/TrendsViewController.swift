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
        layoutNoDataView()
        noDataView.isHidden = true
        noDataView.button.addAction(UIAction(handler: onAddTap), for: .touchUpInside)
        presenter.eventViewReady()
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private let gradientView = GradientView()
    private let noDataView = NoDataView()
    
    private func layoutNoDataView() {
        view.addSubview(noDataView)
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noDataView.topAnchor.constraint(equalTo: view.topAnchor),
            noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func onAddTap(action: UIAction) {
        presenter.eventAddTap()
    }
    
    // MARK: - Public
    
    public var presenter: TrendsPresenter!
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        let tabBarIcon = UIImage(named: "TrendsTabBarIcon", in: Bundle(for: LogEventViewController.self), with: nil)
        tabBarItem = UITabBarItem(title: "", image: tabBarIcon, selectedImage: nil)
    }
}

extension TrendsViewController: TrendsPresenterOutput {
    public func show(noDataHidden: Bool) {
        noDataView.isHidden = noDataHidden
    }
    
    public func show(noDataText: String, button: String) {
        noDataView.label.text = noDataText
        noDataView.button.setTitle(button, for: .normal)
    }
    
    public func show(colors: [UIColor]) {
        gradientView.colors = colors
    }
}
