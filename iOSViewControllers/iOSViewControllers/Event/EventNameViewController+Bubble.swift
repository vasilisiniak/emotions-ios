import UIKit
import iOSControls

extension EventNameViewController {

    final class Bubble: UIView {

        // MARK: - Internal

        class func create(_ text: String, _ color: UIColor) -> UIView {
            let bubble = Rounded<PaddedLabel>()
            bubble.view.adjustsFontForContentSizeCategory = true
            bubble.view.font = .preferredFont(forTextStyle: .footnote)
            bubble.view.text = text
            bubble.view.textColor = color.text
            bubble.view.textInsets = UIEdgeInsets(top: 2, left: 8, bottom: 3, right: 8)
            bubble.view.backgroundColor = color
            return bubble
        }
    }
}
