import Foundation
import UIKit

extension Bundle {

    public var appName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }

    public var appIcon: UIImage? {
        guard
            let icons = object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last
        else {
            return nil
        }
        return UIImage(named: lastIcon)
    }
}
