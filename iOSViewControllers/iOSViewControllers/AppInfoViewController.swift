import UIKit
import Presenters

fileprivate extension UITableViewCell {
    static let reuseIdentifier = String(describing: UITableViewCell.self)
}

public class AppInfoViewController: UITableViewController {

    // MARK: - UIViewController

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.eventViewReady()
    }

    // MARK: - UITableViewController

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return sections?.count ?? 0
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections?[section].rows.count ?? 0
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = sections?[indexPath.section].rows[indexPath.row].title
        return cell
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections?[section].title
    }

    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections?[section].subtitle
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.event(selectIndexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private var sections: [AppInfoPresenterObjects.Section]? {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - Public

    public var presenter: AppInfoPresenter!

    public init() {
        super.init(style: .insetGrouped)
        let tabBarIcon = UIImage(named: "AppInfoTabBarIcon", in: Bundle(for: AppInfoViewController.self), with: nil)
        tabBarItem = UITabBarItem(title: "", image: tabBarIcon, selectedImage: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
    }
}

extension AppInfoViewController: AppInfoPresenterOutput {
    public func show(sections: [AppInfoPresenterObjects.Section]) {
        self.sections = sections
    }
}
