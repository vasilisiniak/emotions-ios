import UIKit
import iOSControls

extension EmotionEventsViewController {

    final class Cell: UITableViewCell {

        // MARK: - UITableViewCell

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .default, reuseIdentifier: Cell.reuseIdentifier)
            selectionStyle = .none
            addSubviews()
            makeConstraints()
            updateContentShadow()
        }

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - UITraitEnvironment

        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            updateContentShadow()
        }

        // MARK: - Private

        private func updateContentShadow() {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                content.layer.shadowOpacity = 0.3
                content.layer.shadowOffset = .zero
            }
            else {
                content.layer.shadowOpacity = 0.1
                content.layer.shadowOffset = CGSize(width: 0, height: 3)
            }
            content.layer.shadowColor = UIColor(light: .black, dark: .white).cgColor
        }

        private let content: UIView = create {
            $0.backgroundColor = UIColor(light: .white, dark: .black)
            $0.layer.cornerRadius = 20
            $0.layer.masksToBounds = false
            $0.layer.shadowRadius = 7
        }
        private func addSubviews() {
            contentView.addSubview(content)
            content.addSubview(nameLabel)
            content.addSubview(detailsLabel)
            content.addSubview(timeLabel)
            content.addSubview(shareButton)
            content.addSubview(emotions)
            content.addSubview(emotionsLabel)
        }

        private func makeConstraints() {
            content.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            detailsLabel.translatesAutoresizingMaskIntoConstraints = false
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            shareButton.translatesAutoresizingMaskIntoConstraints = false
            emotions.translatesAutoresizingMaskIntoConstraints = false
            emotionsLabel.translatesAutoresizingMaskIntoConstraints = false

            timeLabel.setContentHuggingPriority(.required, for: .horizontal)
            timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            detailsLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            emotions.setContentHuggingPriority(.required, for: .vertical)
            emotionsLabel.setContentCompressionResistancePriority(.required, for: .vertical)

            let bottom = content.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15)
            bottom.priority = .defaultHigh
            bottom.isActive = true

            NSLayoutConstraint.activate([
                content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                content.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),

                nameLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
                nameLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 16),
                nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
                nameLabel.firstBaselineAnchor.constraint(equalTo: timeLabel.firstBaselineAnchor),

                detailsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
                detailsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                detailsLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
                detailsLabel.bottomAnchor.constraint(lessThanOrEqualTo: emotions.bottomAnchor),

                timeLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),

                shareButton.rightAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: 2),
                shareButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),

                emotions.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 0),
                emotions.topAnchor.constraint(greaterThanOrEqualTo: nameLabel.bottomAnchor, constant: 24),
                emotions.topAnchor.constraint(greaterThanOrEqualTo: detailsLabel.bottomAnchor, constant: 24),
                emotions.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
                emotions.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -24),

                emotionsLabel.topAnchor.constraint(greaterThanOrEqualTo: nameLabel.bottomAnchor, constant: 24),
                emotionsLabel.topAnchor.constraint(greaterThanOrEqualTo: detailsLabel.bottomAnchor, constant: 24),
                emotionsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                emotionsLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
                emotionsLabel.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -24)
            ])
        }

        // MARK: - Internal

        static let reuseIdentifier = String(describing: UITableViewCell.self)

        let nameLabel: UILabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = UIFontMetrics.default.scaledFont(for: .boldSystemFont(ofSize: 20))
            $0.numberOfLines = 0
        }

        let detailsLabel: PaddedLabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 16))
            $0.textColor = UIColor(light: UIColor(hex: "292929"), dark: UIColor(hex: "d6d6d6"))
            $0.numberOfLines = 0
            $0.textInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
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
            $0.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 16))
            $0.numberOfLines = 0
        }

        let emotions: LinearContainerView = create {
            $0.paddingX = 10
            $0.paddingY = 10
        }

        var expanded = false {
            didSet {
                [(nameLabel, 1), (detailsLabel, 3), (emotionsLabel, 1)].forEach {
                    $0.numberOfLines = (expanded ? 0 : $1)
                }
                emotions.singleLine = !expanded
            }
        }
    }
}
