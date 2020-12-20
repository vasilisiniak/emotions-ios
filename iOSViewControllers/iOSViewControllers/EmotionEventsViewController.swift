import UIKit
import Presenters
import iOSControls

public final class EmotionEventsViewController: UIViewController {
    
    // MARK: - Private
    
    private var isUpdating = false
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layoutTableView()
        presenter.eventViewReady()
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
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
    
    private func layoutTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        return cell
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        isUpdating = true
        presenter.delete(indexPath: indexPath)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        isUpdating = false
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
    public func show(eventsGroups: [EmotionEventsPresenterObjects.EventsGroup]) {
        self.eventsGroups = eventsGroups
    }
}
