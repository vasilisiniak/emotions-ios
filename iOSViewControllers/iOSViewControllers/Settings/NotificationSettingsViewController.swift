import UIKit
import Presenters

fileprivate extension UITableViewCell {
    static let identifier = String(describing: UITableViewCell.self)
}

public final class NotificationSettingsViewController: UITableViewController {

    private enum Section: Int, CaseIterable {
        case enabled
        case rules
    }

    // MARK: - Private

    private var enabled = false {
        didSet { tableView?.reloadSections(IndexSet([Section.enabled.rawValue]), with: .automatic) }
    }

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = presenter.title
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        presenter.eventViewReady()
    }

    // MARK: - UITableViewDataSource

    public override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .enabled: return 1
        case .rules: return 0
        }
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .enabled:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
            cell.textLabel?.text = presenter.notificationsTitle
            cell.accessoryView = {
                let switcher = UISwitch(frame: .zero, primaryAction: UIAction { [weak self] in
                    let value = ($0.sender as? UISwitch)?.isOn == true
                    self?.presenter.event(enabled: value)
                })
                switcher.isOn = enabled
                return switcher
            }()
            return cell

        case .rules: fatalError()
        }
    }

    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .enabled: return presenter.notificationsInfo
        case .rules: return nil
        }
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
}
