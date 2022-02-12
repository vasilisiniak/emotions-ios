import UIKit

public class ExpandableTextView: UITextView {

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

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
        height = min(height, heightConstraints.max ?? height)
        return CGSize(width: super.intrinsicContentSize.width, height: height)
    }

    // MARK: - Private

    private var observer: NSObjectProtocol?

    // MARK: - Public

    public var heightConstraints: (min: CGFloat, max: CGFloat?)? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    public init() {
        super.init(frame: .zero, textContainer: nil)
        observer = NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: self, queue: .main) { [weak self] _ in
            self?.invalidateIntrinsicContentSize()
        }
        text = ""
    }
}

extension ExpandableTextView: UITextViewDelegate {

    public func textViewDidChange(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
    }
}
