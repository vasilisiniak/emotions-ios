import UIKit
import Presenters

fileprivate extension UITableViewCell {
    static let reuseIdentifier = String(describing: UITableViewCell.self)
}

public final class EmotionsGroupsViewController: UIViewController {
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter.eventViewReady()
    }
    
    public override func loadView() {
        view = emotionsGroupsView
    }
    
    // MARK: - Private
    
    private var emotions: [EmotionsGroupsPresenterObjects.Emotion] = [] {
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
        return emotions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = emotions[indexPath.row].name
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.accessoryType = selectedNames.contains(emotions[indexPath.row].name) ? .checkmark : .none
        return cell
    }
}

extension EmotionsGroupsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.event(select: emotions[indexPath.row].name)
    }
    
    public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let meaning = emotions[indexPath.row].meaning
        return UIContextMenuConfiguration(identifier: nil) {
            Menu(text: meaning, width: tableView.bounds.size.width - 50) { [weak self] in
                self?.presenter.eventDidHideInfo()
            }
        }
    }
}

extension EmotionsGroupsViewController: EmotionsGroupsPresenterOutput {
    public func show(share: UIActivityItemSource) {
        let activityViewController = UIActivityViewController(activityItems: [share], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
        present(activityViewController, animated: true, completion: nil)
    }

    public func show(shareAlertMessage: String, okButton: String, cancelButton: String) {
        let alert = UIAlertController(title: shareAlertMessage, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okButton, style: .default, handler: { [weak self] _ in
            self?.presenter.eventShare()
        }))
        alert.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: { [weak self] _ in
            self?.presenter.eventCancelShare()
        }))
        present(alert, animated: true, completion: nil)
    }

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
    
    public func show(selectedEmotionsNames: String, color: UIColor) {
        emotionsGroupsView.label.text = selectedEmotionsNames
        emotionsGroupsView.label.backgroundColor = color.withAlphaComponent(0.4)
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
    
    public func show(emotions: [EmotionsGroupsPresenterObjects.Emotion], selectedNames: [String], color: UIColor) {
        self.emotions = emotions
        self.selectedNames = selectedNames
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.emotionsGroupsView.segmenedControlBackground.backgroundColor = color.withAlphaComponent(0.2)
            self?.emotionsGroupsView.tableView.backgroundColor = color.withAlphaComponent(0.2)
        }
    }
    
    public func show(message: String, button: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
