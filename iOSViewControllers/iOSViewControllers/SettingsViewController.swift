import UIKit
import Presenters

fileprivate extension UITableViewCell {
    static let reuseIdentifier = String(describing: UITableViewCell.self)
}

public class SettingsViewController: UIViewController {

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = presenter.title

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.eventViewReady()
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private var sections: [SettingsPresenterSection]?

    // MARK: - Public

    public var presenter: SettingsPresenter!

    public init() {
        super.init(nibName: nil, bundle: nil)
        let tabBarIcon = UIImage(named: "AppInfoTabBarIcon", in: Bundle(for: SettingsViewController.self), with: nil)
        tabBarItem = UITabBarItem(title: "", image: tabBarIcon, selectedImage: nil)
    }
}

extension SettingsViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections?[section].rows.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        let row = sections?[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = row?.title

        switch row!.style {
        case .disclosure:
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .gray
        case .switcher:
            let switcher = UISwitch(frame: .zero, primaryAction: UIAction { [weak self] in
                let value = ($0.sender as? UISwitch)?.isOn == true
                self?.presenter.event(switcher: value, indexPath: indexPath)
            })
            switcher.isOn = (row?.value as? Bool) == true
            cell.accessoryView = switcher
            cell.accessoryType = .none
            cell.selectionStyle = .none
        }

        cell.textLabel?.text = sections?[indexPath.section].rows[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .gray

        return cell
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections?[section].title
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections?[section].subtitle
    }
}

extension SettingsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard sections?[indexPath.section].rows[indexPath.row].style == .disclosure else { return }
        presenter.event(selectIndexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController: SettingsPresenterOutput {
    public func show(sections: [SettingsPresenterSection], update: [IndexPath]) {
        self.sections = sections

        guard !update.isEmpty, view.window != nil else {
            tableView.reloadData()
            return
        }

        tableView.reloadRows(at: update, with: .automatic)
    }

    public func show(message: String, okButton: String, infoButton: String, okHandler: @escaping () -> ()) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okButton, style: .default))
        alert.addAction(UIAlertAction(title: infoButton, style: .default, handler: { _ in okHandler() }))
        present(alert, animated: true)
    }
}
