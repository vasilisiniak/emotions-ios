import UIKit
import iOSControls

extension EmotionEventsViewController {

    final class Cell: UITableViewCell {

        // MARK: - UITableViewCell

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: Cell.reuseIdentifier)
            separatorInset = .zero
            selectionStyle = .none
            addSubviews()
            makeConstraints()
        }

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private

        private func addSubviews() {
            contentView.addSubview(nameLabel)
            contentView.addSubview(detailsLabel)
            contentView.addSubview(timeLabel)
            contentView.addSubview(shareButton)
            contentView.addSubview(emotionsLabel)
        }

        private func makeConstraints() {
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            detailsLabel.translatesAutoresizingMaskIntoConstraints = false
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            shareButton.translatesAutoresizingMaskIntoConstraints = false
            emotionsLabel.translatesAutoresizingMaskIntoConstraints = false

            timeLabel.setContentHuggingPriority(.required, for: .horizontal)
            timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

            NSLayoutConstraint.activate([
                nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
                nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
                nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
                nameLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor),
                nameLabel.leadingAnchor.constraint(equalTo: emotionsLabel.leadingAnchor),

                detailsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
                detailsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                detailsLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

                timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
                timeLabel.leadingAnchor.constraint(equalTo: emotionsLabel.trailingAnchor),

                shareButton.rightAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: 2),
                shareButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),

                emotionsLabel.topAnchor.constraint(greaterThanOrEqualTo: nameLabel.bottomAnchor, constant: 10),
                emotionsLabel.topAnchor.constraint(greaterThanOrEqualTo: detailsLabel.bottomAnchor),
                emotionsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
            ])
        }

        // MARK: - Internal

        static let reuseIdentifier = String(describing: UITableViewCell.self)

        let nameLabel: UILabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = .preferredFont(forTextStyle: .headline)
            $0.numberOfLines = 0
        }

        let detailsLabel: PaddedLabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = .preferredFont(forTextStyle: .body)
            $0.numberOfLines = 0
            $0.textInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        }

        let timeLabel: UILabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = .preferredFont(forTextStyle: .subheadline)
        }

        let shareButton: UIButton = create {
            let image = UIImage(named: "ShareIcon", in: Bundle(for: Cell.self), with: nil)
            $0.setImage(image, for: .normal)
            $0.tintColor = UIColor(named: "ShareIconColor", in: Bundle(for: Cell.self), compatibleWith: nil)
        }

        let emotionsLabel: UILabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = .preferredFont(forTextStyle: .footnote)
            $0.numberOfLines = 0
        }

        var extended = false {
            didSet {
                [nameLabel, detailsLabel, emotionsLabel].forEach {
                    $0.numberOfLines = (extended ? 0 : 1)
                }
            }
        }
    }
}
