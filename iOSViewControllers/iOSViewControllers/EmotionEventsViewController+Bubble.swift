import UIKit
import iOSControls

extension EmotionEventsViewController {

    final class Bubble: UIView {

        // MARK: - Internal

        class func create(_ text: String, _ color: UIColor) -> UIView {
            let bubble = Rounded<PaddedLabel>()
            bubble.view.text = text
            bubble.view.textColor = color.text
            bubble.view.textInsets = UIEdgeInsets(top: 2, left: 7, bottom: 3, right: 7)
            bubble.view.backgroundColor = color
            return bubble
        }
    }
}
