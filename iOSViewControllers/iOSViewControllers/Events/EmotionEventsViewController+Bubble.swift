import UIKit
import iOSControls

extension EmotionEventsViewController {

    final class Bubble: UIView {

        // MARK: - Internal

        class func create(_ text: String, _ color: UIColor) -> UIView {
            let bubble = Rounded<PaddedLabel>()
            bubble.view.adjustsFontForContentSizeCategory = true
            bubble.view.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 16))
            bubble.view.text = text
            bubble.view.textColor = color.text
            bubble.view.textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            bubble.view.backgroundColor = color
            return bubble
        }
    }
}
