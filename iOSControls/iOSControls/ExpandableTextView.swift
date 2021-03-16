import UIKit

public class ExpandableTextView: UITextView {

    // MARK: - NSCoding

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView

    public override var intrinsicContentSize: CGSize {
        guard let heightConstraints = heightConstraints else {
            return super.intrinsicContentSize
        }
        var height = contentSize.height
        height = max(height, heightConstraints.min)
        height = min(height, heightConstraints.max)
        return CGSize(width: super.intrinsicContentSize.width, height: height)
    }

    // MARK: - Public

    public var heightConstraints: (min: CGFloat, max: CGFloat)? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    public init() {
        super.init(frame: .zero, textContainer: nil)
        delegate = self
        text = ""
    }
}

extension ExpandableTextView: UITextViewDelegate {

    public func textViewDidChange(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
    }
}
