import UIKit
import Presenters
import iOSControls

fileprivate extension UIAction.Identifier {
    static let share = Self(rawValue: "EmotionEventsViewController.share")
}

public final class EmotionEventsViewController: UIViewController {

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = presenter.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "InfoIcon", in: Bundle(for: EmotionEventsViewController.self), with: nil),
            primaryAction: UIAction { [presenter] _ in presenter?.eventInfoTap() }
        )

        layoutSubviews()

        noDataView.isHidden = true
        noDataView.button.addAction(UIAction { [presenter] _ in presenter?.eventAddTap() }, for: .touchUpInside)

        blurView.isHidden = true

        presenter.eventViewReady()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.eventViewWillAppear()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        appObservers = [
            NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
                self?.presenter.eventStartUnsafe()
            },
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
                self?.presenter.eventEndUnsafe()
            }
        ]

        presenter.eventViewDidAppear()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appObservers?.forEach { NotificationCenter.default.removeObserver($0) }
        appObservers = nil
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private var isUpdating = false
    private let noDataView = NoDataView()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

    private var appObservers: [NSObjectProtocol]?

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
        view.addSubview(blurView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        blurView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noDataView.topAnchor.constraint(equalTo: view.topAnchor),
            noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        let tabBarIcon = UIImage(named: "EmotionEventsTabBarIcon", in: Bundle(for: EmotionEventsViewController.self), with: nil)
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
        cell.detailsLabel.text = event.details
        cell.timeLabel.text = event.timeString
        cell.backgroundColor = .systemBackground
        cell.contentView.backgroundColor = event.color.withAlphaComponent(0.2)
        cell.expanded = presenter.expanded(indexPath)
        cell.emotions.removeAll()

        event.emotions.components(separatedBy: ", ")
            .map { Bubble.create($0, .red) }
            .forEach { cell.emotions.add(view: $0) }

        cell.shareButton.addAction(UIAction(identifier: .share) { [weak self, weak cell] _ in
            guard let cell = cell else { return }
            guard let indexPath = self?.tableView.indexPath(for: cell) else { return }
            self?.presenter.event(shareIndexPath: indexPath)
        }, for: .touchUpInside)

        return cell
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: presenter.deleteTitle) { [weak self] (_, _, completion) in
            self?.delete(indexPath: indexPath)
            completion(true)
        }

        let editAction = UIContextualAction(style: .normal, title: presenter.editTitle) { [weak self] (_, _, completion) in
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

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.event(tap: indexPath)
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

    public func show(blur: Bool) {
        guard blurView.isHidden != !blur else { return }

        if blur {
            blurView.isHidden = false
        }
        else {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn, .beginFromCurrentState]) { [blurView] in
                blurView.alpha = 0
            } completion: { [blurView] _ in
                blurView.isHidden = true
                blurView.alpha = 1
            }
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
        alert.addAction(UIAlertAction(title: button, style: .default))
        present(alert, animated: true)
    }

    public func showFaceIdAlert(message: String, okButton: String, infoButton: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okButton, style: .default))
        alert.addAction(UIAlertAction(title: infoButton, style: .default, handler: { [weak self] _ in
            self?.presenter.eventFaceIdInfo()
        }))
        present(alert, animated: true)
    }

    public func show(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
