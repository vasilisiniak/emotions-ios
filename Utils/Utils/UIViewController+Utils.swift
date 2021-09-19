import UIKit

extension UIViewController {
    public var topPresentedViewController: UIViewController {
        return presentedViewController?.topPresentedViewController ?? self
    }
}
