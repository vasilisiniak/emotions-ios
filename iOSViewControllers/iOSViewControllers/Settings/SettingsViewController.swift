import UIKit
import Presenters

fileprivate extension UITableViewCell {
    static let defaultReuseIdentifier = String(describing: UITableViewCell.self) + "default"
    static let optionReuseIdentifier = String(describing: UITableViewCell.self) + "value1"
}

fileprivate extension SettingsPresenterRowStyle {
    var identifier: String {
        switch self {
        case .disclosure: return UITableViewCell.defaultReuseIdentifier
        case .switcher: return UITableViewCell.defaultReuseIdentifier
        case .option: return UITableViewCell.optionReuseIdentifier
        }
    }

    var style: UITableViewCell.CellStyle {
        switch self {
        case .disclosure: return .default
        case .switcher: return .default
        case .option: return .value1
        }
    }
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
        let row = sections![indexPath.section].rows[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: row.style.identifier)
            ?? UITableViewCell(style: row.style.style, reuseIdentifier: row.style.identifier)

        cell.textLabel?.text = row.title

        switch row.style {
        case .disclosure:
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .gray
        case .switcher:
            let switcher = UISwitch(frame: .zero, primaryAction: UIAction { [weak self] in
                let value = ($0.sender as? UISwitch)?.isOn == true
                self?.presenter.event(switcher: value, indexPath: indexPath)
            })
            switcher.isOn = (row.value as? Bool) == true
            cell.accessoryView = switcher
            cell.accessoryType = .none
            cell.selectionStyle = .none
        case .option:
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .gray
            cell.detailTextLabel?.text = (row.value as? String)
        }

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
        switch sections?[indexPath.section].rows[indexPath.row].style {
        case .option, .disclosure:
            presenter.event(selectIndexPath: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
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

    public func show(message: String, okButton: String, infoButton: String?, okHandler: (() -> ())?) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okButton, style: .default))
        if let infoButton = infoButton, let okHandler = okHandler {
            alert.addAction(UIAlertAction(title: infoButton, style: .default, handler: { _ in okHandler() }))
        }
        present(alert, animated: true)
    }

    public func show(options: [(String, () -> ())], cancel: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        options.forEach { name, handler in
            alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in handler() }))
        }
        alert.addAction(UIAlertAction(title: cancel, style: .cancel))
        present(alert, animated: true)
    }
}
