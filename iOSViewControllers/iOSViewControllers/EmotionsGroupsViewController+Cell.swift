import UIKit
import iOSControls

extension EmotionsGroupsViewController {

    final class Cell: UICollectionViewCell {

        static let reuseIdentifier = String(describing: Cell.self)

        // MARK: - UIView

        override init(frame: CGRect) {
            super.init(frame: frame)

            layer.borderWidth = 2

            contentView.addSubview(text)
            text.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                text.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                text.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                text.topAnchor.constraint(equalTo: contentView.topAnchor),
                text.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = min(bounds.size.width, bounds.size.height) / 2
        }

        // MARK: - NSCoder

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Internal

        let text: PaddedLabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textInsets = UIEdgeInsets(top: 5, left: 15, bottom: 7, right: 15)
        }
    }
}
