import UIKit
import iOSControls

extension ReminderViewController {

    final class Cell: UITableViewCell {

        // MARK: - UITableViewCell

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .default, reuseIdentifier: Cell.reuseIdentifier)

            separatorInset = .zero
            selectionStyle = .none
            backgroundColor = .groupedTableViewCellBackground

            label.text = " "

            contentView.addSubview(label)
            contentView.addSubview(range)

            label.translatesAutoresizingMaskIntoConstraints = false
            range.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),

                range.leadingAnchor.constraint(equalTo: label.leadingAnchor),
                range.trailingAnchor.constraint(equalTo: label.trailingAnchor),
                range.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 13),
                range.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
        }

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Internal

        let label: UILabel = create {
            $0.numberOfLines = 0
            $0.textColor = .label
            $0.font = .preferredFont(forTextStyle: .body)
            $0.adjustsFontForContentSizeCategory = true
        }

        let range = RangeControl()

        static let reuseIdentifier = String(describing: Cell.self)
    }
}
