import UIKit
import Presenters

fileprivate extension UITableViewCell {
    static let reuseIdentifier = String(describing: UITableViewCell.self)
}

public class EmotionsGroupsViewController: UIViewController {
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter.eventViewReady()
    }
    
    public override func loadView() {
        view = emotionsGroupsView
    }
    
    // MARK: - Private
    
    private var emotionNames: [String] = [] {
        didSet {
            emotionsGroupsView.tableView.reloadData()
        }
    }
    
    private var selectedNames: [String] = []
    
    private lazy var emotionsGroupsView: View = EmotionsGroupsViewController.create {
        $0.leftSwipeGestureRecognizer.addTarget(self, action: #selector(onLeftSwipe))
        $0.rightSwipeGestureRecognizer.addTarget(self, action: #selector(onRightSwipe))
        $0.tableView.dataSource = self
        $0.tableView.delegate = self
        $0.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        $0.segmentedControl.addAction(UIAction(handler: onIndexChange), for: .valueChanged)
    }
    
    @objc private func onLeftSwipe() {
        presenter.eventSwipeLeft()
    }
    
    @objc private func onRightSwipe() {
        presenter.eventSwipeRight()
    }
    
    private func onIndexChange(_: UIAction) {
        presenter.event(indexChange: emotionsGroupsView.segmentedControl.selectedSegmentIndex)
    }
    
    private func onClear() {
        presenter.eventClear()
    }
    
    private func onNext() {
        presenter.eventNext()
    }
    
    // MARK: - Public
    
    public var presenter: EmotionsGroupsPresenter!
}

extension EmotionsGroupsViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emotionNames.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = emotionNames[indexPath.row]
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.accessoryType = selectedNames.contains(emotionNames[indexPath.row]) ? .checkmark : .none
        return cell
    }
}

extension EmotionsGroupsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.event(select: emotionNames[indexPath.row])
    }
}

extension EmotionsGroupsViewController: EmotionsGroupsPresenterOutput {
    public func show(clearButtonEnabled: Bool) {
        navigationItem.leftBarButtonItem?.isEnabled = clearButtonEnabled
    }
    
    public func show(nextButtonEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = nextButtonEnabled
    }
    
    public func show(title: String) {
        self.title = title
    }
    
    public func show(clearButton: String) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: clearButton, handler: onClear)
    }
    
    public func show(nextButton: String) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nextButton, handler: onNext)
    }
    
    public func show(emotionIndex: Int, selectedNames: [String]) {
        self.selectedNames = selectedNames
        emotionsGroupsView.tableView.reloadRows(at: [IndexPath(row: emotionIndex, section: 0)], with: .automatic)
    }
    
    public func show(selectedEmotionsNames: String) {
        emotionsGroupsView.label.text = selectedEmotionsNames
        UIView.animate(withDuration: 0.15, animations: emotionsGroupsView.layoutIfNeeded)
    }
    
    public func show(groupNames: [String]) {
        groupNames.reversed().forEach {
            emotionsGroupsView.segmentedControl.insertSegment(withTitle: $0, at: 0, animated: false)
        }
        emotionsGroupsView.segmentedControl.selectedSegmentIndex = 0
    }
    
    public func show(selectedGroupIndex: Int) {
        emotionsGroupsView.segmentedControl.selectedSegmentIndex = selectedGroupIndex
    }
    
    public func show(emotionNames: [String], selectedNames: [String], color: UIColor) {
        self.emotionNames = emotionNames
        self.selectedNames = selectedNames
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.emotionsGroupsView.segmenedControlBackground.backgroundColor = color.withAlphaComponent(0.4)
            self?.emotionsGroupsView.tableView.backgroundColor = color.withAlphaComponent(0.4)
        }
    }
}
