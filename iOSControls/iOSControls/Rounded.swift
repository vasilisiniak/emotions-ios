import UIKit

public final class Rounded<V: UIView>: UIView {

    // MARK: - UIView

    public override func layoutSubviews() {
        super.layoutSubviews()

        view.layer.masksToBounds = true
        view.layer.cornerRadius = bounds.height / 2
    }

    public override var intrinsicContentSize: CGSize {
        view.intrinsicContentSize
    }

    // MARK: - Public

    public lazy var view: V = {
        let view = V()

        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        return view
    }()
}
