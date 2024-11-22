import UIKit

extension PasscodeViewController {

    final class Passcode: UIView {

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private

        private let stack: UIStackView = create {
            $0.axis = .horizontal
            $0.spacing = 30
        }

        private func addSubviews() {
            addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: trailingAnchor),
                stack.topAnchor.constraint(equalTo: topAnchor),
                stack.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        private func dot() -> UIView {
            let size = CGFloat(15)
            let view = UIView()

            view.layer.cornerRadius = size / 2
            view.layer.borderColor = UIColor.label.cgColor
            view.layer.borderWidth = 1

            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: size),
                view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1)
            ])

            return view
        }

        private func updateTotal() {
            while stack.arrangedSubviews.count < total {
                stack.addArrangedSubview(dot())
            }
            while stack.arrangedSubviews.count > total {
                stack.removeArrangedSubview(stack.arrangedSubviews.last!)
            }
        }

        private func updateFilled() {
            for i in stack.arrangedSubviews.indices {
                stack.arrangedSubviews[i].layer.borderColor = UIColor.label.cgColor
                stack.arrangedSubviews[i].backgroundColor = i < filled ? .label : .clear
            }
        }

        // MARK: - Internal

        var total = 4 {
            didSet { updateTotal() }
        }

        var filled = 0 {
            didSet { updateFilled() }
        }

        func updateColors() {
            updateTotal()
            updateFilled()
        }

        func shake() {
            transform = .init(translationX: 20, y: 0)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseIn) { [weak self] in
                self?.transform = .identity
            }
        }

        init() {
            super.init(frame: .zero)
            addSubviews()
        }
    }
}
