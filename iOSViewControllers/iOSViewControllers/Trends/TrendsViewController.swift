import UIKit
import iOSControls
import Presenters

public final class TrendsViewController: UIViewController {

    // MARK: - UIViewController

    public override func loadView() {
        view = trendsView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        trendsView.noDataView.isHidden = true
        trendsView.noDataView.button.addAction(UIAction { [presenter] _ in presenter?.eventAddTap() }, for: .touchUpInside)

        trendsView.dateRangePicker.addAction(UIAction { [weak self, trendsView] _ in
            self?.presenter.event(selectedRange: trendsView.dateRangePicker.selectedRange)
        }, for: .valueChanged)

        presenter.eventViewReady()
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private let trendsView = View()

    // MARK: - Public

    public var presenter: TrendsPresenter!

    public init() {
        super.init(nibName: nil, bundle: nil)
        let tabBarIcon = UIImage(named: "TrendsTabBarIcon", in: Bundle(for: TrendsViewController.self), with: nil)
        tabBarItem = UITabBarItem(title: "", image: tabBarIcon, selectedImage: nil)
    }
}

extension TrendsViewController: TrendsPresenterOutput {
    public func show(noDataHidden: Bool) {
        trendsView.noDataView.isHidden = noDataHidden
    }

    public func show(noDataText: String, button: String?) {
        trendsView.noDataView.label.text = noDataText
        trendsView.noDataView.button.setTitle(button, for: .normal)
        trendsView.noDataView.button.isHidden = (button == nil)
    }

    public func show(colors: [UIColor]) {
        trendsView.gradientView.colors = colors
    }

    public func show(stats: [TrendsPresenterObjects.Stat]) {
        trendsView.histogram.items = stats.map { Histogram.Item(name: $0.name, color: $0.color, value: $0.frequency) }
    }

    public func show(range: (min: Date, max: Date)) {
        trendsView.dateRangePicker.range = range
    }

    public func show(selectedRange: (min: Date?, max: Date?)) {
        trendsView.dateRangePicker.selectedRange = selectedRange
    }

    public func show(rangeTitle: String) {
        trendsView.dateRangePicker.titleLabel.text = rangeTitle
    }

    public func show(rangeHidden: Bool) {
        trendsView.dateRangePicker.isHidden = rangeHidden
    }
}
