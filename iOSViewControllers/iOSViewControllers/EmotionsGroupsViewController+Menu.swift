import UIKit
import iOSControls

fileprivate extension PaddedLabel {
    func sizeToPaddedFit() {
        let height = ceil(text!.boundingRect(
            with: CGSize(
                width: bounds.size.width - textInsets.left - textInsets.right,
                height: .greatestFiniteMagnitude
            ),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font!],
            context: nil
        ).height) + textInsets.top + textInsets.bottom
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: height)
    }
}

extension EmotionsGroupsViewController {

    final class Menu: UIViewController {

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - UIViewController

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            label.frame = CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)
            label.sizeToPaddedFit()
        }

        // MARK: - Private

        private func createLabel(text: String) -> PaddedLabel {
            let label = PaddedLabel()
            label.textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            label.text = text
            label.adjustsFontForContentSizeCategory = true
            label.font = .preferredFont(forTextStyle: .body)
            label.numberOfLines = 0
            label.frame = CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)
            label.sizeToPaddedFit()
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }

        private let handler: Handler
        private let width: CGFloat
        private var label: PaddedLabel!

        // MARK: - Internal

        typealias Handler = () -> Void

        init(text: String, width: CGFloat, handler: @escaping Handler) {
            self.width = width
            self.handler = handler
            super.init(nibName: nil, bundle: nil)
            label = createLabel(text: text)
            view = label
            preferredContentSize = label.frame.size
        }

        deinit {
            handler()
        }
    }
}
