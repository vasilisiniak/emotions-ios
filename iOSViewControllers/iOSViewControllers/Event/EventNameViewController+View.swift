import UIKit
import iOSControls

extension EventNameViewController {

    final class View: UIView {

        deinit {
            observers?.forEach { NotificationCenter.default.removeObserver($0) }
        }

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private

        private var observers: [NSObjectProtocol]?

        private func addSubviews() {
            addSubview(backgroundView)
            addSubview(date)
            addSubview(name)
            addSubview(details)
            addSubview(label)
        }

        private func makeConstraints() {
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            date.translatesAutoresizingMaskIntoConstraints = false
            name.translatesAutoresizingMaskIntoConstraints = false
            details.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false

            name.setContentCompressionResistancePriority(.required, for: .vertical)
            label.setContentCompressionResistancePriority(.required, for: .vertical)

            NSLayoutConstraint.activate([
                backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
                backgroundView.topAnchor.constraint(equalTo: topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

                date.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                date.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
                date.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 2),

                name.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
                name.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
                name.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 9),

                details.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
                details.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
                details.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 9),

                label.topAnchor.constraint(equalTo: details.bottomAnchor, constant: 9),
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor),
                label.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor)
            ])
        }

        // MARK: - Internal

        let backgroundView = UIView()

        let date: UIDatePicker = create {
            $0.contentHorizontalAlignment = .leading
            $0.datePickerMode = .dateAndTime
            $0.preferredDatePickerStyle = .compact
        }

        let name: ExpandableTextView = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = .preferredFont(forTextStyle: .body)
            $0.backgroundColor = .systemBackground.withAlphaComponent(0.5)
            $0.textContainer.maximumNumberOfLines = 2
            $0.textContainer.lineBreakMode = .byTruncatingTail
            $0.returnKeyType = .next
            $0.heightConstraints = (min: $0.font!.lineHeight + 18, max: $0.font!.lineHeight * 3)
        }

        let details: ExpandableTextView = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = .preferredFont(forTextStyle: .body)
            $0.backgroundColor = .systemBackground.withAlphaComponent(0.5)
            $0.heightConstraints = (min: $0.font!.lineHeight * 3, max: nil)
        }

        let label: PaddedLabel = create {
            $0.font = .preferredFont(forTextStyle: .headline)
            $0.adjustsFontForContentSizeCategory = true
            $0.numberOfLines = 0
            $0.textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }

        init() {
            super.init(frame: .zero)
            backgroundColor = .systemBackground
            addSubviews()
            makeConstraints()

            observers = [
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] in
                    let duration = ($0.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                    let height = ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                    let safe = self?.safeAreaInsets.bottom ?? 0

                    self?.layoutIfNeeded()
                    UIView.animate(withDuration: duration) {
                        self?.layoutMargins.bottom = height - safe
                        self?.layoutIfNeeded()
                    }
                },
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] in
                    let duration = ($0.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                    self?.layoutIfNeeded()
                    UIView.animate(withDuration: duration) {
                        self?.layoutMargins.bottom = self?.safeAreaInsets.bottom ?? 0
                        self?.layoutIfNeeded()
                    }
                }
            ]
        }
    }
}
