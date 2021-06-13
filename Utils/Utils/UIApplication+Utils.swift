import UIKit

extension UIApplication {
    public var scene: UIWindowScene {
        return connectedScenes.first(where: { $0.activationState == .foregroundActive }) as! UIWindowScene
    }
}
