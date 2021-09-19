import UIKit

extension EmotionNotFoundViewController {

    final class View: UIView {

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private

        private func addSubviews() {
            addSubview(label)
            addSubview(button)
        }

        private func makeConstraints() {
            label.translatesAutoresizingMaskIntoConstraints = false
            button.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
                label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),

                button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 50),
                button.centerXAnchor.constraint(equalTo: centerXAnchor),
                button.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.9),
                button.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -30)
            ])
        }

        // MARK: - Internal

        let label: UILabel = create {
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = .label
            $0.adjustsFontForContentSizeCategory = true
            $0.adjustsFontSizeToFitWidth = true
            $0.numberOfLines = 0
        }

        let button: UIButton = {
            let button = UIButton(type: .system)
            button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
            button.setTitle("Предложить эмоцию", for: .normal)
            button.adjustsImageSizeForAccessibilityContentSizeCategory = true
            return button
        }()

        init() {
            super.init(frame: .zero)
            backgroundColor = .systemBackground
            addSubviews()
            makeConstraints()
        }
    }
}
