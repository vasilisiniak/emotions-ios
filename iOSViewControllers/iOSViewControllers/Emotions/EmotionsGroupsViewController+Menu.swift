import UIKit

extension EmotionsGroupsViewController {

    final class Menu: UIViewController {

        private final class View: UIView {

            private static let padding: CGFloat = 13

            private let title: UILabel = create {
                $0.adjustsFontForContentSizeCategory = true
                $0.font = .preferredFont(forTextStyle: .headline)
            }

            private let text: UILabel = create {
                $0.adjustsFontForContentSizeCategory = true
                $0.font = .preferredFont(forTextStyle: .body)
                $0.numberOfLines = 0
            }

            private func layout() {
                addSubview(title)
                addSubview(text)

                title.translatesAutoresizingMaskIntoConstraints = false
                text.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.padding),
                    title.topAnchor.constraint(equalTo: topAnchor, constant: Self.padding),
                    title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.padding),

                    text.leadingAnchor.constraint(equalTo: title.leadingAnchor),
                    text.topAnchor.constraint(equalTo: title.bottomAnchor, constant: Self.padding * 0.7),
                    text.trailingAnchor.constraint(equalTo: title.trailingAnchor),
                    text.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.padding)
                ])
            }

            init(title: String, text: String, color: UIColor, width: CGFloat) {
                super.init(frame: .zero)
                layout()

                self.title.text = title
                self.title.textColor = color
                self.text.text = text
                self.text.textColor = color
                self.text.preferredMaxLayoutWidth = width - 2 * Self.padding
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }

        deinit {
            handler()
        }

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private

        private let handler: Handler
        private let width: CGFloat

        // MARK: - Internal

        typealias Handler = () -> Void

        init(title: String, text: String, color: UIColor, width: CGFloat, handler: @escaping Handler) {
            self.width = width
            self.handler = handler
            super.init(nibName: nil, bundle: nil)
            view = View(title: title, text: text, color: color, width: width)
            preferredContentSize = view.systemLayoutSizeFitting(CGSize(width: width, height: .greatestFiniteMagnitude))
        }
    }
}
