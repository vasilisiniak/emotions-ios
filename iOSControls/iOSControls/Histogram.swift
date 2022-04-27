import UIKit

final public class Histogram: UIView {

    enum Constants {
        static let Padding: CGFloat = 5
        static let Radius: CGFloat = 5
    }

    public struct Item {

        // MARK: - Public

        public let name: String
        public let color: UIColor
        public let value: Double

        public init(name: String, color: UIColor, value: Double) {
            self.name = name
            self.color = color
            self.value = value
        }
    }

    private class Label: UIView {

        // MARK: - UIView

        override func layoutSubviews() {
            super.layoutSubviews()
            selectedMask?.frame = bounds
        }

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private

        private var selectedMask: CAGradientLayer?

        private func addLabel(_ item: Item) {
            let label = UILabel()
            label.text = item.name
            label.textColor = .black
            label.font = .preferredFont(forTextStyle: .body)
            label.textAlignment = .center
            label.adjustsFontForContentSizeCategory = true

            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor),
                label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
            ])
        }

        private func addSelected(_ item: Item) {
            let view = UIView()
            view.layer.cornerRadius = Constants.Radius
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowRadius = 10
            view.layer.shadowOpacity = 0.2
            view.backgroundColor = item.color

            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.widthAnchor.constraint(equalTo: widthAnchor, multiplier: item.value),
                view.topAnchor.constraint(equalTo: topAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        private func addSelectedLabel(_ item: Item) -> CAGradientLayer {
            let mask = CAGradientLayer()
            mask.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
            mask.startPoint = CGPoint(x: item.value + 1e-10, y: 0.5)
            mask.endPoint = CGPoint(x: item.value - 1e-10, y: 0.5)

            let label = UILabel()
            label.layer.mask = mask
            label.text = item.name
            label.textColor = item.color.text
            label.font = .preferredFont(forTextStyle: .body)
            label.textAlignment = .center
            label.adjustsFontForContentSizeCategory = true

            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor),
                label.topAnchor.constraint(equalTo: topAnchor),
                label.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

            return mask
        }

        // MARK: - Internal

        init(_ item: Item) {
            super.init(frame: .zero)

            backgroundColor = item.color.withAlphaComponent(0.4)
            layer.cornerRadius = Constants.Radius
            layer.masksToBounds = true

            addLabel(item)
            addSelected(item)
            selectedMask = addSelectedLabel(item)
        }
    }

    // MARK: - Private

    private var labels: [Label] = []

    private func addLabels() {
        labels.forEach { $0.removeFromSuperview() }

        labels = items.map(Label.init)
        labels.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Padding).isActive = true
            $0.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Padding).isActive = true
        }

        zip(labels.dropLast(), labels.dropFirst()).forEach {
            $0.bottomAnchor.constraint(equalTo: $1.topAnchor, constant: -Constants.Padding).isActive = true
        }

        labels.first?.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Padding).isActive = true
        labels.last?.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Padding).isActive = true
    }

    // MARK: - Public

    public var items: [Item] = [] {
        didSet { addLabels() }
    }
}
