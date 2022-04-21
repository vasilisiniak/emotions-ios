import UIKit
import Presenters

fileprivate extension UIAction.Identifier {
    static let range = Self(rawValue: "ReminderViewController.range")
}

public final class ReminderViewController: UITableViewController {

    private enum Section: Int, CaseIterable {
        case range
        case interval
    }

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = presenter.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: presenter.cancel, handler: { [weak self] in self?.presenter.eventCancel() })
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: presenter.add, handler: { [weak self] in self?.presenter.eventCreate() })

        tableView.register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
    }

    // MARK: - UITableViewDataSource

    public override func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell

        switch Section(rawValue: indexPath.section)! {
        case .range:
            rangeCell = cell

            cell.range.limits.left.text = presenter.rangeLimit.0
            cell.range.limits.right.text = presenter.rangeLimit.1
            cell.range.value = presenter.range

            cell.range.addAction(UIAction(identifier: .range, handler: { [weak self] _ in
                guard let change = self?.rangeCell?.range.value else { return }
                self?.presenter.event(range: change)
            }), for: .valueChanged)
            
        case .interval:
            intervalCell = cell

            cell.range.limits.left.text = presenter.intervalLimit.0
            cell.range.limits.right.text = presenter.intervalLimit.1
            cell.range.value = presenter.interval

            cell.range.addAction(UIAction(identifier: .range, handler: { [weak self] _ in
                guard let change = self?.intervalCell?.range.value else { return }
                self?.presenter.event(interval: change)
            }), for: .valueChanged)
        }

        return cell
    }

    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .range: return presenter.rangeInfo
        case .interval: return presenter.intervalInfo
        }
    }

    // MARK: - Private

    private var rangeCell: Cell?
    private var intervalCell: Cell?

    // MARK: - Public

    public var presenter: ReminderPresenter!
}

extension ReminderViewController: ReminderPresenterOutput {
    public func show(range: String) {
        rangeCell?.label.text = range
    }

    public func show(interval: String) {
        intervalCell?.label.text = interval
    }
}
