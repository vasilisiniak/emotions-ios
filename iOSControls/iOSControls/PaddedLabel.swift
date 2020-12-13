import UIKit

public class PaddedLabel: UILabel {
    
    // MARK: - UIView
    
    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        if size == .zero {
            return .zero
        }
        else {
            let width = size.width + textInsets.left + textInsets.right
            let height = size.height + textInsets.top + textInsets.bottom
            return CGSize(width: width, height: height)
        }
    }
    
    // MARK: - UILabel
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    // MARK: - Public
    
    public var textInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
}
