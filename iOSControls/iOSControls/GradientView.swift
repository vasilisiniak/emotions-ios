import UIKit

public final class GradientView: UIView {
    
    // MARK: - UIView
    
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    // MARK: - NSCoding
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    // MARK: - Public
    
    public init() {
        super.init(frame: .zero)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }
    
    public var colors: [UIColor] {
        get {
            let colors = gradientLayer.colors as! [CGColor]
            return colors.map(UIColor.init(cgColor:))
        }
        set {
            gradientLayer.colors = newValue.map(\.cgColor)
        }
    }
}
