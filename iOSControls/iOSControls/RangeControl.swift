import UIKit

public final class RangeControl: UIControl {

    private enum Constants {
        static let Radius: CGFloat = 25
        static let Thickness: CGFloat = 4
        static let ShadowRadius: CGFloat = 5
        static let ShadowOffset: CGFloat = 2
    }

    // MARK: - UIView

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard prevBounds != bounds else { return }

        if prevBounds == .zero {
            sendActions(for: .valueChanged)
        }

        prevBounds = bounds

        update()
    }

    // MARK: - NSCoding

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private var start: CGFloat = 0
    private var prevBounds: CGRect = .zero
    private var active: NSLayoutConstraint?

    private var selectedValue: (CGFloat, CGFloat) = (0, 1) {
        didSet { sendActions(for: .valueChanged) }
    }

    private lazy var range: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        view.layer.cornerRadius = Constants.Thickness / 2

        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: Constants.Thickness).isActive = true

        return view
    }()

    private lazy var selectedRange: UIView = {
        let view = UIView()

        range.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: range.topAnchor),
            view.bottomAnchor.constraint(equalTo: range.bottomAnchor)
        ])

        return view
    }()

    private lazy var left: (view: UIView, constraint: NSLayoutConstraint) = {
        let slider = addSlider()
        slider.view.centerXAnchor.constraint(equalTo: selectedRange.leadingAnchor).isActive = true
        return slider
    }()

    private lazy var right: (view: UIView, constraint: NSLayoutConstraint) = {
        let slider = addSlider()

        NSLayoutConstraint.activate([
            slider.view.centerXAnchor.constraint(equalTo: selectedRange.trailingAnchor),
            slider.view.leadingAnchor.constraint(greaterThanOrEqualTo: left.view.trailingAnchor),
        ])
        return slider
    }()

    private lazy var gesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        addGestureRecognizer(pan)
        return pan
    }()

    private func addSlider() -> (view: UIView, constraint: NSLayoutConstraint) {
        let view = UIView()
        view.layer.cornerRadius = Constants.Radius / 2
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = Constants.ShadowRadius
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: Constants.ShadowOffset)

        range.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        let constraint = view.centerXAnchor.constraint(equalTo: range.leadingAnchor)
        constraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: Constants.ShadowRadius - Constants.ShadowOffset),
            view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -Constants.ShadowRadius - Constants.ShadowOffset),
            view.heightAnchor.constraint(equalToConstant: Constants.Radius),
            view.widthAnchor.constraint(equalToConstant: Constants.Radius),
            view.centerYAnchor.constraint(equalTo: range.centerYAnchor),
            view.centerXAnchor.constraint(greaterThanOrEqualTo: range.leftAnchor),
            view.centerXAnchor.constraint(lessThanOrEqualTo: range.rightAnchor),
            constraint
        ])

        return (view, constraint)
    }

    private func addLimitLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])

        return label
    }

    @objc private func onPan() {
        switch gesture.state {
        case .began:
            let x = gesture.location(in: range).x
            active = abs(left.view.center.x - x) < abs(right.view.center.x - x) ? left.constraint : right.constraint
            start = active!.constant

        case .changed:
            active?.constant = start + gesture.translation(in: self).x
            if active == right.constraint {
                left.constraint.constant = max(0, min(left.constraint.constant, right.constraint.constant - right.view.bounds.width))
                if right.constraint.constant < left.constraint.constant + left.view.bounds.width {
                    right.constraint.constant = left.constraint.constant + left.view.bounds.width
                }
            }
            else {
                if right.constraint.constant < left.constraint.constant + left.view.bounds.width {
                    right.constraint.constant = left.constraint.constant + left.view.bounds.width
                }
                left.constraint.constant = min(left.constraint.constant, range.bounds.width - right.view.bounds.width)
            }
            selectedValue = (
                min(1, max(0, left.constraint.constant / range.bounds.width)),
                min(1, max(0, right.constraint.constant / range.bounds.width))
            )

        case .ended:
            if left.constraint.constant < 0 {
                left.constraint.constant = 0
            }
            if right.constraint.constant > range.bounds.width {
                right.constraint.constant = range.bounds.width
            }

        default: break
        }
    }

    private func update() {
        left.constraint.constant = selectedValue.0 * range.bounds.width
        right.constraint.constant = selectedValue.1 * range.bounds.width
    }

    // MARK: - Public

    public var value: (Double, Double) {
        get { (Double(selectedValue.0), Double(selectedValue.1)) }
        set {
            selectedValue.0 = CGFloat(min(1, max(0, newValue.0)))
            selectedValue.1 = CGFloat(min(1, max(0, newValue.1)))
            update()
        }
    }

    public lazy var limits: (left: UILabel, right: UILabel) = {
        let left = addLimitLabel()
        let right = addLimitLabel()

        left.textAlignment = .right
        right.textAlignment = .left

        NSLayoutConstraint.activate([
            left.leadingAnchor.constraint(equalTo: leadingAnchor),
            right.trailingAnchor.constraint(equalTo: trailingAnchor),
            left.trailingAnchor.constraint(equalTo: range.leadingAnchor, constant: -Constants.Radius / 2 - Constants.ShadowRadius),
            right.leadingAnchor.constraint(equalTo: range.trailingAnchor, constant: Constants.Radius / 2 + Constants.ShadowRadius),
            left.widthAnchor.constraint(equalTo: right.widthAnchor),
            left.centerYAnchor.constraint(equalTo: range.centerYAnchor),
            left.centerYAnchor.constraint(equalTo: right.centerYAnchor)
        ])

        return (left, right)
    }()

    public init() {
        super.init(frame: .zero)

        gesture.maximumNumberOfTouches = 1

        limits.left.text = " "
        limits.right.text = " "

        range.backgroundColor = .systemGray5
        selectedRange.backgroundColor = .systemBlue
        left.view.backgroundColor = .systemBackground
        right.view.backgroundColor = .systemBackground

        update()
    }
}
