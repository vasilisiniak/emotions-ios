import UIKit

extension UIBarButtonItem {
    public convenience init(title: String, handler: @escaping () -> ()) {
        let button = UIButton(type: .system)
        button.addAction(UIAction { _ in handler() }, for: .touchUpInside)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        self.init(customView: button)
   }
}
