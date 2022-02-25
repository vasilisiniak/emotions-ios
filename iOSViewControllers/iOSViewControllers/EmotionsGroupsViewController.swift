import UIKit
import Presenters

fileprivate extension UITableViewCell {
    static let reuseIdentifier = String(describing: UITableViewCell.self)
}

public final class EmotionsGroupsViewController: UIViewController {

    private enum Section: Int, CaseIterable {
        case emotions
        case notFound
    }

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter.eventViewReady()
    }

    public override func loadView() {
        view = emotionsGroupsView
    }

    // MARK: - Private

    private var color: UIColor?
    private var observer: AnyObject?
    private var isUpdating = false

    private var emotions: [EmotionsGroupsPresenterObjects.Emotion] = [] {
        didSet {
            guard !isUpdating else { return }

            emotionsGroupsView.tableView.reloadData()
            emotionsGroupsView.tableView.flashScrollIndicators()

            emotionsGroupsView.collectionView.reloadData()
            emotionsGroupsView.collectionView.flashScrollIndicators()

            guard emotionsGroupsView.tableView.numberOfSections > 0 else { return }
            guard emotionsGroupsView.tableView.numberOfRows(inSection: 0) > 0 else { return }

            emotionsGroupsView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            emotionsGroupsView.collectionView.setContentOffset(.zero, animated: true)
        }
    }

    private var notFoundText: String? {
        didSet {
            emotionsGroupsView.tableView.reloadData()
            emotionsGroupsView.collectionView.reloadData()
        }
    }

    private var selectedNames: [String] = []

    private lazy var emotionsGroupsView: View = EmotionsGroupsViewController.create {
        $0.leftSwipeGestureRecognizer.addTarget(self, action: #selector(onLeftSwipe))
        $0.rightSwipeGestureRecognizer.addTarget(self, action: #selector(onRightSwipe))

        $0.tableView.dataSource = self
        $0.tableView.delegate = self
        $0.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)

        $0.collectionView.dataSource = self
        $0.collectionView.delegate = self
        $0.collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)

        $0.layout.minimumInteritemSpacing = 5

        $0.segmentedControl.addAction(UIAction { [weak self] in
            self?.onIndexChange($0)
        }, for: .valueChanged)

        let name = UIContentSizeCategory.didChangeNotification
        observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
            self?.emotionsGroupsView.collectionView.reloadData()
        }
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

extension EmotionsGroupsViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .emotions: return emotions.count
        case .notFound: return 1
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell

        switch Section(rawValue: indexPath.section)! {
        case .emotions:
            let emotion = emotions[indexPath.row].name
            let color = UIColor(hex: emotions[indexPath.row].color)
            let selected = selectedNames.contains(emotion)

            cell.backgroundColor = selected ? color : .clear
            cell.layer.borderColor = color.cgColor
            cell.text.textColor = selected ? color.text : .label
            cell.text.text = emotion
        case .notFound:
            cell.backgroundColor = .clear
            cell.layer.borderColor = color?.withAlphaComponent(0.5).cgColor
            cell.text.textColor = .label.withAlphaComponent(0.5)
            cell.text.text = notFoundText
        }

        return cell
    }
}

extension EmotionsGroupsViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .emotions: presenter.event(select: emotions[indexPath.row].name)
        case .notFound: presenter.eventNotFound()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard Section(rawValue: indexPath.section) == .emotions else { return nil }
        presenter.eventWillShowInfo(emotion: emotions[indexPath.row].name)
        let meaning = emotions[indexPath.row].meaning
        let cell = collectionView.cellForItem(at: indexPath)! as! Cell
        return UIContextMenuConfiguration(identifier: nil) {
            Menu(title: cell.text.text!, text: meaning, color: cell.text.textColor, width: collectionView.bounds.size.width - 50) { [weak self] in
                self?.presenter.eventDidHideInfo()
            }
        }
    }
}

extension EmotionsGroupsViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .emotions: return emotions.count
        case .notFound: return 1
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)

        switch Section(rawValue: indexPath.section)! {
        case .emotions:
            let emotion = emotions[indexPath.row].name
            let color = UIColor(hex: emotions[indexPath.row].color)
            let selected = selectedNames.contains(emotion)

            cell.textLabel?.textColor = cell.textLabel?.textColor?.withAlphaComponent(1)
            cell.textLabel?.text = emotion
            cell.accessoryType = selected ? .checkmark : .none
            cell.accessoryView?.alpha = 1
            cell.selectionStyle = .none
            cell.backgroundColor = selected ? color.withAlphaComponent(0.5) : .clear
        case .notFound:
            cell.textLabel?.textColor = cell.textLabel?.textColor?.withAlphaComponent(0.2)
            cell.textLabel?.text = notFoundText
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView?.alpha = 0.2
            cell.selectionStyle = .gray
            cell.backgroundColor = .clear
        }

        return cell
    }
}

extension EmotionsGroupsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .emotions:
            presenter.event(select: emotions[indexPath.row].name)
        case .notFound:
            tableView.deselectRow(at: indexPath, animated: true)
            presenter.eventNotFound()
        }
    }

    public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard Section(rawValue: indexPath.section) == .emotions else { return nil }
        presenter.eventWillShowInfo(emotion: emotions[indexPath.row].name)
        let meaning = emotions[indexPath.row].meaning
        let cell = tableView.cellForRow(at: indexPath)!
        return UIContextMenuConfiguration(identifier: nil) {
            Menu(title: cell.textLabel!.text!, text: meaning, color: cell.textLabel!.textColor, width: tableView.bounds.size.width - 50) { [weak self] in
                self?.presenter.eventDidHideInfo()
            }
        }
    }
}

