import UIKit
import iOSControls

extension PasscodeViewController {

    final class Keypad: UIView {

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private

        private func addSubviews() {

            let lines = UIStackView()
            lines.axis = .vertical
            lines.alignment = .fill
            lines.distribution = .equalSpacing

            let lastLine = UIStackView(arrangedSubviews: [UILabel(), button(title: "0"), UILabel()])
            lastLine.axis = .horizontal
            lastLine.alignment = .center
            lastLine.distribution = .equalSpacing

            for i in 0..<3 {
                let line = UIStackView()
                line.axis = .horizontal
                line.distribution = .equalSpacing

                for j in 1...3 {
                    line.addArrangedSubview(button(title: "\(i * 3 + j)"))
                }
                
                lines.addArrangedSubview(line)
            }

            lines.addArrangedSubview(lastLine)

            addSubview(lines)
            lines.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                lines.leadingAnchor.constraint(equalTo: leadingAnchor),
                lines.trailingAnchor.constraint(equalTo: trailingAnchor),
                lines.topAnchor.constraint(equalTo: topAnchor),
                lines.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

            for button in buttons {
                button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.26).isActive = true
            }
        }

        private func button(title: String) -> Rounded<UIButton> {
            let button = Rounded<UIButton>()

            button.view.setTitle(title, for: .normal)
            button.view.setTitleColor(.systemBackground, for: .normal)
            button.view.backgroundColor = .secondaryLabel
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setContentHuggingPriority(.required, for: .vertical)
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentCompressionResistancePriority(.required, for: .vertical)
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true

            button.layoutHandler = { $0.view.titleLabel?.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: $0.frame.height / 2)) }

            button.view.addAction(UIAction { [button] _ in
                button.view.backgroundColor = .quaternaryLabel
            }, for: .touchDown)

            button.view.addAction(UIAction { [button] _ in
                UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction]) {
                    button.view.backgroundColor = .secondaryLabel
                }
            }, for: [.touchUpInside, .touchDragExit])

            buttons.append(button)

            return button
        }

        // MARK: - Internal

        private(set) var buttons = [Rounded<UIButton>]()

        init() {
            super.init(frame: .zero)
            addSubviews()
        }
    }
}
