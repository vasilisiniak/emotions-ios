import UIKit

public final class LinearContainerView: UIView {

    // MARK: - UIView

    @objc func _needsDoubleUpdateConstraintsPass() -> Bool {
        return true
    }

    public override func layoutSubviews() {
        layout(for: bounds.width)
        gradient.frame = bounds
        layer.mask = needsGradient ? gradient : nil
        invalidateIntrinsicContentSize()
    }

    public override var intrinsicContentSize: CGSize {
        layout(for: engineBounds?.width ?? 0)
        let width = views.map(\.frame.maxX).max() ?? 0
        let height = views.map(\.frame.maxY).max() ?? 0
        return CGSize(width: width, height: height)
    }

    // MARK: - Private

    private var views: [UIView] = []
    private var width: CGFloat?

    private lazy var gradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.8, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.colors = [
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        return layer
    }()

    var needsGradient: Bool {
        guard singleLine else { return false }
        let maxX = views.map(\.frame.maxX).max() ?? 0
        return maxX > bounds.maxX
    }

    private var engineBounds: CGRect? {
        let objcSelector = NSSelectorFromString("_nsis_compatibleBoundsInEngine:")
        typealias CFunction = @convention(c) (AnyObject, Selector, Any) -> CGRect

        let impl = class_getMethodImplementation(type(of: self).self, objcSelector)
        let callableImpl = unsafeBitCast(impl, to: CFunction.self)

        return layoutEngine.flatMap { callableImpl(self, objcSelector, $0) }
    }

    private var layoutEngine: Any? {
        let objcSelector = NSSelectorFromString("nsli_layoutEngine")
        typealias CFunction = @convention(c) (AnyObject, Selector) -> Any

        let impl = class_getMethodImplementation(type(of: self).self, objcSelector)
        let callableImpl = unsafeBitCast(impl, to: CFunction.self)

        return callableImpl(self, objcSelector)
    }

    private func layout(for width: CGFloat) {
        guard width != self.width else { return }
        self.width = width

        var x: CGFloat = 0
        var y: CGFloat = 0

        views.forEach {
            $0.frame.size = $0.intrinsicContentSize

            if !singleLine && (x > 0) && (width > 0) && (x + $0.frame.width > width) {
                x = 0
                y += $0.frame.height + paddingY
            }

            $0.frame.origin.x = x
            $0.frame.origin.y = y
            x += $0.frame.width + paddingX
        }
    }

    // MARK: - Public

    public var singleLine = false {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    public var paddingX: CGFloat = 5 {
        didSet {
            width = nil
            layoutSubviews()
        }
    }

    public var paddingY: CGFloat = 5 {
        didSet {
            width = nil
            layoutSubviews()
        }
    }

    public func add(view: UIView) {
        addSubview(view)
        views.append(view)

        width = nil

        if superview?.bounds != .zero {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    public func removeAll() {
        views.forEach { $0.removeFromSuperview() }
        views.removeAll()

        width = nil

        if superview?.bounds != .zero {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
}
