import UIKit
import iOSControls
import Presenters

fileprivate extension UITableViewCell {
    static let defaultReuseIdentifier = String(describing: UITableViewCell.self) + "default"
    static let subtitleReuseIdentifier = String(describing: UITableViewCell.self) + "subtitle"
}

public final class NotificationSettingsViewController: UITableViewController {

    private enum Section: Int, CaseIterable {
        case enabled
        case reminders
        case add
    }

    // MARK: - Private

    private var enabled = false {
        didSet {
            if oldValue != enabled {
                tableView?.reloadSections(IndexSet(Section.allCases.map(\.rawValue)), with: .automatic)
            }
            else {
                tableView?.reloadSections(IndexSet([Section.reminders.rawValue]), with: .automatic)
            }
        }
    }

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = presenter.title
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.defaultReuseIdentifier)
        presenter.eventViewReady()
    }

    // MARK: - UITableViewDataSource

    public override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .enabled: return 1
        case .reminders: return presenter.reminders.count
        case .add: return enabled ? 1 : 0
        }
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .enabled:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.defaultReuseIdentifier, for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.text = presenter.notificationsTitle

            cell.accessoryView = {
                let switcher = UISwitch(frame: .zero, primaryAction: UIAction { [weak self] in
                    let value = ($0.sender as? UISwitch)?.isOn == true
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self?.presenter.event(enabled: value)
                })
                switcher.isOn = enabled
                return switcher
            }()

            return cell

        case .reminders:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.subtitleReuseIdentifier)
                ?? UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.subtitleReuseIdentifier)
            cell.selectionStyle = .none

            cell.textLabel?.text = presenter.reminders[indexPath.row].0
            cell.detailTextLabel?.text = presenter.reminders[indexPath.row].1

            return cell

        case .add:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.defaultReuseIdentifier, for: indexPath)
            cell.textLabel?.text = presenter.add
            cell.textLabel?.textAlignment = .center
            cell.accessoryView = nil
            return cell
        }
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .enabled: return nil
        case .reminders: return presenter.reminders.isEmpty ? nil : presenter.rules
        case .add: return nil
        }
    }

    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .enabled: return presenter.notificationsInfo
        case .reminders: return nil
        case .add: return nil
        }
    }

    // MARK: - UITableViewDelegate

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Section(rawValue: indexPath.section)! {
        case .enabled: break
        case .reminders: break
        case .add: presenter.eventAdd()
        }
    }

    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        presenter.event(delete: indexPath.row)
    }

    // MARK: - Public

    public var presenter: NotificationsSettingsPresenter!
}

extension NotificationSettingsViewController: NotificationsSettingsPresenterOutput {
    public func show(enabled: Bool) {
        self.enabled = enabled
    }

    public func show(denied: String, ok: String, settings: String) {
        let alert = UIAlertController(title: denied, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ok, style: .default))
        alert.addAction(UIAlertAction(title: settings, style: .default, handler: { [weak self] _ in
            self?.presenter.eventSettings()
        }))
        present(alert, animated: true)
    }

    public func show(info: String, ok: String) {
        let alert = UIAlertController(title: info, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ok, style: .default))
        present(alert, animated: true)
    }

    public func show(info: Bool) {
        navigationItem.rightBarButtonItem = !info ? nil : UIBarButtonItem(
            image: UIImage(named: "InfoIcon", in: Bundle(for: NotificationSettingsViewController.self), with: nil),
            primaryAction: UIAction { [presenter] _ in presenter?.eventInfo() }
        )
    }
}
