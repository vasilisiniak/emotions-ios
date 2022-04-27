import UIKit

final public class GradientedTop<V: UIView>: UIView {

    // MARK: - UIView

    public override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }

    // MARK: - Private

    private let gradient: CAGradientLayer = create { $0.colors = [UIColor.clear.cgColor, UIColor.black.cgColor] }

    private func update() {
        gradient.frame = bounds
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: offset / bounds.height)
    }

    // MARK: - Public

    public var offset: CGFloat = 100 {
        didSet { update() }
    }

    public var view: V? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let view = view else { return }

            addSubview(view)
            view.layer.mask = gradient
            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.topAnchor.constraint(equalTo: topAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
}
