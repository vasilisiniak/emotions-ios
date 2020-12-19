import UIKit
import Presenters

public final class EmotionEventsViewController: UIViewController {
    
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
            tableView.reloadData()
        }
    }
    
    private lazy var tableView: UITableView = EmotionEventsViewController.create {
        $0.dataSource = self
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
        return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return eventsGroups[section].dateString
    }
}

extension EmotionEventsViewController: EmotionEventsPresenterOutput {
    public func show(eventsGroups: [EmotionEventsPresenterObjects.EventsGroup]) {
        self.eventsGroups = eventsGroups
    }
}
