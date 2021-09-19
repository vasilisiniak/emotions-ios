import UIKit
import Presenters
import iOSControls

public final class EmotionEventsViewController: UIViewController {

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layoutSubviews()
        noDataView.isHidden = true
        noDataView.button.addAction(UIAction(handler: onAddTap), for: .touchUpInside)
        presenter.eventViewReady()
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private var isUpdating = false
    private let noDataView = NoDataView()

    private var eventsGroups: [EmotionEventsPresenterObjects.EventsGroup] = [] {
        didSet {
            if !isUpdating {
                tableView.reloadData()
            }
        }
    }

    private lazy var tableView: UITableView = EmotionEventsViewController.create {
        $0.dataSource = self
        $0.delegate = self
        $0.register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
    }

    private func layoutSubviews() {
        view.addSubview(tableView)
        view.addSubview(noDataView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        noDataView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noDataView.topAnchor.constraint(equalTo: view.topAnchor),
            noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func onAddTap(action: UIAction) {
        presenter.eventAddTap()
    }

    private func delete(indexPath: IndexPath) {
        isUpdating = true
        presenter.event(deleteIndexPath: indexPath)
        if tableView.numberOfRows(inSection: indexPath.section) == 1 {
            tableView.deleteSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        isUpdating = false
    }

    private func edit(indexPath: IndexPath) {
        presenter.event(editIndexPath: indexPath)
    }

    // MARK: - Public

    public var presenter: EmotionEventsPresenter!

    public init() {
        super.init(nibName: nil, bundle: nil)
        let tabBarIcon = UIImage(named: "EmotionEventsTabBarIcon", in: Bundle(for: LogEventViewController.self), with: nil)
        tabBarItem = UITabBarItem(title: "", image: tabBarIcon, selectedImage: nil)
    }
}

extension EmotionEventsViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return eventsGroups.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsGroups[section].events.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        let event = eventsGroups[indexPath.section].events[indexPath.row]
        cell.nameLabel.text = event.name
        cell.timeLabel.text = event.timeString
        cell.emotionsLabel.text = event.emotions
        cell.backgroundColor = .systemBackground
        cell.contentView.backgroundColor = event.color.withAlphaComponent(0.2)
        cell.shareButton.addAction(UIAction(handler: { [weak self]_ in
            self?.presenter.event(shareIndexPath: indexPath)
        }), for: .touchUpInside)
        return cell
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: presenter.deleteTitle) { [weak self] (action, view, completion) in
            self?.delete(indexPath: indexPath)
            completion(true)
        }

        let editAction = UIContextualAction(style: .normal, title: presenter.editTitle) { [weak self] (action, view, completion) in
            self?.edit(indexPath: indexPath)
            completion(true)
        }
        editAction.backgroundColor = .systemYellow

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

extension EmotionEventsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = PaddedLabel()
        let font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .boldSystemFont(ofSize: font.pointSize))
        label.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        label.backgroundColor = .systemBackground
        label.text = eventsGroups[section].dateString
        return label
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

extension EmotionEventsViewController: EmotionEventsPresenterOutput {
    public func show(noDataHidden: Bool) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.noDataView.alpha = noDataHidden ? 0 : 1
        } completion: { [weak self] _ in
            self?.noDataView.isHidden = noDataHidden
        }
    }

    public func show(noDataText: String, button: String) {
        noDataView.label.text = noDataText
        noDataView.button.setTitle(button, for: .normal)
    }

    public func show(eventsGroups: [EmotionEventsPresenterObjects.EventsGroup]) {
        self.eventsGroups = eventsGroups
    }

    public func show(message: String, button: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