extension EmotionsGroupsViewController: EmotionsGroupsPresenterOutput {
    public func show(share: UIActivityItemSource) {
        let activityViewController = UIActivityViewController(activityItems: [share], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
        present(activityViewController, animated: true)
    }

    public func show(shareAlertMessage: String, okButton: String, cancelButton: String) {
        let alert = UIAlertController(title: shareAlertMessage, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okButton, style: .default, handler: { [weak self] _ in
            self?.presenter.eventShare()
        }))
        alert.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: { [weak self] _ in
            self?.presenter.eventCancelShare()
        }))
        present(alert, animated: true)
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

    public func show(notFound: String) {
        notFoundText = notFound
    }

    public func show(clearButton: String) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: clearButton) { [weak self] in self?.onClear() }
    }

    public func show(nextButton: String) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nextButton) { [weak self] in self?.onNext() }
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
        let changes = { [emotionsGroupsView] in
            self.selectedNames = selectedNames
            self.emotions = emotions
            self.color = color

            UIView.animate(withDuration: 0.3) {
                emotionsGroupsView.segmentedControlBackground.backgroundColor = color.withAlphaComponent(0.2)
                emotionsGroupsView.tableView.backgroundColor = color.withAlphaComponent(0.2)
                emotionsGroupsView.collectionView.backgroundColor = color.withAlphaComponent(0.2)
            }
        }

        guard !self.emotions.isEmpty else {
            changes()
            return
        }

        let old: [Int]
        let new: [Int]

        switch (self.selectedNames.count - selectedNames.count) {
        case 1:
            let removed = self.selectedNames.first { !selectedNames.contains($0) }!
            old = [self.emotions.firstIndex { $0.name == removed }!]
            new = emotions.firstIndex { $0.name == removed }.map { [$0] } ?? []
        case -1:
            let added = selectedNames.first { !self.selectedNames.contains($0) }!
            old = [self.emotions.firstIndex { $0.name == added }!]
            new = [emotions.firstIndex { $0.name == added }!]
        case self.selectedNames.count:
            old = Array(0..<self.selectedNames.count)
            new = self.selectedNames.compactMap { name in emotions.firstIndex { $0.name == name } }
        default:
            old = []
            new = []
        }

        guard !old.isEmpty else {
            changes()
            return
        }

        guard emotionsGroupsView.tableView.isHidden else {
            func update(_ delete: [IndexPath], _ insert: [IndexPath]) {
                isUpdating = true
                emotionsGroupsView.tableView.beginUpdates()
                changes()
                emotionsGroupsView.tableView.deleteRows(at: delete, with: .left)
                emotionsGroupsView.tableView.insertRows(at: insert, with: .right)
                emotionsGroupsView.tableView.endUpdates()
                isUpdating = false
            }

            func swap(_ old: IndexPath, _ new: IndexPath) {
                isUpdating = true
                emotionsGroupsView.tableView.beginUpdates()
                changes()
                emotionsGroupsView.tableView.moveRow(at: old, to: new)
                emotionsGroupsView.tableView.endUpdates()
                emotionsGroupsView.tableView.reloadRows(at: [new], with: .automatic)
                isUpdating = false
            }

            if old.count == 1 && new.count == 1 {
                swap(IndexPath(row: old.first!, section: 0), IndexPath(row: new.first!, section: 0))
            }
            else {
                update(old.map { IndexPath(row: $0, section: 0) }, new.map { IndexPath(row: $0, section: 0) })
            }

            emotionsGroupsView.collectionView.reloadData()

            return
        }

        func update(_ delete: [IndexPath], _ insert: [IndexPath]) {
            isUpdating = true
            emotionsGroupsView.collectionView.performBatchUpdates {
                changes()
                emotionsGroupsView.collectionView.deleteItems(at: delete)
                emotionsGroupsView.collectionView.insertItems(at: insert)
            }
            completion: { [emotionsGroupsView] _ in
                emotionsGroupsView.collectionView.reloadData()
            }
            isUpdating = false
        }

        func swap(_ old: IndexPath, _ new: IndexPath) {
            isUpdating = true
            emotionsGroupsView.collectionView.performBatchUpdates {
                changes()
                emotionsGroupsView.collectionView.moveItem(at: old, to: new)
            }
            completion: { [emotionsGroupsView] _ in
                emotionsGroupsView.collectionView.reloadData()
            }
            isUpdating = false
        }

        if old.count == 1 && new.count == 1 {
            swap(IndexPath(row: old.first!, section: 0), IndexPath(row: new.first!, section: 0))
        }
        else {
            update(old.map { IndexPath(row: $0, section: 0) }, new.map { IndexPath(row: $0, section: 0) })
        }

        emotionsGroupsView.tableView.reloadData()
    }

    public func show(message: String, button: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .default))
        present(alert, animated: true)
    }

    public func show(legacy: Bool) {
        emotionsGroupsView.tableView.isHidden = !legacy
        emotionsGroupsView.collectionView.isHidden = legacy
    }
}
