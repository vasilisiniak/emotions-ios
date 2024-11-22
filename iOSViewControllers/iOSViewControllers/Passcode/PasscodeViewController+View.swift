import UIKit

extension PasscodeViewController {

    final class View: UIView {

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private

        private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

        private let stack: UIStackView = create {
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }

        private let headerStack: UIStackView = create {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = 20
        }

        private func addSubviews() {
            addSubview(blurView)
            addSubview(stack)

            headerStack.addArrangedSubview(info)
            headerStack.addArrangedSubview(task)
            headerStack.addArrangedSubview(passcode)
            headerStack.addArrangedSubview(error)

            stack.addArrangedSubview(headerStack)
            stack.addArrangedSubview(keypad)
            stack.addArrangedSubview(cancel)
        }

        private func makeConstraints() {
            blurView.translatesAutoresizingMaskIntoConstraints = false
            stack.translatesAutoresizingMaskIntoConstraints = false
            keypad.translatesAutoresizingMaskIntoConstraints = false
            headerStack.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
                blurView.topAnchor.constraint(equalTo: topAnchor),
                blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

                keypad.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75),
                keypad.heightAnchor.constraint(equalTo: keypad.widthAnchor, multiplier: 1.22),

                stack.leadingAnchor.constraint(equalTo: leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: trailingAnchor),
                stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50),
                stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30),

                headerStack.widthAnchor.constraint(equalTo: widthAnchor, constant: -20)
            ])
        }

        // MARK: - Internal

        let keypad = Keypad()
        let passcode = Passcode()

        let info: UILabel = create {
            $0.textColor = .label
            $0.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 24))
            $0.text = " "
        }

        let task: UILabel = create {
            $0.textColor = .label
            $0.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 18))
            $0.text = " "
        }

        let error: UILabel = create {
            $0.textColor = .label
            $0.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 18))
            $0.text = " "
        }

        let cancel: UIButton = {
            let button = UIButton(type: .system)
            button.titleLabel?.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 16))
            button.setTitleColor(.label, for: .normal)
            return button
        }()

        init() {
            super.init(frame: .zero)
            addSubviews()
            makeConstraints()
        }
    }
}
